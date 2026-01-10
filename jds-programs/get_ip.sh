#!/bin/bash
# -----------------------------------------------------------------
# Universal get_ip.sh
# Jeffrey D. Shaffer
# Updated -- 2025-12-24
#
# A little program that asked a local machine (running as an IP-hub)
# to send back the IP address of the machine name queried. 
# This allows for the automatic lookup of machine IP based on
# nicknames. It also allow for custom scripts that use the custom
# lookups, such as:  mySSH RaspberryPi
#
# -----------------------------------------------------------------
# Notes:
#    - Requires ifconfig to be installed
#      (might need to run:  sudo apt install net-tools
#    - Be sure to update and check the "Configuration" below
#
# -----------------------------------------------------------------

# Configuration
RPI_HUB_IP="192.168.1.1"    # Be sure to set this to the local machine's IP
RPI_HUB_PORT="5000"

# Check if a hostname argument is provided
if [ -z "$1" ]; then
#    echo "Usage: $0 <target_hostname>"     # Older version
    echo "Usage:  getIP  <target_hostname>"
    exit 1
fi

TARGET_HOSTNAME="$1"

# Special input case: list all known hostnames
if [ "$TARGET_HOSTNAME" = "list" ]; then
    echo "Machines currently added to IPhub:"
    curl -sf "http://${RPI_HUB_IP}:${RPI_HUB_PORT}/list_devices" \
    | jq -r '.devices[]' | sed 's/^/   /'
    echo ""
    exit 0
fi

#echo "Querying IP for ${TARGET_HOSTNAME} from http://${RPI_HUB_IP}:${RPI_HUB_PORT}/get_ip"
response=$(curl -s "http://${RPI_HUB_IP}:${RPI_HUB_PORT}/get_ip?hostname=${TARGET_HOSTNAME}")
CURL_STATUS=$?

if [ $CURL_STATUS -ne 0 ]; then
    echo "Error: Failed to connect to the IP hub. Curl exit code: ${CURL_STATUS}"
    # This might indicate network issues or the server not running
    exit 1
fi

# Check if the response contains an error (e.g., hostname not found)
# Using jq to check for the presence of the 'error' key
ERROR_MESSAGE=$(echo "${response}" | jq -r '.error // empty')

if [ -n "$ERROR_MESSAGE" ]; then
    echo "Error from IP hub: ${ERROR_MESSAGE}"
    exit 1
fi

# Parse the JSON response using jq
IP_ADDRESS=$(echo "${response}" | jq -r '.ip_address // empty')
LAST_UPDATED=$(echo "${response}" | jq -r '.last_updated // empty')


if [ -n "$IP_ADDRESS" ]; then
#    echo "--------------------------------------------------"
#    echo "Hostname:      ${TARGET_HOSTNAME}"
#    echo "IP Address:    ${IP_ADDRESS}"
#    echo "Last Updated:  ${LAST_UPDATED}"
#    echo "--------------------------------------------------"
    echo "${IP_ADDRESS}" # Output just the IP for easy scripting
    exit 0
else
    # If IP_ADDRESS is empty but no explicit error was found, something unexpected happened
    echo "Error: Could not parse IP address from response. Raw response: ${response}"
    exit 1
fi