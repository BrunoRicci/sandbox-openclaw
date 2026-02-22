#!/bin/bash
# Starts the OpenClaw gateway as a detached background process.
# Called by devcontainer postStartCommand on every container start.

# postStartCommand runs with a minimal PATH — node won't be found without this.
# /usr/local/share/nvm is the canonical node location in devcontainers/javascript-node images.
export PATH="/usr/local/share/nvm/current/bin:/usr/local/bin:$PATH"

cd "$(dirname "$0")/.."

mkdir -p /tmp/openclaw

nohup ./node_modules/.bin/openclaw gateway --force >> /tmp/openclaw-gateway.log 2>&1 &
disown $!
