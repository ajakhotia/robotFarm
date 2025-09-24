#!/usr/bin/env bash
set -euo pipefail

# robotFarm quickBuild.sh - Download robotFarm archive
# Usage: curl -sSL https://raw.githubusercontent.com/ajakhotia/robotFarm/main/tools/quickBuild.sh | bash
# Usage with version: curl -sSL https://raw.githubusercontent.com/ajakhotia/robotFarm/main/tools/quickBuild.sh | bash -s -- v1.0.0

(
  VERSION="${1:-main}"
  GITHUB_REPO="ajakhotia/robotFarm"

  TMP_DIR=$(mktemp -d)
  pushd "${TMP_DIR}" > /dev/null

  trap 'popd > /dev/null; echo "Cleaning up ${TMP_DIR}..."; rm -rf "${TMP_DIR}"' EXIT
  echo "Working in temporary directory: ${TMP_DIR}"

  (
    SRC_DIR="robotFarm-src"
    mkdir -p "${SRC_DIR}"
    trap 'echo "Cleaning up source directory..."; rm -rf "${SRC_DIR}"' EXIT
    echo "Downloading robotFarm ${VERSION}..."

    if [[ "${VERSION}" == "main" ]]; then
      ARCHIVE_URL="https://github.com/${GITHUB_REPO}/archive/refs/heads/main.tar.gz"
    else
      ARCHIVE_URL="https://github.com/${GITHUB_REPO}/archive/refs/tags/${VERSION}.tar.gz"
    fi

    curl -fsSL "${ARCHIVE_URL}" | tar -xz -C "${SRC_DIR}" --strip-components=1
    echo "robotFarm ${VERSION} downloaded to ${TMP_DIR}/${SRC_DIR}"
  )
)
