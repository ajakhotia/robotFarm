#!/usr/bin/env bash
set -e

DEFAULT_CMAKE_VERSION="4.1.0"
DEFAULT_INSTALL_PREFIX_BASE="/opt"
SYMLINK_DIR="/usr/local/bin"

CMAKE_VERSION="${DEFAULT_CMAKE_VERSION}"
INSTALL_PREFIX=""

if [[ $# -ge 1 ]]; then
  CMAKE_VERSION="${1}"
  shift
fi

if [[ $# -ge 1 ]]; then
  INSTALL_PREFIX="${1}"
  shift
else
  INSTALL_PREFIX="${DEFAULT_INSTALL_PREFIX_BASE}/cmake-${CMAKE_VERSION}"
fi

SYSTEM_ARCH="$(uname -m)"
INSTALLER_NAME="cmake-${CMAKE_VERSION}-linux"
BASE_URL="https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}"

case "${SYSTEM_ARCH}" in
  x86_64)   INSTALLER_NAME="${INSTALLER_NAME}-x86_64.sh" ;;
  aarch64|arm64) INSTALLER_NAME="${INSTALLER_NAME}-aarch64.sh" ;;
  *) echo "Unsupported architecture: ${SYSTEM_ARCH}"; exit 1 ;;
esac

curl -LO "${BASE_URL}/${INSTALLER_NAME}"
mkdir -p "${INSTALL_PREFIX}"

bash "${INSTALLER_NAME}" --skip-license --prefix="${INSTALL_PREFIX}"
rm -f "${INSTALLER_NAME}"

for tool in cmake ctest cpack; do
  ln -sfn "${INSTALL_PREFIX}/bin/${tool}" "${SYMLINK_DIR}/${tool}"
done

echo "Installed $(cmake --version)"
