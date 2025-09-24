#!/usr/bin/env bash
set -euo pipefail

# robotFarm quickBuild.sh - Download robotFarm archive
# Usage: curl -sSL https://raw.githubusercontent.com/ajakhotia/robotFarm/main/tools/quickBuild.sh | bash
# Usage with version: curl -sSL https://raw.githubusercontent.com/ajakhotia/robotFarm/main/tools/quickBuild.sh | bash -s -- v1.0.0
# Usage with all params: curl -sSL https://raw.githubusercontent.com/ajakhotia/robotFarm/main/tools/quickBuild.sh | bash -s -- v1.0.0 /opt/robotFarm linux-gnu-14 "Eigen3ExternalProject;OpenCVExternalProject"

(
  VERSION="${1:-main}"
  INSTALL_PREFIX="${2:-/opt/robotFarm}"
  TOOLCHAIN="${3:-linux-gnu-default}"
  BUILD_LIST="${4:-}"
  GITHUB_REPO="https://github.com/ajakhotia/robotFarm"

  TMP_DIR=$(mktemp -d)
  pushd "${TMP_DIR}" > /dev/null

  trap 'popd > /dev/null; echo "Cleaning up ${TMP_DIR}..."; rm -rf "${TMP_DIR}"' EXIT
  echo "Working in temporary directory: ${TMP_DIR}"

  (
    SOURCE_TREE="${TMP_DIR}/robotFarm-src"
    mkdir -p "${SOURCE_TREE}"
    trap 'echo "Cleaning up source tree at ${SOURCE_TREE}"; rm -rf "${SOURCE_TREE}"' EXIT

    if [[ "${VERSION}" == "main" ]]; then
      ARCHIVE_URL="${GITHUB_REPO}/archive/refs/heads/main.tar.gz"
    else
      ARCHIVE_URL="${GITHUB_REPO}/archive/refs/tags/${VERSION}.tar.gz"
    fi

    echo "Downloading robotFarm from ${ARCHIVE_URL}"
    curl -fsSL "${ARCHIVE_URL}" | tar -xz -C "${SOURCE_TREE}" --strip-components=1
    echo "robotFarm ${VERSION} downloaded to ${SOURCE_TREE}"

    echo "Installing basic tools & compilers..."
    apt-get update &&                                                                               \
    apt-get install -y --no-install-recommends jq &&                                                \
    apt-get install -y --no-install-recommends                                                      \
      "$(sh "${SOURCE_TREE}/tools/extractDependencies.sh"                                           \
      Basics                                                                                        \
      "${SOURCE_TREE}/systemDependencies.json")" &&                                                 \
    bash "${SOURCE_TREE}/tools/installCMake.sh" &&                                                  \
    bash "${SOURCE_TREE}/tools/apt/addGNUSources.sh" -y &&                                          \
    bash "${SOURCE_TREE}/tools/apt/addLLVMSources.sh" -y &&                                         \
    bash "${SOURCE_TREE}/tools/apt/addNvidiaSources.sh" -y &&                                       \
    apt-get install -y --no-install-recommends                                                      \
      "$(sh "${SOURCE_TREE}/tools/extractDependencies.sh"                                           \
      Compilers                                                                                     \
      "${SOURCE_TREE}/systemDependencies.json")"

    (
      BUILD_TREE="${TMP_DIR}/robotFarm-build"
      mkdir -p "${BUILD_TREE}"
      trap 'echo "Cleaning up build tree at ${BUILD_TREE}"; rm -rf "${BUILD_TREE}"' EXIT

      echo "Configuring robotFarm with CMake..."
      cmake -G Ninja                                                                                \
        -S "${SOURCE_TREE}"                                                                         \
        -B "${BUILD_TREE}"                                                                          \
        -DCMAKE_BUILD_TYPE=Release                                                                  \
        -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}"                                                  \
        -DCMAKE_TOOLCHAIN_FILE="${SOURCE_TREE}/cmake/toolchains/${TOOLCHAIN}.cmake"                 \
        ${BUILD_LIST:+-DROBOT_FARM_REQUESTED_BUILD_LIST=${BUILD_LIST}}

      # shellcheck disable=SC2046
      apt-get install -y --no-install-recommends $(cat "${BUILD_TREE}/systemDependencies.txt")

      cmake --build "${BUILD_TREE}"
    )
  )
)
