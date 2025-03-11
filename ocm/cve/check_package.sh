#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
	echo "Usage: $0 <image_name> <binary_patch> <package_name>"
	exit 1
fi

# Assign input arguments to variables
IMAGE_NAME=$1
BINARY_PATCH=$2
PACKAGE_NAME=$3

# Pull the Docker image
echo "Pulling image: $IMAGE_NAME"
docker pull "$IMAGE_NAME"

# Inspect the image to find the UpperDir
echo "Inspecting image to find UpperDir..."
UPPER_DIR=$(docker inspect "$IMAGE_NAME" | grep -oP '(?<="UpperDir": ")[^"]+')

if [ -z "$UPPER_DIR" ]; then
	echo "Failed to find UpperDir for image: $IMAGE_NAME"
	exit 1
fi

echo "UpperDir found: $UPPER_DIR"

# Construct the full path to the binary
BINARY_PATH="$UPPER_DIR$BINARY_PATCH"

# Check if the binary exists
if [ ! -f "$BINARY_PATH" ]; then
	echo "Binary not found at path: $BINARY_PATH"
	exit 1
fi

# Run the go version -m command and grep for the package name
echo "Checking for package: $PACKAGE_NAME in binary: $BINARY_PATH"
go version -m "$BINARY_PATH" | grep "$PACKAGE_NAME"
