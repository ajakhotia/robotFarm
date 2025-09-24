#!/usr/bin/env bash
set -euo pipefail

# robotFarm quickBuild.sh - Download robotFarm archive
# Usage: curl -sSL https://raw.githubusercontent.com/ajakhotia/robotFarm/main/tools/quickBuild.sh | bash
# Usage with version: curl -sSL https://raw.githubusercontent.com/ajakhotia/robotFarm/main/tools/quickBuild.sh | bash -s -- v1.0.0

VERSION="${1:-main}"
GITHUB_REPO="ajakhotia/robotFarm"
DEST_DIR="/tmp/robotFarm"

echo "Downloading robotFarm ${VERSION}..."

if [[ "${VERSION}" == "main" ]]; then
  ARCHIVE_URL="https://github.com/${GITHUB_REPO}/archive/refs/heads/main.tar.gz"
  EXTRACT_DIR="robotFarm-main"
else
  ARCHIVE_URL="https://github.com/${GITHUB_REPO}/archive/refs/tags/${VERSION}.tar.gz"
  EXTRACT_DIR="robotFarm-${VERSION#v}"
fi

rm -rf "${DEST_DIR}"
mkdir -p "${DEST_DIR}"

curl -fsSL "${ARCHIVE_URL}" | tar -xz -C "${DEST_DIR}" --strip-components=1

echo "robotFarm ${VERSION} downloaded to ${DEST_DIR}"