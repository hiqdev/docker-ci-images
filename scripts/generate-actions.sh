#!/bin/bash

EVENT_NAME=$1
CHANGED_DIRS=$2
PERIODIC_UPDATES_MIN_VERSION=$3
BUILD_MIN_VERSION=$4

# Helper: check if directory has changed
# Usage: has_changes "php-nginx/8.2/"
has_changes() {
    local target_dir=$1
    local count
    count=$(echo "$CHANGED_DIRS" | jq ".[] | select(. | contains(\"$target_dir\"))" | wc -l)
    if [[ $count -gt 0 ]]; then
        return 0  # true
    else
        return 1  # false
    fi
}

# --- Helper: list version subdirectories for given base directory ---
# Usage: get_versions "php-nginx"
get_versions() {
    local dir=$1
    (cd "$dir" && ls -d */ 2>/dev/null | cut -f1 -d'/')
}

# Build JSON array
items=()

# =========================
# PHP IMAGES
# =========================
for VERSION in $(get_versions "php-nginx"); do
    # Do not include versions that are not supported by periodic updates
    if [[ $EVENT_NAME == 'schedule' ]] && [[ $VERSION < $PERIODIC_UPDATES_MIN_VERSION ]]; then
        continue
    fi

    # Do not include legacy versions
    if [[ $VERSION < $BUILD_MIN_VERSION ]]; then
        continue
    fi

    # On pull requests, if there are no changes in that version folder, skip it
    if [[ $EVENT_NAME == 'pull_request' ]] && ! has_changes "php-nginx/$VERSION/"; then
        continue
    fi

    # Append to array
    items+=("$(jq -nc --arg type php-nginx --arg version "$VERSION" '{type: $type, version: $version}')")
done

# =========================
# PLAYWRIGHT IMAGES
# =========================
for VERSION in $(get_versions "playwright"); do
    # Include Playwright if scheduled or its directory changed
    if [[ "$EVENT_NAME" != "schedule" ]] && ! has_changes "playwright/$VERSION/"; then
        continue
    fi

    # I think we need run on schedule or when dir was changed, but I am not sure
    items+=("$(jq -nc --arg type playwright --arg version "$VERSION" '{type: $type, version: $version}')")
done

# Join items with commas to form a valid JSON array string
items_json=$(IFS=, ; echo "${items[*]}")

# Output the final JSON structure
jq -n -c --argjson items "[$items_json]" '{"fail-fast":false,"matrix":{"include":$items}}'
