"""
Ensure the evidence directory (.playwright-mcp) exists in the current working
directory and print its absolute path. The path is printed whether or not the
directory already existed, so callers can resolve EVIDENCES_DIR in a single step.

Usage:
  python3 prepare_evidence_dir.py

Output (parseable, forward-slashed, trailing slash for easy concatenation):
  EVIDENCES_DIR=/abs/path/to/cwd/.playwright-mcp/

The directory is always created under the current working directory and is
always named .playwright-mcp. Cross-platform: standard library only; forward
slashes are emitted so the value can be used directly with the Playwright
browser tools on any OS (macOS, Linux, Windows).
"""
import sys
from pathlib import Path

DIR_NAME = ".playwright-mcp"


def main() -> None:
    evidence_dir = Path.cwd() / DIR_NAME

    if evidence_dir.exists() and not evidence_dir.is_dir():
        sys.exit(f"ERROR: {evidence_dir} exists but is not a directory.")

    evidence_dir.mkdir(parents=True, exist_ok=True)

    # Emit forward slashes + trailing slash so the value concatenates cleanly
    # with a filename on any OS (e.g. "<dir>/<file>.png").
    printable = evidence_dir.resolve().as_posix().rstrip("/") + "/"
    print(f"EVIDENCES_DIR={printable}")


if __name__ == "__main__":
    main()
