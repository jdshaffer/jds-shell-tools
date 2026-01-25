#!/bin/bash
#---------------------------------------------------------
# Shutdown after Charge (MacOS + Linux)
# Jeffrey D. Shaffer & ChatGPT
# 2026-01-25
#
# This bash script watches the MacBook battery level.
#
# When the battery is fully charged, it sends out an
#   email notification, then shuts down the computer.
#
# When battery charging is put on hold by the OS due
#   to optimized charging, it sends out an email 
#   notification including the final battery level,
#   then shuts down the computer.
#
# Note: For the shutdown command to work under Linux
#       without requiring a password, you can try
#       running  "sudo visudo" and then add this
#       line to the bottom of the sudoers.tmp file:
#       USERNAME ALL=(ALL) NOPASSWD: /sbin/shutdown
#
#---------------------------------------------------------

echo
echo "Checking Operating System Type..."
OS="$(uname)"


# ---------- MacOS Code ----------
if [ "$OS" = "Darwin" ]; then
    echo "MacOS Detected"
    echo
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


# ---------- Linux Code ----------
elif [ "$OS" = "Linux" ]; then
    echo "Linux Detected"
    echo

    BAT_PATH=$(ls -d /sys/class/power_supply/BAT* | head -n 1)

    # Attempt to read the system-specified maximum charge allowed, otherwise assume 100%
    if [ -f "$BAT_PATH/charge_control_end_threshold" ]; then
        THRESHOLD=$(cat "$BAT_PATH/charge_control_end_threshold")
    else
        THRESHOLD=100
    fi
    echo "Shutdown threshold set to: $THRESHOLD%"

    while true; do
        BATT=$(cat "$BAT_PATH/capacity")
        STATUS=$(cat "$BAT_PATH/status")

        echo "Battery: $BATT% | Status: $STATUS"

        if [[ "$BATT" -ge "$THRESHOLD" ]]; then
            echo "Battery reached the allowed maximum charge of ($THRESHOLD%)."
            echo "Sending notification and shutting down..."
            python3 notify_by_email.py "Asus Shutdown (Max Charge Reached)" "Asus has shutdown after charging to the system-specified maximum of $BATT%."
            sudo shutdown now
            exit 0
        fi

        sleep 60
    done


# ---------- Unexpected OS Code ----------
else
    echo "Unsupported OS"
    exit 1
fi
