############################################################################################
# Notify By Email
# 2024-11-22
#
# A little program that sends out an email using Gmail.
#
# Note -- This requires a settings file "notify_by_email_settings.txt" which
#         contains your gmail email address on line one and
#         your gmail app password on line two.
#
# Use  -- python3 notify_by_email.py 'Cool Subject' 'Cool Message!'
#
############################################################################################

import smtplib
from email.mime.text import MIMEText
import argparse
import os # Import the os module to check for file existence


# LOAD EMAIL AND APP PASSWORD FROM CONFIGURATION FILE --------------------------------------
# Define the path to your settings file
SETTINGS_FILE = "notify_by_email_settings.txt"

# Check if the settings file exists
if not os.path.exists(SETTINGS_FILE):
    print(f"Error: The settings file '{SETTINGS_FILE}' was not found.")
    print("Please create this file in the same directory as the script with your email and app password on separate lines.")
    exit(1) # Exit the script if the file is missing

# Read email credentials from the file
try:
    with open(SETTINGS_FILE, 'r') as f:
        EMAIL_ADDRESS = f.readline().strip() # Read first line for email, remove whitespace
        APP_PASSWORD = f.readline().strip()  # Read second line for app password, remove whitespace
except Exception as e:
    print(f"Error reading settings from '{SETTINGS_FILE}': {e}")
    print("Please ensure the file contains your email on the first line and app password on the second line.")
    exit(1) # Exit if there's an error reading the file

# Ensure credentials are not empty
if not EMAIL_ADDRESS or not APP_PASSWORD:
    print(f"Error: Email address or app password found in '{SETTINGS_FILE}' is empty.")
    print("Please ensure both lines in the file contain valid credentials.")
    exit(1)



# SEND-EMAIL FUNCTION ----------------------------------------------------------------------
def send_email_notification(message_subject, message_body):
    msg = MIMEText(f"{message_body}")     # The email body
    msg['From'] = EMAIL_ADDRESS
    msg['To'] = EMAIL_ADDRESS
    msg['Subject'] = f"{message_subject}"
    

    # Send email
    try:
        server = smtplib.SMTP_SSL('smtp.gmail.com', 465)
        server.login(EMAIL_ADDRESS, APP_PASSWORD)
        server.send_message(msg)
        server.quit()
        # print("Email sent successfully!")
    except Exception as e:
        print(f"✗ Email sending failed!")
        print(f"Error details: {e}")



# MAIN FUNCTION ----------------------------------------------------------------------------
if __name__ == "__main__":
    # Setup to parse the incoming arguments
    parser = argparse.ArgumentParser(description="Send an email notification with a specified subject and body.")

    parser.add_argument(
        "subject",
        type=str,
        help="The subject of the email."
    )
    parser.add_argument(
        "body",
        type=str,
        help="The body content of the email."
    )

    args = parser.parse_args() # Parse the arguments

    # Call the function with the parsed arguments
    send_email_notification(args.subject, args.body)
