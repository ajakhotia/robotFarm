#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------------------------
# Add upstream repos for latest compilers (run as root; no sudo)
# - LLVM/Clang  : apt.llvm.org
# - CUDA (nvcc) : NVIDIA CUDA repo
# - GNU (GCC)   : Ubuntu Toolchain PPA (Ubuntu only)
# -------------------------------------------------------------------

require_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1" >&2; exit 1; }; }
require_cmd awk
require_cmd tr
require_cmd dpkg
require_cmd apt-get
require_cmd gpg
require_cmd curl
command -v add-apt-repository >/dev/null 2>&1 || true

# Detect OS
if [[ -r /etc/os-release ]]; then
  . /etc/os-release
else
  echo "Cannot detect OS: /etc/os-release not readable." >&2
  exit 1
fi

OS_ID="${ID,,}"                          # ubuntu|debian
OS_VERSION_ID="${VERSION_ID:-}"          # "24.04" | "12"
OS_CODENAME="${VERSION_CODENAME:-}"
if [[ -z "${OS_CODENAME}" ]] && command -v lsb_release >/dev/null 2>&1; then
  OS_CODENAME="$(lsb_release -sc || true)"
fi

ARCH_DEB="$(dpkg --print-architecture)"  # amd64 | arm64 | ...
# Map to NVIDIA's directory naming
case "${ARCH_DEB}" in
  amd64) NVIDIA_ARCH_DIR="x86_64" ;;
  arm64) NVIDIA_ARCH_DIR="sbsa" ;;      # NVIDIA uses 'sbsa' for AArch64 servers
  *)     NVIDIA_ARCH_DIR="${ARCH_DEB}" ;;
esac

case "${OS_ID}" in
  ubuntu|debian) ;;
  *) echo "Supported distros: Ubuntu/Debian. Detected: ${OS_ID}"; exit 1 ;;
esac

if [[ -z "${OS_CODENAME}" ]]; then
  echo "Could not determine codename (e.g., noble, jammy, bookworm). Aborting." >&2
  exit 1
fi

# Numeric for Ubuntu (e.g., 24.04 -> 2404); major for Debian (e.g., 12)
if [[ "${OS_ID}" == "ubuntu" ]]; then
  OS_NUMERIC="$(echo "${OS_VERSION_ID}" | tr -d '.')"
  NVIDIA_REPO_SEG="ubuntu${OS_NUMERIC}"
else
  DEB_MAJOR="$(echo "${OS_VERSION_ID}" | awk -F. '{print $1}')"
  NVIDIA_REPO_SEG="debian${DEB_MAJOR}"
fi

# Plan entries
declare -a PLAN_LABELS=()
declare -a PLAN_ACTIONS=()   # repo:<file>:<line> or ppa:<ppa>
declare -a PLAN_KEYS=()      # key:<dest>:<url>

# LLVM (apt.llvm.org)
LLVM_KEY_DST="/usr/share/keyrings/llvm-archive-keyring.gpg"
LLVM_KEY_URL="https://apt.llvm.org/llvm-snapshot.gpg.key"
LLVM_LIST_FILE="/etc/apt/sources.list.d/llvm-official.list"
LLVM_DEB_LINE="deb [signed-by=${LLVM_KEY_DST}] http://apt.llvm.org/${OS_CODENAME}/ llvm-toolchain-${OS_CODENAME} main"

PLAN_LABELS+=("LLVM/Clang (apt.llvm.org)")
PLAN_KEYS+=("key:${LLVM_KEY_DST}:${LLVM_KEY_URL}")
PLAN_ACTIONS+=("repo:${LLVM_LIST_FILE}:${LLVM_DEB_LINE}")

