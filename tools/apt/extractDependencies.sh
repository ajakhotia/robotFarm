#!/bin/sh

SCRIPT_DIR=$(dirname "${0}")

GROUP_NAME="${1}"
OS_NAME="$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"'):$(grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"')"

display_usage() {
    echo "sh installSystemDependencies.sh <GROUP NAME>"
    echo "Refer to \"groups\" sub-structure of the sibling file \"systemDependencies.json\" " \
         "for a list of valid options."
}

if [ -z "${GROUP_NAME}" ]; then
    echo "No group name has been provided."
    display_usage
    exit 1
fi

jq -j                                                   \
    --arg GRP "$GROUP_NAME"                             \
    --arg OS "$OS_NAME"                                 \
    '.groups[] | select(.group == $GRP) | .[$OS]'       \
    "${SCRIPT_DIR}"/systemDependencies.json
