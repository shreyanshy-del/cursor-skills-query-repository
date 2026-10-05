#!/usr/bin/env bash
set -euo pipefail
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_DIR"
REMOTE_URL="https://github.com/shreyanshy-del/cr-analytics.git"
if ! git remote get-url origin >/dev/null 2>&1; then
  git remote add origin "$REMOTE_URL"
else
  git remote set-url origin "$REMOTE_URL"
fi
# Ensure main exists on remote for PR base
git push -u origin main
git push -u origin cursor/cr-analyser-full-8e9b
echo "Pushed. Open PR: cursor/cr-analyser-full-8e9b → main"
