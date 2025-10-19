#!/bin/bash

# =============================================================================
# Script: log_manager.sh
# Description: Backs up log files older than a specified number of days,
#              compresses them, and then deletes the original files.
#              Logs all actions taken.
# Author: Gemini
# Date: 2025-10-16
# =============================================================================

# --- Configuration ---
# Directory containing the logs to be managed.
LOG_SOURCE_DIR="/var/logs/checkins"

# Directory where compressed backups will be stored.
BACKUP_DEST_DIR="/backup/logs"

# File to log the actions of this script.
ACTION_LOG_FILE="/var/log/log_manager.log"

# Number of days after which logs should be archived.
DAYS_TO_KEEP=7

# --- Pre-run Checks ---

# Ensure the source directory exists.
if [ ! -d "$LOG_SOURCE_DIR" ]; then
    echo "$(date +"%Y-%m-%d %T") - ERROR: Log source directory not found: $LOG_SOURCE_DIR" | tee -a "$ACTION_LOG_FILE"
    exit 1
fi

# Ensure the backup directory exists, or create it.
if [ ! -d "$BACKUP_DEST_DIR" ]; then
    mkdir -p "$BACKUP_DEST_DIR"
    if [ $? -ne 0 ]; then
        echo "$(date +"%Y-%m-%d %T") - ERROR: Could not create backup directory: $BACKUP_DEST_DIR" | tee -a "$ACTION_LOG_FILE"
        exit 1
    fi
    echo "$(date +"%Y-%m-%d %T") - INFO: Created backup directory: $BACKUP_DEST_DIR" | tee -a "$ACTION_LOG_FILE"
fi

# --- Main Logic ---

TIMESTAMP=$(date +"%Y-%m-%d_%H%M%S")
BACKUP_FILENAME="checkin-logs-backup-${TIMESTAMP}.tar.gz"
BACKUP_FILE_PATH="${BACKUP_DEST_DIR}/${BACKUP_FILENAME}"

echo "--------------------------------------------------" | tee -a "$ACTION_LOG_FILE"
echo "$(date +"%Y-%m-%d %T") - INFO: Starting log management process." | tee -a "$ACTION_LOG_FILE"

# Find log files older than DAYS_TO_KEEP. The -print0 and xargs -0 handle filenames with spaces.
OLD_LOGS=$(find "$LOG_SOURCE_DIR" -type f -name "*.log" -mtime +$DAYS_TO_KEEP)

if [ -z "$OLD_LOGS" ]; then
    echo "$(date +"%Y-%m-%d %T") - INFO: No logs found older than $DAYS_TO_KEEP days. No action taken." | tee -a "$ACTION_LOG_FILE"
    exit 0
fi

echo "$(date +"%Y-%m-%d %T") - INFO: Found the following logs to archive:" | tee -a "$ACTION_LOG_FILE"
echo "$OLD_LOGS" | while read -r line; do echo "  - $line" | tee -a "$ACTION_LOG_FILE"; done


# Create a compressed archive of the old log files.
echo "$(date +"%Y-%m-%d %T") - INFO: Creating backup archive at: $BACKUP_FILE_PATH" | tee -a "$ACTION_LOG_FILE"
find "$LOG_SOURCE_DIR" -type f -name "*.log" -mtime +$DAYS_TO_KEEP -print0 | xargs -0 tar -czvf "$BACKUP_FILE_PATH"

# Verify backup and delete old files if successful
if [ $? -eq 0 ]; then
    echo "$(date +"%Y-%m-%d %T") - SUCCESS: Backup archive created successfully." | tee -a "$ACTION_LOG_FILE"
    
    # Delete the original log files that were archived.
    echo "$(date +"%Y-%m-%d %T") - INFO: Deleting original log files..." | tee -a "$ACTION_LOG_FILE"
    find "$LOG_SOURCE_DIR" -type f -name "*.log" -mtime +$DAYS_TO_KEEP -print0 | xargs -0 rm -v | tee -a "$ACTION_LOG_FILE"
    
    if [ $? -eq 0 ]; then
        echo "$(date +"%Y-%m-%d %T") - SUCCESS: Original log files deleted." | tee -a "$ACTION_LOG_FILE"
    else
        echo "$(date +"%Y-%m-%d %T") - ERROR: Failed to delete some or all original log files." | tee -a "$ACTION_LOG_FILE"
    fi
else
    echo "$(date +"%Y-%m-%d %T") - ERROR: Failed to create backup archive. Original files will not be deleted." | tee -a "$ACTION_LOG_FILE"
    exit 1
fi

echo "$(date +"%Y-%m-%d %T") - INFO: Log management process finished." | tee -a "$ACTION_LOG_FILE"
echo "--------------------------------------------------" | tee -a "$ACTION_LOG_FILE"

exit 0
