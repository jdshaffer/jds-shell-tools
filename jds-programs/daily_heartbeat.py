#!/usr/bin/env python3
#--------------------------------------------------------------------------------------------------
# Daily Heartbeat Email (from RasPi)
# by Jds and ChatGPT
# 2026-01-29
#
# Sends a once-a-day “I’m alive” message to confirm the server is still running.
# Schedule via cron for noon each day.
#
# ADD AS A CRONJOB:
#    crontab -e
#    0 12 * * * /usr/bin/python3 /path/to/daily_heartbeat.py
#
# 2025-12-20 -- Disabled logging on success, but left logging on error
# 2025-12-21 -- Updated the email subject and contents to be a bit more fun
# 2026-01-29 -- Added code to report on the status of custom services and Home Assistant
#               also prettified the email body using fixed-width html
#            -- Moved email settings to external file for safety
# 2026-01-30 -- Fixed a "can't find the external file" problem when run as a cronjob
#
#--------------------------------------------------------------------------------------------------


import smtplib
import ssl
from email.message import EmailMessage
from datetime import datetime
import socket
import os
import logging
import subprocess


# Make sure the file exists (in the same directory as the script)
import os
SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))
SETTINGS_FILE = os.path.join(SCRIPT_DIR, "email_settings.txt")

if not os.path.exists(SETTINGS_FILE):
    print(f"Error: The settings file '{SETTINGS_FILE}' was not found.")
    print("Please create this file in the same directory as the script with your email and app password on separate lines.")
    exit(1) # Exit the script if the file is missing

# Read email credentials from the file
try:
    with open(SETTINGS_FILE, 'r') as f:
        GMAIL_USER = f.readline().strip() # Read first line for email, remove whitespace
        GMAIL_APP_PASSWORD = f.readline().strip()  # Read second line for app password, remove whitespace
except Exception as e:
    print(f"Error reading settings from '{SETTINGS_FILE}': {e}")
    print("Please ensure the file contains your email on the first line and app password on the second line.")
    exit(1) # Exit if there's an error reading the file

# Ensure credentials are not empty
if not GMAIL_USER or not GMAIL_APP_PASSWORD:
    print(f"Error: Email address or app password found in '{SETTINGS_FILE}' is empty.")
    print("Please ensure both lines in the file contain valid credentials.")
    exit(1)


# --- CONFIG ---
GMAIL_SMTP = 'smtp.gmail.com'
GMAIL_SMTP_PORT = 587
LOG_FILE = '/tmp/daily_heartbeat.log'


# --- LOGGING ---
logging.basicConfig(
    filename=LOG_FILE,
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s'
)


# --- HELPER ---
def get_cmd_output(cmd):
    try:
        result = subprocess.run(cmd, capture_output=True, text=True)
        return result.stdout.strip()
    except Exception as e:
        return f"error: {e}"


# --- MAIN ---
try:
    hostname = socket.gethostname()
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    # Uptime
    try:
        uptime = os.popen("uptime -p").read().strip()
    except Exception:
        uptime = "(could not get uptime)"

    # Service checks
    ip_hub_status = get_cmd_output(["systemctl", "is-active", "ip-hub.service"])
    phone_status = get_cmd_output(["systemctl", "is-active", "phonecall_detector.service"])
    docker_status = get_cmd_output(["systemctl", "is-active", "docker"])
    ha_status = get_cmd_output([
        "docker", "inspect",
        "-f", "{{.State.Status}}",
        "homeassistant"
    ])

    # --- BUILD REPORT (aligned text) ---
    report = (
        f"Just letting you know that Little Ben (RasPi) is online and well.\n\n"
        f"Currently {uptime}...\n\n"
        f"-----------------------------\n"
        f"Service Status Report\n"
        f"-----------------------------\n"
        f"{'ip-hub:':20}{ip_hub_status}\n"
        f"{'phonecall_detector:':20}{phone_status}\n"
        f"{'Docker:':20}{docker_status}\n"
        f"{'Home Assistant:':20}{ha_status}\n"
    )

    # --- CREATE EMAIL ---
    msg = EmailMessage()
    msg['Subject'] = "Ding, Dong... it's 12 o'clock! -- Little Ben"
    msg['From'] = GMAIL_USER
    msg['To'] = GMAIL_USER

    # Plain text version
    msg.set_content(report)

    # HTML version using a table (aligns perfectly everywhere)
    msg.add_alternative(f"""\
<html>
<body style="font-family: monospace;">
<p>Just letting you know that Little Ben (RasPi) is online and well.</p>

<p>Currently {uptime}...</p>

<pre>-----------------------------
Service Status Report
-----------------------------</pre>

    <table style="font-family: monospace;">
      <tr><td>ip-hub:</td><td>&nbsp;&nbsp;{ip_hub_status}</td></tr>
      <tr><td>phonecall_detector:</td><td>&nbsp;&nbsp;{phone_status}</td></tr>
      <tr><td>Docker:</td><td>&nbsp;&nbsp;{docker_status}</td></tr>
      <tr><td>Home Assistant:</td><td>&nbsp;&nbsp;{ha_status}</td></tr>
    </table>
  </body>
</html>
""", subtype='html')

    # --- SEND EMAIL ---
    context = ssl.create_default_context()
    with smtplib.SMTP(GMAIL_SMTP, GMAIL_SMTP_PORT) as smtp:
        smtp.starttls(context=context)
        smtp.login(GMAIL_USER, GMAIL_APP_PASSWORD)
        smtp.send_message(msg)

    # --- LOG SUCCESS ---
    logging.info("Heartbeat email sent successfully.")

except Exception as e:
    logging.error(f"Failed to send heartbeat email: {e}")
