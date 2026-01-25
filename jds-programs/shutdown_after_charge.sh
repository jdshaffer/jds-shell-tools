#!/bin/bash
#---------------------------------------------------------
# Shutdown after Charge (MacOS + Linux)
# Jeffrey D. Shaffer & ChatGPT
# 2026-01-25
#
# This bash script watches the laptop battery level.
#
# When the battery is fully charged, it sends out an
#   email notification, then shuts down the computer.
#
# When battery charging is put on hold by the OS due
#   to optimized charging, or when the charging halts
#   at the same level for an hour, it sends out an
#   email notification including the final battery
#   level, then shuts down the computer.
#
# Will warn and exit when run on a system with no
#   battery (i.e., a desktop computer)
#
# Note: For the shutdown command to work under Linux
#       without requiring a password, you can try
#       running  "sudo visudo" and then add this
#       line to the bottom of the sudoers.tmp file:
#       USERNAME ALL=(ALL) NOPASSWD: /sbin/shutdown
#
#---------------------------------------------------------


echo
echo "Starting the 'Shutdown After Charge' Script..."
echo "Checking Operating System Type..."
OS="$(uname)"



# ---------- MacOS Code ----------
# Two shutdown cases:
#   (1) Battery is 100% charged
#   (2) Battery charging halts due to battery optimization
if [ "$OS" = "Darwin" ]; then
    echo "MacOS Detected."
    echo
        while true; do
            STATUS="$(pmset -g batt)"

            # Extract battery percent
            BATT=$(echo "$STATUS" | grep -Eo "\d+%" | tr -d '%')

            if [ -z "$BATT" ]; then
               echo "WARNING: This computer does not have a battery."
               echo "Script canceled."
               echo
               exit 0
            fi

            echo "Battery: $BATT%"

            # Case 1 -- Fully Charged
            if [ "$BATT" -ge 100 ]; then
                echo "Battery charged."
                echo "Sending notification and shutting down..."
                python3 notify_by_email.py "MBA Shutdown (Fully Charged)" "MBA has shutdown after fully charging."
                sleep 30     # Needed as apparently notify_by_email.py doesn't always connect to gmail right away
                osascript -e 'tell application "System Events" to shut down'
                exit 0
            fi

            # Case 2 -- Charging on hold (Optimization)
            if echo "$STATUS" | grep -q "charging on hold"; then
                echo "Battery charging has been placed on hold (optimization)."
                echo "Sending notification and shutting down..."
                python3 notify_by_email.py "MBA Shutdown (Charging on Hold)" "MBA has shutdown after partially charging to $BATT%. Battery optimization has placed charging on hold."
                sleep 30     # Needed as apparently notify_by_email.py doesn't always connect to gmail right away
                osascript -e 'tell application "System Events" to shut down'
                exit 0
            fi

            sleep 60
        done


# ---------- Linux Code ----------
# Two shutdown cases:
#   (1) Battery is charged to the system-set maximum charged
#   (2) Battery charging fails to progress for an hour (probably the battery max has been reached)
elif [ "$OS" = "Linux" ]; then
    echo "Linux Detected."
    echo

    if ! compgen -G "/sys/class/power_supply/BAT*" > /dev/null; then
       echo "WARNING: This computer does not have a battery."
       echo "Script canceled."
       echo
       exit 0
    fi

    BAT_PATH=$(ls -d /sys/class/power_supply/BAT* | head -n 1)

    # Attempt to read the system-specified maximum charge allowed, otherwise assume 100%
    if [ -f "$BAT_PATH/charge_control_end_threshold" ]; then
        THRESHOLD=$(cat "$BAT_PATH/charge_control_end_threshold")
    else
        THRESHOLD=100
    fi
    echo "Shutdown threshold set to: $THRESHOLD%"

    # Counters used to track halted charging
    PREV_BATT=-1
    STABLE_MINUTES=0

    while true; do
        BATT=$(cat "$BAT_PATH/capacity")

        echo "Battery: $BATT% | Stable: $STABLE_MINUTES min"

        # Case 1 — Reach the system-set maximum charge
        if [[ "$BATT" -ge "$THRESHOLD" ]]; then
            echo "Battery reached system charge limit ($THRESHOLD%)."
            python3 notify_by_email.py "Asus Shutdown (Max Charge Reached)" \
            "Asus has shutdown after charging to the system-specified maximum of $BATT%."
            sleep 30     # Needed as apparently notify_by_email.py doesn't always connect to gmail right away
            sudo shutdown now
            exit 0
        fi

        # Case 2 — Battery charging fails to progress for an hour
        if [ "$BATT" -le "$PREV_BATT" ]; then
            STABLE_MINUTES=$((STABLE_MINUTES + 1))
        else
            STABLE_MINUTES=0
        fi

        # If stuck for 60 minutes, assume charging is complete
        if [ "$STABLE_MINUTES" -ge 60 ]; then
            echo "Battery has remained at $BATT% for 60 minutes."
            python3 notify_by_email.py "Asus Shutdown (Charge Plateau)" 
            "Asus has shutdown after battery remained at $BATT% for one hour. Charging appears complete."
            sleep 30     # Needed as apparently notify_by_email.py doesn't always connect to gmail right away
            sudo shutdown now
            exit 0
        fi

        PREV_BATT=$BATT
        sleep 60
    done
fi


# ---------- Unexpected OS Code ----------
else
    echo "Unsupported OS"
    exit 1
fi
