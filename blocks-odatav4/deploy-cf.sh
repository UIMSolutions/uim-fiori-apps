#!/bin/sh
# Builds a cflinuxfs4-compatible binary (in Docker, Ubuntu 22.04) and pushes it to Cloud Foundry.
#   ./deploy-cf.sh          -> build + cf push (manifest.yml, no approuter)
#   ./deploy-cf.sh --build  -> build cf-dist/ only (used by mta.yaml)
set -e
cd "$(dirname "$0")"
ROOT=$(cd .. && pwd)
docker build -f ../fiori_elements/backend/Dockerfile.build -t fe-vibe-build ../fiori_elements/backend >/dev/null 2>&1 || true
rm -rf cf-dist && mkdir cf-dist
docker run --rm -v "$ROOT":/repo -w /repo/blocks-odatav4/backend -e DUB_HOME=/tmp/dub fe-vibe-build \
  sh -c 'dub build --compiler=ldc2 -b release --config=server && cp blocks-odatav4 /repo/blocks-odatav4/cf-dist/blocks-odatav4 && chown -R '"$(id -u):$(id -g)"' /repo/blocks-odatav4 .dub 2>/dev/null || true'
cp -r frontend cf-dist/public
rm -rf cf-dist/public/localService
cp manifest.yml cf-dist/manifest.yml
[ "$1" = "--build" ] && exit 0
cd cf-dist && cf push
