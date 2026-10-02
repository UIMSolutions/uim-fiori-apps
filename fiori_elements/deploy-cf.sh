#!/bin/sh
# Builds a cflinuxfs4-compatible binary and pushes the app to Cloud Foundry.
set -e
cd "$(dirname "$0")"
rm -rf cf-dist && mkdir cf-dist
docker build -f backend/Dockerfile.build -t fe-vibe-build backend
id=$(docker create fe-vibe-build)
docker cp "$id":/src/fe-vibe-backend cf-dist/fe-vibe-backend
docker rm "$id" >/dev/null
cp -r webapp cf-dist/webapp
cp manifest.yml cf-dist/manifest.yml
cd cf-dist && cf push
