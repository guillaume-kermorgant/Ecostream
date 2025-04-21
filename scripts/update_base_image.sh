#!/bin/sh

set -e

# this script pulls a docker image for a specific platform and push it to a different registry

echo "Pulling source image: $SRC_IMAGE for platform $IMAGE_ARCH..."
docker pull --platform="linux/$IMAGE_ARCH" "$SRC_IMAGE"

echo "Tagging $SRC_IMAGE as $DEST_IMAGE..."
docker tag "$SRC_IMAGE" "$DEST_IMAGE"

echo "Pushing $DEST_IMAGE..."
docker push "$DEST_IMAGE"

echo "Done updating $DEST_IMAGE"
