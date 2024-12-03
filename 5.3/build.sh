#!/bin/sh
docker buildx bake --no-cache --push --set "*.platform=linux/arm64/v8,linux/amd64" latest
