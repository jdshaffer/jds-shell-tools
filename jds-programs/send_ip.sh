#!/bin/bash
# -----------------------------------------------------------------
# Universal send_ip.sh
# Jeffrey D. Shaffer
# Updated -- 2025-12-24
#
# A little program that automatically sends the local machine's
# name (set in .bash_aliases) and ip address to a local
# machine set as an IP hub. This allows for the automated
# lookup of IP addresses, even with local IPs change over time
# (reboots, etc.)
#
# -----------------------------------------------------------------
# Notes:
#    - Requires ifconfig to be installed
#      (might need to run:  sudo apt install net-tools
#    - Be sure to update and check the "Configuration" below
#
# -----------------------------------------------------------------

# Configuration
RPI_HUB_IP="192.168.1.1"    # Be sure to set this to your IP-hub machine's IP!
RPI_HUB_PORT="5000"
DEVICE_HOSTNAME=$machine_name
CURL_TIMEOUT=5    # How long to wait before exiting gracefully


# Get the primary IP address of the current device
DEVICE_IP=""
DEVICE_IP=$(/sbin/ifconfig | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}' | head -n 1)

# Check if IP was successfully retrieved
if [ -z "$DEVICE_IP" ]; then
    echo "Error: Could not determine device IP address."
    exit 1
fi


# Construct the JSON payload
JSON_PAYLOAD="{\"hostname\": \"${DEVICE_HOSTNAME}\", \"ip_address\": \"${DEVICE_IP}\"}"


# Send the report using curl with a timeout (for graceful exit on network errors)
echo "Reporting IP ${DEVICE_IP} for ${DEVICE_HOSTNAME} to http://${RPI_HUB_IP}:${RPI_HUB_PORT}/report_ip"
curl -s --connect-timeout ${CURL_TIMEOUT} --max-time ${CURL_TIMEOUT} -X POST \
     -H "Content-Type: application/json" \
     -d "${JSON_PAYLOAD}" \
     http://${RPI_HUB_IP}:${RPI_HUB_PORT}/report_ip > /dev/null
     # Remove "/dev/null" to see server's reply in terminal


# Check the exit status of curl
CURL_EXIT_STATUS=$?

if [ ${CURL_EXIT_STATUS} -eq 0 ]; then
    echo "IP report sent successfully."
elif [ ${CURL_EXIT_STATUS} -eq 28 ]; then
    echo "Error: IP report failed due to timeout. The IP Hub might be unreachable or unresponsive."
    exit 1 # Exit with an error code for timeout
else
    echo "Error: Failed to send IP report. Curl exited with status ${CURL_EXIT_STATUS}."
    exit 1 # Exit with an error code for other curl errors
fi
