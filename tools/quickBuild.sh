#!/usr/bin/env bash
set -euo pipefail

# robotFarm quickBuild.sh - Download robotFarm archive
# Usage: curl -sSL https://raw.githubusercontent.com/ajakhotia/robotFarm/main/tools/quickBuild.sh | bash
# Usage with version: curl -sSL https://raw.githubusercontent.com/ajakhotia/robotFarm/main/tools/quickBuild.sh | bash -s -- v1.0.0

(
  VERSION="${1:-main}"
  GITHUB_REPO="ajakhotia/robotFarm"
  TMP_DIR=$(mktemp -d)
  SRC_DIR="${TMP_DIR}/robotFarm-src"

  cleanup() {
    echo "Cleaning up ${TMP_DIR}..."
    rm -rf "${TMP_DIR}"
  }

  trap cleanup EXIT

  echo "Downloading robotFarm ${VERSION}..."

  if [[ "${VERSION}" == "main" ]]; then
    ARCHIVE_URL="https://github.com/${GITHUB_REPO}/archive/refs/heads/main.tar.gz"
  else
    ARCHIVE_URL="https://github.com/${GITHUB_REPO}/archive/refs/tags/${VERSION}.tar.gz"
  fi

  mkdir -p "${SRC_DIR}"
  curl -fsSL "${ARCHIVE_URL}" | tar -xz -C "${SRC_DIR}" --strip-components=1

  echo "robotFarm ${VERSION} downloaded to ${SRC_DIR}"
)