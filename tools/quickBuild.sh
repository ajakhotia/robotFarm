#!/usr/bin/env bash
# robotFarm quickBuild.sh - Build and install libraries using robotFarm quickly.
# Usage:
#   curl -sSL https://raw.githubusercontent.com/ajakhotia/robotFarm/main/tools/quickBuild.sh | bash
# Usage with named params:
#   curl -sSL https://raw.githubusercontent.com/ajakhotia/robotFarm/main/tools/quickBuild.sh | bash -s -- --version v2.0.0
# Usage with all params:
#   curl -sSL https://raw.githubusercontent.com/ajakhotia/robotFarm/main/tools/quickBuild.sh | bash -s -- --version v2.0.0 --prefix /opt/robotFarm --toolchain linux-gnu-14 --build-list "Eigen3ExternalProject;OpenCVExternalProject"

(
  set -euo pipefail

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
        echo "  -v, --version VERSION      Tag or branch to check out (default: main)"
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
  trap 'echo "Cleaning up ${TMP_DIR}..."; rm -rf "${TMP_DIR}"' EXIT
  echo "Working in temporary directory: ${TMP_DIR}"

  SOURCE_TREE="${TMP_DIR}/robotFarm-src"
  BUILD_TREE="${TMP_DIR}/robotFarm-build"

  echo "Installing prerequisites for shallow checkout..."
  apt-get update
  apt-get install -y --no-install-recommends ca-certificates git jq

  echo "Shallow-cloning robotFarm ${VERSION} from ${GITHUB_REPO}"
  git clone --depth 1 --branch "${VERSION}" "${GITHUB_REPO}.git" "${SOURCE_TREE}"

  echo "Shallow-fetching top-level submodules (no recursion)"
  git -C "${SOURCE_TREE}" submodule update --init --depth 1
  echo "robotFarm ${VERSION} checked out to ${SOURCE_TREE}"

  echo "Installing basic tools & compilers..."

  sh "${SOURCE_TREE}/external/infraCommons/tools/extractDependencies.sh"        \
      Basics "${SOURCE_TREE}/systemDependencies.json"                           \
      | xargs -r apt-get install -y --no-install-recommends

  bash "${SOURCE_TREE}/external/infraCommons/tools/installCMake.sh"
  bash "${SOURCE_TREE}/external/infraCommons/tools/apt/addGNUSources.sh" -y
  bash "${SOURCE_TREE}/external/infraCommons/tools/apt/addLLVMSources.sh" -y
  bash "${SOURCE_TREE}/external/infraCommons/tools/apt/addNvidiaSources.sh" -y

  sh "${SOURCE_TREE}/external/infraCommons/tools/extractDependencies.sh"        \
      Compilers "${SOURCE_TREE}/systemDependencies.json"                        \
      | xargs -r apt-get install -y --no-install-recommends

  mkdir -p "${BUILD_TREE}"

  echo "Configuring robotFarm with CMake..."
  cmake -G Ninja                                                                                      \
    -S "${SOURCE_TREE}"                                                                               \
    -B "${BUILD_TREE}"                                                                                \
    -DCMAKE_BUILD_TYPE=Release                                                                        \
    -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}"                                                        \
    -DCMAKE_TOOLCHAIN_FILE="${SOURCE_TREE}/external/infraCommons/cmake/toolchains/${TOOLCHAIN}.cmake" \
    ${BUILD_LIST:+-DROBOT_FARM_REQUESTED_BUILD_LIST=${BUILD_LIST}}

  # shellcheck disable=SC2046
  apt-get install -y --no-install-recommends $(cat "${BUILD_TREE}/systemDependencies.txt")

  cmake --build "${BUILD_TREE}"
)
