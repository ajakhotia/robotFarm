#!/usr/bin/env bash

echo "${1}" | sed -E 's/([a-z0-9])([A-Z])/\1-\L\2/g' | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9/]+/-/g'
