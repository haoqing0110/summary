#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

INPUT_FILE=$1

# Check if the input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Input file not found: $INPUT_FILE"
    exit 1
fi

# Read the input file line by line
while IFS= read -r line; do
    # Skip empty lines
    if [ -z "$line" ]; then
        continue
    fi

    # Read image name, binary patch, and package name from the line
    IMAGE_NAME=$(echo "$line" | awk '{print $1}')
    BINARY_PATCH=$(echo "$line" | awk '{print $2}')
    PACKAGE_NAME=$(echo "$line" | awk '{print $3}')

    # Pull the Docker image
    echo "Pulling image: $IMAGE_NAME"
	docker pull "$IMAGE_NAME" > /dev/null 2>&1

    # Inspect the image to find the UpperDir
    # echo "Inspecting image to find UpperDir..."
    UPPER_DIR=$(docker inspect "$IMAGE_NAME" | grep -oP '(?<="UpperDir": ")[^"]+')

    if [ -z "$UPPER_DIR" ]; then
        echo "Failed to find UpperDir for image: $IMAGE_NAME"
    else
        #echo "UpperDir found: $UPPER_DIR"

        # Construct the full path to the binary
        BINARY_PATH="$UPPER_DIR$BINARY_PATCH"

        # Check if the binary exists
        if [ -f "$BINARY_PATH" ]; then
            # Run the go version -m command and grep for the package name
            echo "============================="
            echo "Checking for package: $PACKAGE_NAME in binary: $BINARY_PATH"
            echo "go version -m $BINARY_PATH | grep $PACKAGE_NAME"
            go version -m "$BINARY_PATH" | grep "$PACKAGE_NAME"
            echo "============================="
        else
            echo "Binary not found at path: $BINARY_PATH"
        fi
    fi

done < "$INPUT_FILE"