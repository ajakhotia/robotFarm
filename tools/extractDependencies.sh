#!/bin/sh
# Resolve a dependency entry from systemDependencies.json for the current OS.
# Exact key match only: "<os_id>:<version>"
# - Linux:  os_id = ID from /etc/os-release, version = VERSION_ID
# - macOS:  os_id = macos, version = $(sw_vers -productVersion) (e.g., 14.5.1)
set -eu

# ---------- Exit code constants (from sysexits.h) ----------
EX_OK=0           # successful termination
EX_USAGE=64       # command line usage error
EX_DATAERR=65     # invalid input data
EX_NOINPUT=66     # cannot open input
EX_UNAVAILABLE=69 # service unavailable (e.g. unsupported OS)
EX_SOFTWARE=70    # internal software error
EX_OSERR=71       # system error
EX_CANTCREAT=73   # can't create (file/dir)
EX_NOPERM=77      # permission denied
EX_CONFIG=78      # configuration error

print_usage() {
  printf '%s\n' \
    "Usage: sh installSystemDependencies.sh <GROUP NAME> <PATH TO systemDependencies.json>" \
    "" \
    "Arguments:" \
    "  <GROUP NAME>              Name of the dependency group to query." \
    "  <PATH TO systemDependencies.json>   Path to the JSON file containing dependency definitions." \
    "" \
    "The script detects your OS and version, then looks up an exact key match" \
    "in the JSON (format: '<os_id>:<version>')." \
    "" \
    "Refer to the \"groups\" array in the JSON file to see valid group names" \
    "and the OS keys available for each group." \
    "" \
    "Example:" \
    "  sh installSystemDependencies.sh build ./systemDependencies.json" >&2
}

fail() {
  code="${1}"
  shift
  printf 'Error: %s\n' "$*" >&2
  exit "${code}"
}

require_jq() {
  command -v jq > /dev/null 2>&1 || fail 127 "jq is required but not installed or not in PATH."
}

require_readable_file() {
  path="${1}"
  [ -r "${path}" ] || fail ${EX_NOINPUT} "cannot read file: ${path}"
}

# Detect OS into OS_ID and OS_VERSION (exact values used for key)
detect_os() {
  uname_s="$(uname -s 2> /dev/null || echo unknown)"
  case "${uname_s}" in
    Linux)
      if [ -r /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        OS_ID="${ID:-linux}"
        OS_VERSION="${VERSION_ID:-}"
        [ -n "${OS_VERSION}" ] || fail ${EX_SOFTWARE} "/etc/os-release missing VERSION_ID."
      else
        fail ${EX_UNAVAILABLE} "/etc/os-release not found; cannot detect Linux distribution."
      fi
      ;;
    Darwin)
      OS_ID="macos"
      if command -v sw_vers > /dev/null 2>&1; then
        OS_VERSION="$(sw_vers -productVersion | tr -d '\r')"
      else
        fail ${EX_UNAVAILABLE} "sw_vers not available; cannot detect macOS version."
      fi
      [ -n "${OS_VERSION}" ] || fail ${EX_SOFTWARE} "could not determine macOS version."
      ;;
    *)
      fail ${EX_UNAVAILABLE} "unsupported operating system: ${uname_s}"
      ;;
  esac
}

# ---------- Main ----------

GROUP_NAME="${1:-}"
DEPENDENCIES_JSON_PATH="${2:-}"

if [ -z "${GROUP_NAME}" ] || [ -z "${DEPENDENCIES_JSON_PATH}" ]; then
  print_usage
  exit ${EX_USAGE}
fi

require_jq
require_readable_file "${DEPENDENCIES_JSON_PATH}"
detect_os

OS_KEY="${OS_ID}:${OS_VERSION}"

# Ensure the group exists
if ! jq -e --arg GRP "${GROUP_NAME}" '.groups[] | select(.group == $GRP)' "${DEPENDENCIES_JSON_PATH}" > /dev/null; then
  printf 'No system dependencies specified for "%s".\n' "${GROUP_NAME}" >&2
  exit ${EX_OK}
fi

# Exact lookup
VALUE="$(jq -r \
  --arg GRP "${GROUP_NAME}" \
  --arg KEY "${OS_KEY}" \
  '.groups[] | select(.group == $GRP) | .[$KEY] // empty' \
  "${DEPENDENCIES_JSON_PATH}")"

if [ -z "${VALUE}" ] || [ "${VALUE}" = "null" ]; then
  printf 'Error: no exact entry for key "%s" in group "%s".\n' "${OS_KEY}" "${GROUP_NAME}" >&2
  printf 'Known keys for this group:\n' >&2
  jq -r --arg GRP "${GROUP_NAME}" '.groups[] | select(.group == $GRP) | keys[]' "${DEPENDENCIES_JSON_PATH}" >&2
  exit ${EX_DATAERR}
fi

# Print exactly (no extra newline)
printf '%s' "${VALUE}"
