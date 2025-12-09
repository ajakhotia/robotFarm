#!/usr/bin/env bash
set -euo pipefail

# robotFarm quickBuild.sh - Download robotFarm archive
# Usage: curl -sSL https://raw.githubusercontent.com/ajakhotia/robotFarm/main/tools/quickBuild.sh | bash
# Usage with named params: curl -sSL https://raw.githubusercontent.com/ajakhotia/robotFarm/main/tools/quickBuild.sh | bash -s -- --version v1.0.0
# Usage with all params: curl -sSL https://raw.githubusercontent.com/ajakhotia/robotFarm/main/tools/quickBuild.sh | bash -s -- --version v1.0.0 --prefix /opt/robotFarm --toolchain linux-gnu-14 --build-list "Eigen3ExternalProject;OpenCVExternalProject"

(
  # Default values
  VERSION="main"
  INSTALL_PREFIX="/opt/robotFarm"
  TOOLCHAIN="linux-gnu-default"
  BUILD_LIST=""

  # Simple argument parsing
  while [[ $# -gt 0 ]]; do
    case $1 in
      -v|--version) VERSION="$2"; shift 2 ;;
      -p|--prefix) INSTALL_PREFIX="$2"; shift 2 ;;
      -t|--toolchain) TOOLCHAIN="$2"; shift 2 ;;
      -b|--build-list) BUILD_LIST="$2"; shift 2 ;;
      -h|--help)
        echo "Usage: $(basename "$0") [options]"
        echo "Options:"
        echo "  -v, --version VERSION      Version to download (default: main)"
        echo "  -p, --prefix PREFIX        Install prefix (default: /opt/robotFarm)"
        echo "  -t, --toolchain TOOLCHAIN  Toolchain to use (default: linux-gnu-default)"
        echo "  -b, --build-list LIST      Semicolon-separated list of libraries to build (default: all)"
        echo "  -h, --help                 Show this help message"
        exit 0
        ;;
      *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
  done
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
    sh "${SOURCE_TREE}/tools/extractDependencies.sh" Basics "${SOURCE_TREE}/systemDependencies.json" | xargs apt-get install -y --no-install-recommends && \
    bash "${SOURCE_TREE}/tools/installCMake.sh" &&                                                  \
    bash "${SOURCE_TREE}/tools/apt/addGNUSources.sh" -y &&                                          \
    bash "${SOURCE_TREE}/tools/apt/addLLVMSources.sh" -y &&                                         \
    bash "${SOURCE_TREE}/tools/apt/addNvidiaSources.sh" -y &&                                       \
    sh "${SOURCE_TREE}/tools/extractDependencies.sh" Compilers "${SOURCE_TREE}/systemDependencies.json" | xargs apt-get install -y --no-install-recommends

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
