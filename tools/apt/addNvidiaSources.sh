#!/usr/bin/env bash
set -euo pipefail

assume_yes=false
if [[ "${1:-}" == "-y" ]]; then
  assume_yes=true
fi

confirm() {
  if $assume_yes; then return 0; fi
  read -r -p "Proceed? [y/N]: " ans
  [[ "${ans,,}" == "y" || "${ans,,}" == "yes" ]]
}

need_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "Elevating privileges with sudo..."
    exec sudo --preserve-env=assume_yes bash "$0" ${assume_yes:+-y}
  fi
}

# OS detection
if [[ -r /etc/os-release ]]; then . /etc/os-release; else
  echo "Cannot detect OS (missing /etc/os-release)."; exit 1; fi

id="${ID:-}"; codename="${VERSION_CODENAME:-}"
echo "Detected: ID='${id}', VERSION_CODENAME='${codename}'"

# Map to NVIDIA repo distro segment
repo_distro=""
case "$id" in
  ubuntu)
    case "$codename" in
      focal) repo_distro="ubuntu2004" ;;
      jammy) repo_distro="ubuntu2204" ;;
      noble) repo_distro="ubuntu2404" ;;
      *) echo "Unsupported Ubuntu codename '${codename}'. Aborting."; exit 1 ;;
    esac
    ;;
  debian)
    case "$codename" in
      bullseye) repo_distro="debian11" ;;
      bookworm) repo_distro="debian12" ;;
      *) echo "Unsupported Debian codename '${codename}'. Aborting."; exit 1 ;;
    esac
    ;;
  *)
    echo "Unsupported OS ID '${id}'. Aborting."
    exit 1
    ;;
esac

# NVIDIA repo URLs (x86_64)
repo_base="https://developer.download.nvidia.com/compute/cuda/repos/${repo_distro}/x86_64"
keyring_url="${repo_base}/cuda-archive-keyring.gpg"
list_file="/etc/apt/sources.list.d/nvidia-cuda-${repo_distro}.list"
keyring_dest="/usr/share/keyrings/nvidia-cuda-archive-keyring.gpg"

echo
echo "Plan:"
echo "  • Install NVIDIA CUDA repository keyring from:"
echo "      ${keyring_url}"
echo "  • Add APT source to:"
echo "      ${list_file}"
echo "  • Update package lists"
echo
if ! confirm; then echo "Aborted by user."; exit 0; fi

need_root

# Create keyrings dir if missing
mkdir -p "$(dirname "$keyring_dest")"

# Install/refresh keyring
echo "Fetching NVIDIA CUDA keyring..."
curl -fsSL "$keyring_url" -o "$keyring_dest"

# Add/refresh APT source
repo_line="deb [signed-by=${keyring_dest}] ${repo_base} /"
if [[ ! -f "$list_file" ]]; then
  echo "Adding CUDA APT source to ${list_file}..."
  printf "%s\n" "$repo_line" > "$list_file"
else
  if grep -Fxq "$repo_line" "$list_file"; then
    echo "CUDA APT source already present."
  else
    echo "Updating existing CUDA APT source at ${list_file}..."
    printf "%s\n" "$repo_line" > "$list_file"
  fi
fi

echo "Updating package lists..."
apt-get update -y

echo "Done."
echo
echo "Next steps (examples, not executed):"
echo "  • List CUDA toolkits:      apt-cache search '^cuda-toolkit-[0-9]+'"
echo "  • Install a toolkit:       sudo apt install cuda-toolkit-12-6"
echo "  • Install only compilers:  sudo apt install nvidia-cuda-toolkit"
echo
echo "Note: This script targets x86_64. On non-amd64 systems, the repo path may differ."
