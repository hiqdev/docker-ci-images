#!/bin/bash

EVENT_NAME=$1
CHANGED_DIRS=$2
PERIODIC_UPDATES_MIN_VERSION=$3
BUILD_MIN_VERSION=$4

# Build JSON array
items=()

# Handle PHP images
cd php-nginx || exit
VERSIONS=$(ls -d */ | cut -f1 -d'/')

for VERSION in $VERSIONS; do
    # Do not include versions that are not supported by periodic updates
    if [[ $EVENT_NAME == 'schedule' ]] && [[ $VERSION < $PERIODIC_UPDATES_MIN_VERSION ]]; then
        continue
    fi

    # Do not include legacy versions
    if [[ $VERSION < $BUILD_MIN_VERSION ]]; then
        continue
    fi

    # On pull requests, if there are no changes in that version folder, skip it
    CHANGED_FILES_COUNT=$(echo $CHANGED_DIRS | jq ".[] | select(. | contains(\"php-nginx/$VERSION/\"))" | wc -l)
    if [[ $EVENT_NAME == 'pull_request' ]] && [[ $CHANGED_FILES_COUNT -eq 0 ]]; then
        continue
    fi

    # Append to array
    items+=("$(jq -nc --arg type php-nginx --arg version "$VERSION" '{type: $type, version: $version}')")
done

cd ..

# Handle Playwright image
if [[ "$CHANGED_DIRS" == *"playwright/"* || "$EVENT_NAME" == "schedule" ]]; then
    items+=("$(jq -nc --arg type playwright --arg version latest '{type: $type, version: $version}')")
fi

# Join items with commas to form a valid JSON array string
items_json=$(IFS=, ; echo "${items[*]}")

# Output the final JSON structure
jq -n -c --argjson items "[$items_json]" '{"fail-fast":false,"matrix":{"include":$items}}'
