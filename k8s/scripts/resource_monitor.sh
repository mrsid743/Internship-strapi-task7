#!/bin/bash

# =============================================================================
# Script: resource_monitor.sh
# Description: Monitors system resources (CPU, Memory, Disk) and sends an
#              email alert if any of the defined thresholds are breached.
# Author: Gemini
# Date: 2025-10-16
# =============================================================================

# --- Configuration ---
# Set the threshold values in percentage.
CPU_THRESHOLD=80
MEM_THRESHOLD=75
DISK_THRESHOLD=85
LOAD_THRESHOLD=5.0 # Threshold for 1-minute load average

# Set the recipient email address for alerts.
RECIPIENT_EMAIL="siddhantpanekar39@gmail.com"

# Set the filesystem to monitor (e.g., "/" for the root filesystem).
FILESYSTEM_TO_MONITOR="/mnt/c"

# --- Main Logic ---

# Get the current server hostname and timestamp.
HOSTNAME=$(hostname)
TIMESTAMP=$(date +"%Y-%m-%d %T")

# A flag to check if an alert needs to be sent.
SEND_ALERT=0
# A variable to build the email message.
ALERT_MESSAGE=""

# 1. Check CPU Usage
# Using `top` to get CPU idle percentage, then subtracting from 100 to get usage.
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}' | cut -d. -f1)

if [ "$CPU_USAGE" -gt "$CPU_THRESHOLD" ]; then
    SEND_ALERT=1
    ALERT_MESSAGE+="CRITICAL: High CPU usage detected: ${CPU_USAGE}% (Threshold: ${CPU_THRESHOLD}%)\n"
fi

# 2. Check Memory Usage
# Using `free` to calculate the percentage of used memory.
MEM_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}' | cut -d. -f1)

if [ "$MEM_USAGE" -gt "$MEM_THRESHOLD" ]; then
    SEND_ALERT=1
    ALERT_MESSAGE+="CRITICAL: High Memory usage detected: ${MEM_USAGE}% (Threshold: ${MEM_THRESHOLD}%)\n"
fi

# 3. Check Disk Usage
# Using `df` to get the usage percentage for the specified filesystem.
DISK_USAGE=$(df -h "$FILESYSTEM_TO_MONITOR" | grep -w "$FILESYSTEM_TO_MONITOR" | awk '{ print $5 }' | sed 's/%//g')

echo "DEBUG: The value of DISK_USAGE is: '$DISK_USAGE'"
echo "DEBUG: The value of DISK_THRESHOLD is: '$DISK_THRESHOLD'"

if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    SEND_ALERT=1
    ALERT_MESSAGE+="CRITICAL: Low Disk Space detected on ${FILESYSTEM_TO_MONITOR}: ${DISK_USAGE}% used (Threshold: ${DISK_THRESHOLD}%)\n"
fi

# 4. Check System Load Average

# Using `uptime` to get the 1-minute load average.
LOAD_AVG=$(uptime | awk -F'load average: ' '{ print $2 }' | cut -d, -f1)

if (( $(echo "$LOAD_AVG > $LOAD_THRESHOLD" | bc -l) )); then
    SEND_ALERT=1
    ALERT_MESSAGE+="CRITICAL: High System Load Average detected: ${LOAD_AVG} (Threshold: ${LOAD_THRESHOLD})\n"
fi


# 5. Send Email Alert if any threshold was breached
if [ "$SEND_ALERT" -eq 1 ]; then
    EMAIL_SUBJECT="System Resource Alert on $HOSTNAME"
    EMAIL_BODY="--------------------------------------------------\n"
    EMAIL_BODY+="System Alert Report for: $HOSTNAME\n"
    EMAIL_BODY+="Timestamp: $TIMESTAMP\n"
    EMAIL_BODY+="--------------------------------------------------\n\n"
    EMAIL_BODY+="$ALERT_MESSAGE"
    EMAIL_BODY+="\n--- System Summary ---\n"
    EMAIL_BODY+="CPU Usage: $CPU_USAGE%\n"
    EMAIL_BODY+="Memory Usage: $MEM_USAGE%\n"
    EMAIL_BODY+="Disk Usage (${FILESYSTEM_TO_MONITOR}): $DISK_USAGE%\n"
    EMAIL_BODY+="Load Average (1-min): $LOAD_AVG\n"

    # Use mailx or sendmail to send the email.
    # Ensure that the mail utilities are installed and configured on your system.
    echo -e "$EMAIL_BODY" | mailx -s "$EMAIL_SUBJECT" "$RECIPIENT_EMAIL"

    # For systems without mailx, you might use sendmail:
    # echo -e "Subject: $EMAIL_SUBJECT\n\n$EMAIL_BODY" | sendmail "$RECIPIENT_EMAIL"

    echo "Alert sent to $RECIPIENT_EMAIL."
else
    echo "All system resources are within thresholds."
fi

exit 0
