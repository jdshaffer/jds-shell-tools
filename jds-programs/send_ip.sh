#!/bin/bash
#-----------------------------------------------------------------
# Universal send_ip.sh
# 2026-01-26
#
# 2025-06-27
#    - Current version will exit gracefully if the remote machine
#      does not repond (i.e., is not found) after 5 seconds
#    - Be sure to update "machine_name" in .bash_aliases
#    - Be sure to update and check the "Configuration" below
#
# 2025-07-04
#    - Changed the curl command to hide the server's response
#
# 2026-01-26
#    - Now checks which machine is being used before looking
#      up the local IP. One of my machines (raspi) needs
#      special treatment because of a Docker container that
#      reports a different, conflicting IP
#    - Tidied up the console feedback provided by the problem.
#
#-----------------------------------------------------------------


# Configuration
RPI_HUB_IP="192.168.3.71"
RPI_HUB_PORT="5000"
DEVICE_HOSTNAME=$machine_name
CURL_TIMEOUT=5    # How long to wait before exiting gracefully


# Check the machine name, then get the primary IP address for the current device
case "$machine_name" in
    raspi)
        # wlan0 is added to avoid multiple IPs, such as those caused by a running Docker container
        DEVICE_IP=""
        DEVICE_IP=$(/sbin/ifconfig wlan0 | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}' | head -n 1)
        ;;
    *)
        # This is MacOS
        DEVICE_IP=""
        DEVICE_IP=$(/sbin/ifconfig | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}' | head -n 1)
        ;;
esac


# Check if IP was successfully retrieved
if [ -z "$DEVICE_IP" ]; then
    echo "Error: Could not determine device IP address."
    exit 1
fi


# Construct the JSON payload to send to the IP-Hub
JSON_PAYLOAD="{\"hostname\": \"${DEVICE_HOSTNAME}\", \"ip_address\": \"${DEVICE_IP}\"}"


# Send the report using curl with a timeout (for graceful exit on network errors)
echo "Reporting IP ${DEVICE_IP} for this computer (${DEVICE_HOSTNAME}) to the IP-Hub..."
curl -s --connect-timeout ${CURL_TIMEOUT} --max-time ${CURL_TIMEOUT} -X POST \
     -H "Content-Type: application/json" \
     -d "${JSON_PAYLOAD}" \
     http://${RPI_HUB_IP}:${RPI_HUB_PORT}/report_ip > /dev/null
     # Remove "/dev/null" to see server's reply in terminal


# Check the exit status of curl
CURL_EXIT_STATUS=$?

if [ ${CURL_EXIT_STATUS} -eq 0 ]; then
    echo "IP report sent successfully."
    echo
elif [ ${CURL_EXIT_STATUS} -eq 28 ]; then
    echo "Error: IP report failed due to timeout. The IP Hub might be unreachable or unresponsive."
    echo
    exit 1 # Exit with an error code for timeout
else
    echo "Error: Failed to send IP report. Curl exited with status ${CURL_EXIT_STATUS}."
    echo
    exit 1 # Exit with an error code for other curl errors
fi

