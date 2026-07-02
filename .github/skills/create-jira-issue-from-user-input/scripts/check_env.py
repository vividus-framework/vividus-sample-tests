"""
Verify that a caller-supplied list of environment variables is available, and
optionally read their values.

Generic and reusable across skills: pass the names of the variables you require.
Each variable is considered available if it is already set in the current
process environment, or if it is defined in a .env file in the current directory
(the workspace root, from which the skill's scripts are always invoked).

Usage:
  # Verify only (default) — prints variable names, never values:
  python3 check_env.py --vars VAR_A VAR_B VAR_C

  # Verify AND read — after all vars are confirmed present, emit KEY=VALUE lines:
  python3 check_env.py --print --vars JIRA_CLOUD_ID JIRA_PROJECT JIRA_BASE_URL

  # Override where the .env is discovered (default: ./.env in the current dir):
  python3 check_env.py --vars VAR_A --env-file /path/to/.env

Options:
  --vars      One or more environment variable names to require (mandatory).
  --print     After verification, print each requested variable as `KEY=VALUE`
              (parseable) on stdout. Verification still runs first: if any var is
              missing, nothing is printed and the script aborts.
              ⚠️ Only use this for values you are comfortable printing to stdout —
              do NOT pass secrets (API tokens, passwords) with --print.
  --env-file  Optional explicit path to a .env file. When omitted, the script
              looks for ./.env in the current directory (the workspace root, from
              which the skill's scripts are always invoked).

Exit codes:
  0  all required variables are available (and printed, if --print)
  1  one or more required variables are missing (names printed to stderr)

Without --print, values are never emitted — only variable names and status.
"""
import argparse
import os
import sys

from env_utils import load_dotenv


def check_env(var_names, env_file: str = "") -> list:
    """Return the list of required variable names that are missing/empty."""
    load_dotenv(env_file)
    return [name for name in var_names if not os.environ.get(name, "").strip()]


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Verify a caller-supplied list of environment variables is available."
    )
    parser.add_argument(
        "--vars",
        nargs="+",
        required=True,
        help="One or more environment variable names to require.",
    )
    parser.add_argument(
        "--print",
        dest="print_values",
        action="store_true",
        help="After verification, print each requested variable as KEY=VALUE. "
        "Do NOT use for secrets you don't want on stdout.",
    )
    parser.add_argument(
        "--env-file",
        default="",
        help="Optional explicit path to a .env file (default: ./.env in the current directory).",
    )
    args = parser.parse_args()

    missing = check_env(args.vars, args.env_file)

    if missing:
        print(
            "❌ ABORTED: required environment variables not configured.\n"
            f"Missing required variable(s): {', '.join(missing)}\n"
            "Set them in the process env or .env.",
            file=sys.stderr,
        )
        sys.exit(1)

    if args.print_values:
        # stdout stays purely parseable (KEY=VALUE lines only); status goes to stderr.
        for name in args.vars:
            print(f"{name}={os.environ.get(name, '')}")
        print(
            f"✅ All required environment variables available: {', '.join(args.vars)}",
            file=sys.stderr,
        )
    else:
        print(f"✅ All required environment variables available: {', '.join(args.vars)}")


if __name__ == "__main__":
    main()
