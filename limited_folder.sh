#!/bin/bash

function __help() {
    cat << EOF
Usage: script.sh [image_file] [size_limit_mb] [lim_dir]

Creates a zero-filled disk image file, formats it as ext4, and mounts it to a specified directory.

Parameters:
  image_file        Path to the image file to be created (e.g., /path/to/image.img).
  size_limit_mb     Size of the image file in megabytes (e.g., 100 for a 100 MB image).
  lim_dir           Directory where the image file will be mounted (e.g., /mnt/logs).

Example:
  script.sh my_image.img 100 /mnt/logs
  This command creates a 100 MB image file named 'my_image.img', formats it as ext4,
  and mounts it to the directory '/mnt/logs'.
EOF
}
if [[ "$1" == "--help" ]]; then
    __help
    exit 0
fi

if [ "$#" -ne 3 ]; then
    echo "Error: Invalid number of arguments."
    __help
    exit 1
fi

IMAGE_FILE=$1
SIZE_LIMIT_MB=$2
LIMITED_DIR=$3
CURRENT_USER=$(whoami)

if ! dd if=/dev/zero of="$IMAGE_FILE" bs=1M count="$SIZE_LIMIT_MB" status=progress; then
    echo "Error: Failed to create the image file."
    exit 1
fi

if ! mkfs.ext4 "$IMAGE_FILE"; then
    echo "Error: Failed to format the image file."
    exit 1
fi

mkdir -p "$LIMITED_DIR"

if ! sudo mount -o loop "$IMAGE_FILE" "$LIMITED_DIR"; then
    echo "Error: Failed to mount the image file."
    exit 1
fi

if ! sudo chown -R "$CURRENT_USER":"$CURRENT_USER" "$LIMITED_DIR"; then
    echo "Error: Failed to change ownership of the log directory."
    exit 1
fi

echo "Successfully created and mounted image file at '$LIMITED_DIR'."

