#!/usr/bin/env bash
set -euo pipefail

assume_yes=false
if [[ "${1:-}" == "-y" ]]; then
  assume_yes=true
fi

require_confirmation() {
  if $assume_yes; then return 0; fi
  read -r -p "Proceed? [y/N]: " ans
  [[ "${ans,,}" == "y" || "${ans,,}" == "yes" ]]
}

need_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "This script needs root for system changes. Re-running with sudo..."
    exec sudo --preserve-env=assume_yes bash "$0" ${assume_yes:+-y}
  fi
}

# Detect OS
if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
else
  echo "Cannot detect OS (missing /etc/os-release). Aborting."
  exit 1
fi

echo "Detected: ID='${ID:-unknown}', VERSION_CODENAME='${VERSION_CODENAME:-unknown}'"

case "${ID:-}" in
  ubuntu)
    echo
    echo "Plan:"
    echo "  • Add the Ubuntu Toolchain PPA (ubuntu-toolchain-r/test) to access newer GCC/G++."
    echo "  • Update package lists."
    echo
    if ! require_confirmation; then
      echo "Aborted by user."
      exit 0
    fi
    need_root
    if ! grep -qi 'ubuntu-toolchain-r/test' /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
      echo "Adding Ubuntu Toolchain PPA..."
      add-apt-repository -y ppa:ubuntu-toolchain-r/test
    else
      echo "Ubuntu Toolchain PPA already present. Skipping add."
    fi
    echo "Updating package lists..."
    apt-get update -y
    echo "Done. You can now install specific GCC/G++ versions from this PPA."
    ;;

  debian)
    codename="${VERSION_CODENAME:-}"
    if [[ -z "$codename" ]]; then
      echo "Debian codename not found. Aborting."
      exit 1
    fi

    if [[ "$codename" == "sid" || "$codename" == "trixie" ]]; then
      echo
      echo "You're on Debian ${codename}. Backports are unnecessary here for newer GCC."
      echo "Nothing to do."
      exit 0
    fi

    suite="${codename}-backports"
    list_file="/etc/apt/sources.list.d/${suite}.list"

    echo
    echo "Plan:"
    echo "  • Enable Debian backports (${suite}) to access newer GCC/G++ while staying on stable."
    echo "  • Update package lists."
    echo "Target file: ${list_file}"
    echo
    if ! require_confirmation; then
      echo "Aborted by user."
      exit 0
    fi
    need_root
    if [[ ! -f "$list_file" ]]; then
      echo "Adding ${suite} repository..."
      printf "deb http://deb.debian.org/debian %s main\n" "$suite" > "$list_file"
      printf "deb-src http://deb.debian.org/debian %s main\n" "$suite" >> "$list_file"
    else
      echo "${suite} repository already present at ${list_file}. Skipping add."
    fi
    echo "Updating package lists..."
    apt-get update -y
    echo "Done. You can now install specific GCC/G++ versions from backports."
    ;;

  *)
    echo "Unsupported or unrecognized OS ID: '${ID:-}'. Aborting."
    exit 1
    ;;
esac
