#!/usr/bin/env bash
# create-sandbox-repo.sh
#
# Creates the BrunoRicci/sandbox-openclaw GitHub repository and populates it
# with a clean snapshot of this repo (credentials stripped).
#
# Prerequisites:
#   - gh CLI authenticated: gh auth login
#   OR
#   - GITHUB_TOKEN environment variable set with a token that has repo scope
#
# Usage:
#   bash create-sandbox-repo.sh
#
set -euo pipefail

REPO_OWNER="BrunoRicci"
REPO_NAME="sandbox-openclaw"
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="/tmp/${REPO_NAME}-init"

echo "==> Creating ${REPO_OWNER}/${REPO_NAME} on GitHub..."

# Create the repo
if command -v gh &>/dev/null; then
  gh repo create "${REPO_OWNER}/${REPO_NAME}" \
    --private \
    --description "OpenClaw sandbox workspace" \
    --confirm 2>/dev/null || true
elif [[ -n "${GITHUB_TOKEN:-}" ]]; then
  curl -s -X POST \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/user/repos" \
    -d "{\"name\":\"${REPO_NAME}\",\"private\":true,\"description\":\"OpenClaw sandbox workspace\"}" \
    | python3 -c "import sys,json; d=json.load(sys.stdin); print('Created:', d.get('full_name','error: '+str(d)))"
else
  echo "ERROR: Need gh CLI (gh auth login) or GITHUB_TOKEN env var."
  exit 1
fi

echo "==> Setting up local clone at ${WORK_DIR}..."
rm -rf "${WORK_DIR}"
mkdir -p "${WORK_DIR}"
cd "${WORK_DIR}"
git init --initial-branch=main
git config user.name "$(git -C "${SOURCE_DIR}" config user.name)"
git config user.email "$(git -C "${SOURCE_DIR}" config user.email)"

echo "==> Copying tracked files from snapshot..."
# Copy all git-tracked files from the source repo
git -C "${SOURCE_DIR}" ls-files | while IFS= read -r file; do
  dir="$(dirname "${file}")"
  mkdir -p "${dir}"
  cp "${SOURCE_DIR}/${file}" "${file}"
done

echo "==> Stripping credentials from state files..."
node - <<'JS'
const fs = require('fs');

function strip(path, fn) {
  if (!fs.existsSync(path)) return;
  try {
    const d = JSON.parse(fs.readFileSync(path));
    fn(d);
    fs.writeFileSync(path, JSON.stringify(d, null, 2) + '\n');
    console.log('  stripped:', path);
  } catch(e) { console.warn('  skip:', path, e.message); }
}

strip('.openclaw-config.json', d => {
  if (d.gateway?.auth) d.gateway.auth.token = '';
});

strip('.openclaw-state/credentials/github-copilot.token.json', d => {
  d.token = ''; d.expiresAt = 0; d.updatedAt = 0;
});

strip('.openclaw-state/identity/device-auth.json', d => {
  d.deviceId = '';
  Object.values(d.tokens || {}).forEach(t => { t.token = ''; });
});

strip('.openclaw-state/identity/device.json', d => {
  d.deviceId = ''; d.publicKeyPem = ''; d.privateKeyPem = '';
});

if (fs.existsSync('.openclaw-state/devices/paired.json')) {
  fs.writeFileSync('.openclaw-state/devices/paired.json', '{}\n');
  console.log('  cleared: .openclaw-state/devices/paired.json');
}
JS

echo "==> Committing initial snapshot..."
git add -A
git commit -m "Initial snapshot from openclawtest (credentials stripped)"

echo "==> Pushing to GitHub..."
if command -v gh &>/dev/null; then
  REMOTE_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}.git"
  git remote add origin "${REMOTE_URL}"
  gh repo set-default "${REPO_OWNER}/${REPO_NAME}"
  git push -u origin main
elif [[ -n "${GITHUB_TOKEN:-}" ]]; then
  git remote add origin "https://${GITHUB_TOKEN}@github.com/${REPO_OWNER}/${REPO_NAME}.git"
  git push -u origin main
fi

echo ""
echo "Done! Repository available at: https://github.com/${REPO_OWNER}/${REPO_NAME}"
echo ""
echo "Next steps:"
echo "  1. cd /tmp/${REPO_NAME}-init"
echo "  2. npm install"
echo "  3. npm run setup   # configure model provider"
echo "  4. npm run gateway # start the gateway"
