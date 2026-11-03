#!/bin/sh
# Builds a cflinuxfs4-compatible binary (in Docker, Ubuntu 22.04) and pushes to Cloud Foundry.
set -e
cd "$(dirname "$0")"
ROOT=$(cd .. && pwd)
docker build -f ../fiori_elements/backend/Dockerfile.build -t fe-vibe-build ../fiori_elements/backend >/dev/null 2>&1 || true
rm -rf cf-dist && mkdir cf-dist
docker run --rm -v "$ROOT":/repo -w /repo/blocks-odatav4/backend -e DUB_HOME=/tmp/dub fe-vibe-build \
  sh -c 'dub build --compiler=ldc2 -b release && cp project /repo/blocks-odatav4/cf-dist/project && chown -R '"$(id -u):$(id -g)"' /repo/blocks-odatav4 .dub 2>/dev/null || true'
cp -r backend/public cf-dist/public
cp manifest.yml cf-dist/manifest.yml
cd cf-dist && cf push
