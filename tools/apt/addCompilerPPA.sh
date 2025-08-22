#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------------------------
# Helper to check required commands exist
# -------------------------------------------------------------------
require_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "Missing: $1" >&2; exit 1; }; }

require_cmd curl
require_cmd grep
require_cmd sed
require_cmd tee
require_cmd lsb_release || true

# -------------------------------------------------------------------
# Detect operating system and version from /etc/os-release
# -------------------------------------------------------------------
if [[ -r /etc/os-release ]]; then
  . /etc/os-release
else
  echo "Cannot read /etc/os-release to detect OS info." >&2
  exit 1
fi

# Normalize values
OS_NAME="${ID,,}"                # e.g. "ubuntu" or "debian"
OS_VERSION="${VERSION_ID:-}"     # e.g. "24.04" or "12"
OS_VERSION_NO_DOT="$(echo "${OS_VERSION}" | tr -d '.')"
OS_CODENAME="${VERSION_CODENAME:-}"

# Fallback: if codename missing, try lsb_release
if [[ -z "$OS_CODENAME" ]]; then
  OS_CODENAME="$(lsb_release -sc 2>/dev/null || true)"
fi

if [[ -z "$OS_CODENAME" || -z "$OS_VERSION_NO_DOT" ]]; then
  echo "Could not determine codename or version." >&2
  exit 1
fi

echo "Detected OS: ${OS_NAME} ${OS_VERSION} (${OS_CODENAME})"

# -------------------------------------------------------------------
# Prepare keyrings directory
# -------------------------------------------------------------------
mkdir -p /etc/apt/keyrings
chmod 0755 /etc/apt/keyrings

# -------------------------------------------------------------------
# 1) LLVM / Clang
# -------------------------------------------------------------------
LLVM_KEY=/etc/apt/keyrings/llvm.asc
LLVM_LIST=/etc/apt/sources.list.d/llvm-toolchain.list

echo "Adding LLVM repo for ${OS_CODENAME}…"
curl -fsSL https://apt.llvm.org/llvm-snapshot.gpg.key > "$LLVM_KEY"
chmod 0644 "$LLVM_KEY"

cat <<EOF > "$LLVM_LIST"
deb [signed-by=$LLVM_KEY] http://apt.llvm.org/${OS_CODENAME}/ llvm-toolchain-${OS_CODENAME} main
# To pin a specific major version, uncomment:
# deb [signed-by=$LLVM_KEY] http://apt.llvm.org/${OS_CODENAME}/ llvm-toolchain-${OS_CODENAME}-<MAJOR> main
EOF

# -------------------------------------------------------------------
# 2) GCC
# -------------------------------------------------------------------
if [[ "$OS_NAME" == "ubuntu" ]]; then
  echo "Adding Ubuntu Toolchain PPA for newer GCC…"
  apt-get update -qq
  apt-get install -y --no-install-recommends software-properties-common
  add-apt-repository -y ppa:ubuntu-toolchain-r/test

elif [[ "$OS_NAME" == "debian" ]]; then
  echo "Enabling Debian backports for newer GCC…"
  DEB_LIST=/etc/apt/sources.list.d/debian-backports.list
  cat <<EOF > "$DEB_LIST"
deb http://deb.debian.org/debian ${OS_CODENAME}-backports main contrib non-free non-free-firmware
EOF
else
  echo "Skipping GCC repo setup (unsupported OS: $OS_NAME)."
fi

# -------------------------------------------------------------------
# 3) NVIDIA CUDA repo
# -------------------------------------------------------------------
DIST_TAG="${OS_NAME}${OS_VERSION_NO_DOT}"
CUDA_KEY_DEB="cuda-keyring_1.1-1_all.deb"
CUDA_TMP="/tmp/${CUDA_KEY_DEB}"

echo "Adding NVIDIA CUDA repo for ${DIST_TAG}…"
CUDA_URL="https://developer.download.nvidia.com/compute/cuda/repos/${DIST_TAG}/x86_64/${CUDA_KEY_DEB}"

if curl -fsSLI "$CUDA_URL" >/dev/null; then
  curl -fsSL "$CUDA_URL" -o "$CUDA_TMP"
  apt-get install -y "$CUDA_TMP" || dpkg -i "$CUDA_TMP"
  rm -f "$CUDA_TMP"
else
  echo "WARN: Could not fetch ${CUDA_URL}. Falling back to manual key setup…"
  NV_KEY=/etc/apt/keyrings/cuda-archive-keyring.gpg
  curl -fsSL "https://developer.download.nvidia.com/compute/cuda/repos/${DIST_TAG}/x86_64/cuda-archive-keyring.gpg" > "$NV_KEY"
  chmod 0644 "$NV_KEY"
  NV_LIST=/etc/apt/sources.list.d/cuda.list
  cat <<EOF > "$NV_LIST"
deb [signed-by=$NV_KEY] https://developer.download.nvidia.com/compute/cuda/repos/${DIST_TAG}/x86_64/ /
EOF
fi

# -------------------------------------------------------------------
# Finish up
# -------------------------------------------------------------------
echo "Updating package lists…"
apt-get update

echo "Done. Repositories added:"
echo "  - LLVM:   $(cat "$LLVM_LIST" | sed 's/^/    /')"
if [[ "$OS_NAME" == "ubuntu" ]]; then
  echo "  - GCC:    Ubuntu Toolchain PPA enabled"
elif [[ "$OS_NAME" == "debian" ]]; then
  echo "  - GCC:    Debian backports enabled"
fi
echo "  - NVIDIA: CUDA repository added"
