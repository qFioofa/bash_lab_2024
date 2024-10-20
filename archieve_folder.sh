#!/bin/bash

function __help() {
    cat << EOF
Usage: $(basename "$0") TARGET_FOLDER [THRESHOLD] [BACKUP_PATH]

This script checks the size of the TARGET_FOLDER directory and archives files if the usage exceeds the specified threshold.

Arguments:
  TARGET_FOLDER       Path to the directory containing video files (required).
  THRESHOLD           Percentage threshold for archiving (default: 70).
  BACKUP_PATH         Directory where backups will be stored (default: "\$TARGET_FOLDER/../backup").

Options:
  --help              Display this help message and exit.
EOF
}

if [ "$1" == "--help" ]; then
    __help
    exit 0
fi

TARGET_FOLDER="$1"
THRESHOLD=${2:-70}
BACKUP_PATH=${3:-"$TARGET_FOLDER/../backup"}

if [ -z "$TARGET_FOLDER" ]; then
    echo "Please provide a target folder as the first argument."
    exit 1
fi

if [ ! -d "$TARGET_FOLDER" ]; then
    echo "Directory does not exist: $TARGET_FOLDER"
    exit 1
fi

MOUNT_POINT=$(df "$TARGET_FOLDER" | tail -1 | awk '{print $1}')
if [ -z "$MOUNT_POINT" ]; then
    echo "The specified folder is not located on a mounted disk."
    exit 1
fi

FOLDER_SIZE_MB=$(du -sm "$TARGET_FOLDER" | cut -f1)
SIZE_LIMIT=$(df -m "$MOUNT_POINT" | tail -1 | awk '{print $2}')

echo "Initial folder size: $FOLDER_SIZE_MB MB"

PERCENTAGE=$(echo "scale=2; ($FOLDER_SIZE_MB / $SIZE_LIMIT) * 100" | bc)
echo "Initial folder takes ${PERCENTAGE}% of the ${SIZE_LIMIT} MB"

if [ ! -d "$BACKUP_PATH" ]; then
    echo "Backup directory does not exist. Creating: $BACKUP_PATH"
    mkdir -p "$BACKUP_PATH"
fi

while (( $(echo "$PERCENTAGE > $THRESHOLD" | bc -l) )); do
    echo "Usage has exceeded ${THRESHOLD}%, proceeding to archive files."

    OLDEST_FILE=$(ls -t "$TARGET_FOLDER" | grep -v -Ff <(ls "$BACKUP_PATH" 2>/dev/null) | tail -n 1)

    if [ -z "$OLDEST_FILE" ]; then
        echo "No files found to archive."
        exit 0
    fi

    ARCHIVE_NAME="$BACKUP_PATH/log_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    echo "Archiving $OLDEST_FILE into: $ARCHIVE_NAME"
    
    tar -czf "$ARCHIVE_NAME" -C "$TARGET_FOLDER" "$OLDEST_FILE"
    if [ $? -eq 0 ]; then
        echo "Successfully archived $OLDEST_FILE."
        rm -f "$TARGET_FOLDER/$OLDEST_FILE"
        echo "Deleted $OLDEST_FILE from $TARGET_FOLDER"
    else
        echo "Error occurred while archiving $OLDEST_FILE."
        exit 1
    fi

    FOLDER_SIZE_MB=$(du -sm "$TARGET_FOLDER" | cut -f1)
    PERCENTAGE=$(echo "scale=2; ($FOLDER_SIZE_MB / $SIZE_LIMIT) * 100" | bc)
    echo "Folder now takes ${PERCENTAGE}% of the ${SIZE_LIMIT} MB"

    if (( $(echo "$PERCENTAGE <= $THRESHOLD" | bc -l) )); then
        echo "Usage is now within the threshold. Archiving complete."
        break
    fi
done

if (( $(echo "$PERCENTAGE <= $THRESHOLD" | bc -l) )); then
    echo "Folder usage is now within acceptable limits. No further action needed."
else
    echo "Folder usage is still above threshold after archiving."
fi