# NVIDIA CUDA (official)
NVIDIA_KEY_DST="/usr/share/keyrings/nvidia-cuda-archive-keyring.gpg"
NVIDIA_REPO_URL="https://developer.download.nvidia.com/compute/cuda/repos/${NVIDIA_REPO_SEG}/${NVIDIA_ARCH_DIR}/"
NVIDIA_KEY_URL="${NVIDIA_REPO_URL}3bf863cc.pub"
NVIDIA_LIST_FILE="/etc/apt/sources.list.d/cuda-nvidia-official.list"
NVIDIA_DEB_LINE="deb [signed-by=${NVIDIA_KEY_DST}] ${NVIDIA_REPO_URL} /"

PLAN_LABELS+=("NVIDIA CUDA (official)")
PLAN_KEYS+=("key:${NVIDIA_KEY_DST}:${NVIDIA_KEY_URL}")
PLAN_ACTIONS+=("repo:${NVIDIA_LIST_FILE}:${NVIDIA_DEB_LINE}")

# GNU (GCC) via Ubuntu Toolchain PPA on Ubuntu
if [[ "${OS_ID}" == "ubuntu" ]]; then
  PLAN_LABELS+=("GNU (GCC) via Ubuntu Toolchain PPA")
  PLAN_ACTIONS+=("ppa:ppa:ubuntu-toolchain-r/test")  # placeholder to keep format consistent
fi

# Show plan
echo "Detected: ${PRETTY_NAME:-$OS_ID $OS_VERSION_ID} (${OS_CODENAME}), arch: ${ARCH_DEB}"
echo
echo "The following sources will be configured:"
for label in "${PLAN_LABELS[@]}"; do
  echo "  - ${label}"
done
echo

read -r -p "Proceed with adding these sources? [y/N]: " REPLY
case "${REPLY,,}" in
  y|yes) ;;
  *) echo "Aborted. No changes made."; exit 0 ;;
esac

# Fetch & install keys
for key_spec in "${PLAN_KEYS[@]}"; do
  IFS=':' read -r kind dest url <<< "${key_spec}"
  [[ "${kind}" == "key" ]] || continue
  echo "Fetching key: ${url}"
  curl -fsSL "${url}" | gpg --dearmor > "${dest}.tmp"
  mv "${dest}.tmp" "${dest}"
  chmod 0644 "${dest}"
done

# Write repo files / add PPA
for action in "${PLAN_ACTIONS[@]}"; do
  IFS=':' read -r kind a b <<< "${action}"
  case "${kind}" in
    repo)
      list_file="${a}"
      deb_line="${b}"
      echo "Writing ${list_file}"
      printf "%s\n" "${deb_line}" > "${list_file}.tmp"
      mv "${list_file}.tmp" "${list_file}"
      chmod 0644 "${list_file}"
      ;;
    ppa)
      # FIX: ensure we pass 'ppa:ubuntu-toolchain-r/test' (not 'ubuntu-toolchain-r/test')
      ppa_name="${b:-$a}"
      # remove accidental 'ppa:' prefix from 'a' if present, then add exactly one 'ppa:' prefix
      ppa_name="${ppa_name#ppa:}"
      ppa_name="ppa:${ppa_name}"
      if [[ "${OS_ID}" != "ubuntu" ]]; then
        echo "Skipping PPA (${ppa_name}) on non-Ubuntu."
      elif ! command -v add-apt-repository >/dev/null 2>&1; then
        echo "Skipping PPA (${ppa_name}) because add-apt-repository is not available."
      else
        echo "Adding PPA: ${ppa_name}"
        add-apt-repository -y "${ppa_name}"
      fi
      ;;
    *)
      echo "Unknown action kind: ${kind}" >&2
      exit 1
      ;;
  esac
done

echo "Updating package lists..."
apt-get update -y

echo "Done."
if [[ "${OS_ID}" == "debian" ]]; then
  cat <<'NOTE'

Note on GNU (GCC) for Debian:
  There is no official "GNU PPA". Newer GCC versions on Debian typically come
  from testing/unstable or backports. This script leaves your release lines
  unchanged to avoid destabilizing your system.
NOTE
fi
