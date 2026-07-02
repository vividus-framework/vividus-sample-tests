"""
Shared environment helpers for the skill's scripts.

Provides a single .env loader so scripts don't each reimplement it. Values
already present in the process environment always take precedence and are never
overwritten by the .env file.
"""
import os
from pathlib import Path


def load_dotenv(env_file: str = "") -> None:
    """Load KEY=VALUE pairs from a .env file into os.environ (no-op if not found).

    If ``env_file`` is given, only that path is consulted. Otherwise the
    project-root ``.env`` is used: this skill's scripts are always invoked from
    the workspace root, so ``Path.cwd() / ".env"`` is the project ``.env``. This
    is intentional — no ancestor walk — so a missing project ``.env`` fails
    loudly at Step 0 instead of silently loading an unrelated parent's file.
    Existing process-env values take precedence (never overwritten).
    """
    candidate = Path(env_file) if env_file else Path.cwd() / ".env"

    if candidate.is_file():
        with candidate.open(encoding="utf-8") as fh:
            for line in fh:
                line = line.strip()
                if not line or line.startswith("#") or "=" not in line:
                    continue
                key, _, value = line.partition("=")
                key = key.strip()
                value = value.strip().strip('"').strip("'")
                if key and key not in os.environ:
                    os.environ[key] = value
