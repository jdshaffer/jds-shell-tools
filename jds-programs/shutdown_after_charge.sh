#!/bin/bash
#---------------------------------------------------------
# Shutdown after Charge (MacOS)
# Jeffrey D. Shaffer & ChatGPT
# 2026-01-25
#
# This bash script watches the MacBook battery level.
#
# When the battery is fully charged, it sends out an
#   email notification, then shutsdown the computer.
#
# When battery charging is put on hold by the OS due
#   to optimized charging, it sends out an email 
#   notification including the final battery level,
#   then shutsdown the computer.
#
#---------------------------------------------------------

echo 
echo "Waiting for MacOS to finish charging..."

while true; do
    STATUS="$(pmset -g batt)"

    # Extract battery percent
    BATT=$(echo "$STATUS" | grep -Eo "\d+%" | tr -d '%')

    echo "Battery: $BATT%"

    # Case 1 -- Fully Charged
    if [ "$BATT" -ge 100 ]; then
        echo "Battery charged."
        echo "Sending notification and shutting down..."
        python3 notify_by_email.py "MBA Shutdown (Fully Charged)" "MBA has shutdown after fully charging."
        osascript -e 'tell application "System Events" to shut down'
        exit 0
    fi

    # Case 2 -- Charging on hold (Optimization)
    if echo "$STATUS" | grep -q "charging on hold"; then
        echo "Battery charging has been placed on hold (optimization)."
        echo "Sending notification and shutting down..."
        python3 notify_by_email.py "MBA Shutdown (Charging on Hold)" "MBA has shutdown after partially charging to $BATT%. Battery optimization has placed charging on hold."
        osascript -e 'tell application "System Events" to shut down'
        exit 0
    fi

    sleep 60
done
