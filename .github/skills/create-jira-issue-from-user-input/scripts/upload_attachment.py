"""
Upload one or more screenshots (or any files) to a Jira issue as attachments.

Usage:
  python3 scripts/upload_attachment.py \
      --issue TEST-1234 \
      --file .playwright-mcp/before.png .playwright-mcp/after.png

  # --file may be repeated instead of space-separated:
  #   --file a.png --file b.png

Credentials are read from environment variables or a .env file in the project
root (or CWD). Required variables:
  JIRA_API_EMAIL  — Atlassian account email
  JIRA_API_KEY    — Atlassian API token
  JIRA_BASE_URL   — Jira site base URL (e.g. https://your-org.atlassian.net)

Exit codes:
  0  all files uploaded successfully
  1  error (details printed to stderr); partial uploads are reported
"""
import argparse
import os
import secrets
import sys
import mimetypes
from pathlib import Path
from urllib.request import urlopen, Request
from urllib.error import HTTPError, URLError
from base64 import b64encode
import json

from env_utils import load_dotenv


def upload(issue_key: str, file_path: Path, email: str, api_token: str, base_url: str) -> dict:
    url = f"{base_url.rstrip('/')}/rest/api/3/issue/{issue_key}/attachments"

    mime_type, _ = mimetypes.guess_type(str(file_path))
    mime_type = mime_type or "application/octet-stream"

    boundary = f"----PythonMultipartBoundary{secrets.token_hex(16)}"
    file_bytes = file_path.read_bytes()

    body = (
        f"--{boundary}\r\n"
        f'Content-Disposition: form-data; name="file"; filename="{file_path.name}"\r\n'
        f"Content-Type: {mime_type}\r\n\r\n"
    ).encode() + file_bytes + f"\r\n--{boundary}--\r\n".encode()

    credentials = b64encode(f"{email}:{api_token}".encode()).decode()
    req = Request(
        url,
        data=body,
        headers={
            "Authorization": f"Basic {credentials}",
            "X-Atlassian-Token": "no-check",
            "Content-Type": f"multipart/form-data; boundary={boundary}",
        },
        method="POST",
    )

    with urlopen(req) as resp:
        return json.loads(resp.read().decode())


def main() -> None:
    load_dotenv()
    parser = argparse.ArgumentParser(description="Attach one or more files to a Jira issue")
    parser.add_argument("--issue", required=True, help="Jira issue key, e.g. TEST-1234")
    parser.add_argument(
        "--file",
        required=True,
        nargs="+",
        action="extend",
        help="One or more paths to files to attach (space-separated, and/or repeat --file)",
    )
    args = parser.parse_args()

    email = os.environ.get("JIRA_API_EMAIL", "")
    token = os.environ.get("JIRA_API_KEY", "")
    base_url = os.environ.get("JIRA_BASE_URL", "")

    if not email or not token:
        sys.exit("ERROR: Jira credentials missing. Set JIRA_API_EMAIL and JIRA_API_KEY in the environment or .env file.")

    if not base_url:
        sys.exit("ERROR: Jira base URL missing. Set JIRA_BASE_URL in the environment or .env file.")

    file_paths = [Path(f) for f in args.file]
    missing = [str(p) for p in file_paths if not p.is_file()]
    if missing:
        sys.exit(f"ERROR: File(s) not found: {', '.join(missing)}")

    failures = []
    for file_path in file_paths:
        try:
            result = upload(args.issue, file_path, email, token, base_url)
            names = [a.get("filename", "") for a in result] if isinstance(result, list) else [result.get("filename", "")]
            print(f"✅ Attached {', '.join(names)} to {args.issue}")
        except HTTPError as exc:
            body = exc.read().decode(errors="replace")
            print(f"ERROR: {file_path} — HTTP {exc.code} — {body}", file=sys.stderr)
            failures.append(str(file_path))
        except URLError as exc:
            print(f"ERROR: {file_path} — Network error — {exc.reason}", file=sys.stderr)
            failures.append(str(file_path))

    if failures:
        sys.exit(f"ERROR: {len(failures)} of {len(file_paths)} upload(s) failed: {', '.join(failures)}")


if __name__ == "__main__":
    main()
