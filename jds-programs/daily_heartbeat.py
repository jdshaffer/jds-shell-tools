#!/usr/bin/env python3
#--------------------------------------------------------------------------------------------------
# Daily Heartbeat Email (from a local machine)
# by Jds and ChatGPT
#
# Sends a once-a-day “I’m alive” message to confirm the server is still running.
# Best to schedule as a cronjob each day (I prefer at noon).
#
# ADD AS A CRONJOB:
#    crontab -e
#    0 12 * * * /usr/bin/python3 /path/to/daily_heartbeat.py
#
# Note: This requires a Google App Password to be setup
#
#--------------------------------------------------------------------------------------------------

import smtplib
import ssl
from email.message import EmailMessage
from datetime import datetime
import socket
import os
import logging

# --- CONFIG ---
GMAIL_USER = ''                  # Your GMail Address Goes Here
GMAIL_APP_PASSWORD = ''          # Your Google App Password Goes Here
GMAIL_SMTP = 'smtp.gmail.com'
GMAIL_SMTP_PORT = 587
LOG_FILE = '/tmp/daily_heartbeat.log'

# --- LOGGING ---
logging.basicConfig(
    filename=LOG_FILE,
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s'
)

# --- MAIN ---
try:
    hostname = socket.gethostname()
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    # Grab Uptime
    try:
        uptime = os.popen("uptime -p").read().strip()
    except Exception:
        uptime = "(could not get uptime)"

    # Create Message
    msg = EmailMessage()
    msg['Subject'] = f"Ding Dong... It's 12 o'clock! -- Little Ben"
    msg['From'] = GMAIL_USER
    msg['To'] = GMAIL_USER
    msg.set_content(
        f"\n"
        f"Just letting you know that Little Ben (RasPi) is online and well.\n"
        f"\n"
        f"Currently {uptime} and counting!\n\n"
    )

    # Send Message
    context = ssl.create_default_context()
    with smtplib.SMTP(GMAIL_SMTP, GMAIL_SMTP_PORT) as smtp:
        smtp.starttls(context=context)
        smtp.login(GMAIL_USER, GMAIL_APP_PASSWORD)
        smtp.send_message(msg)

except Exception as e:
    logging.error(f"Failed to send heartbeat email: {e}")
