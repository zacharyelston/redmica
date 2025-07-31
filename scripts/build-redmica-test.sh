#!/bin/bash
# Build and tag a custom Redmica Docker image for testing (with RAG/LDAP patches)
set -e
cd "$(dirname "$0")/.."

IMAGE_NAME="redmica-custom:test"

echo "[INFO] Building custom Redmica image: $IMAGE_NAME"
docker build -t "$IMAGE_NAME" .

echo "[INFO] Build complete. To run:"
echo "  docker run --rm -p 3000:3000 $IMAGE_NAME"
