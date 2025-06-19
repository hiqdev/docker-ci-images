#!/bin/bash

EVENT_NAME=$1
CHANGED_DIRS=$2
PERIODIC_UPDATES_MIN_VERSION=$3

# Handle PHP images
cd php-nginx || exit
VERSIONS=$(ls -d */ | cut -f1 -d'/')

for VERSION in $VERSIONS; do
    # Do not include versions that are not supported by periodic updates
    if [[ $EVENT_NAME == 'schedule' ]] && [[ $VERSION < $PERIODIC_UPDATES_MIN_VERSION ]]; then
        continue
    fi

    CHANGED_FILES_COUNT=$(echo $CHANGED_DIRS | jq ".[] | select(. | contains(\"php-nginx/$VERSION/\"))" | wc -l)
    if [[ $EVENT_NAME == 'pull_request' ]] && [[ $CHANGED_FILES_COUNT -eq 0 ]]; then
        continue
    fi

    jq --null-input \
      --arg type "php-nginx" \
      --arg version "$VERSION" \
      '{"type": $type, "version": $version}'
done

cd ..

# Handle Playwright image
if [[ "$CHANGED_DIRS" == *"playwright/"* || "$EVENT_NAME" == "schedule" ]]; then
    jq --null-input \
      --arg type "playwright" \
      --arg version "latest" \
      '{"type": $type, "version": $version}'
fi
