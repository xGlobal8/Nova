#!/bin/bash
# Sets up playwright-cli (used by the playwright-cli skill) in Claude Code cloud sessions.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-$(pwd)}"

if ! command -v playwright-cli >/dev/null 2>&1; then
  npm install -g @playwright/cli@latest
fi

# Point playwright-cli at the pre-installed Chromium instead of downloading Chrome.
browsers="${PLAYWRIGHT_BROWSERS_PATH:-/opt/pw-browsers}"
chrome="$(ls -d "$browsers"/chromium-*/chrome-linux*/chrome 2>/dev/null | sort -V | tail -n 1 || true)"
if [ -n "$chrome" ]; then
  mkdir -p .playwright
  cat > .playwright/cli.config.json <<JSON
{
  "browser": {
    "browserName": "chromium",
    "launchOptions": { "executablePath": "$chrome" }
  }
}
JSON
else
  echo "session-start: no pre-installed Chromium found under $browsers" >&2
fi
