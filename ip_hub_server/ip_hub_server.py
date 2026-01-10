#--------------------------------------------------------------------
# IP Hub Server -- Version 1.1
# Jeffrey D. Shaffer and Generative-AI
# 2025-12-24
#
# Notes:
#    - This python program runs a simple flask webserver
#    - The webserver receives IP information from machines on
#      the local network and stores them in an sqlite3 database
#    - The webserver also receives requests for IP information
#      from local machines, to which it looks up the desired
#      IP address and sends it back
#    - Running "getIP list" now returns a list of logged machines
#
#--------------------------------------------------------------------

import sqlite3
from flask import Flask, request, jsonify
import os
import datetime

app = Flask(__name__)
DATABASE = 'ip_addresses.db'

def init_db():
    """Initializes the database if it doesn't exist."""
    with sqlite3.connect(DATABASE) as conn:
        cursor = conn.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS devices (
                hostname TEXT PRIMARY KEY,
                ip_address TEXT NOT NULL,
                last_updated TEXT NOT NULL
            )
        ''')
        conn.commit()
    print(f"Database '{DATABASE}' initialized.")

@app.route('/report_ip', methods=['POST'])
def report_ip():
    """
    Endpoint for devices to report their current IP address.
    Expects a JSON payload: {"hostname": "mydevice", "ip_address": "192.168.1.100"}
    """
    if not request.is_json:
        return jsonify({"error": "Request must be JSON"}), 400

    data = request.get_json()
    hostname = data.get('hostname')
    ip_address = data.get('ip_address')

    if not hostname or not ip_address:
        return jsonify({"error": "Missing hostname or ip_address"}), 400

    current_time = datetime.datetime.now().isoformat()

    try:
        with sqlite3.connect(DATABASE) as conn:
            cursor = conn.cursor()
            cursor.execute('''
                INSERT OR REPLACE INTO devices (hostname, ip_address, last_updated)
                VALUES (?, ?, ?)
            ''', (hostname, ip_address, current_time))
            conn.commit()
        print(f"Reported IP: {hostname} -> {ip_address} (Last Updated: {current_time})")
        return jsonify({"message": "IP updated successfully", "hostname": hostname, "ip_address": ip_address}), 200
    except sqlite3.Error as e:
        print(f"Database error: {e}")
        return jsonify({"error": "Database error", "details": str(e)}), 500
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        return jsonify({"error": "Internal server error", "details": str(e)}), 500

@app.route('/get_ip', methods=['GET'])
def get_ip():
    """
    Endpoint to retrieve the IP address for a given hostname.
    Expects a query parameter: ?hostname=targetdevice
    """
    hostname = request.args.get('hostname')

    if not hostname:
        return jsonify({"error": "Missing hostname query parameter"}), 400

    try:
        with sqlite3.connect(DATABASE) as conn:
            cursor = conn.cursor()
            cursor.execute('SELECT ip_address, last_updated FROM devices WHERE hostname = ?', (hostname,))
            result = cursor.fetchone()

        if result:
            ip_address, last_updated = result
            print(f"Queried IP: {hostname} -> {ip_address} (Last Updated: {last_updated})")
            return jsonify({"hostname": hostname, "ip_address": ip_address, "last_updated": last_updated}), 200
        else:
            print(f"Queried IP: Hostname '{hostname}' not found.")
            return jsonify({"error": f"Hostname '{hostname}' not found"}), 404
    except sqlite3.Error as e:
        print(f"Database error: {e}")
        return jsonify({"error": "Database error", "details": str(e)}), 500
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        return jsonify({"error": "Internal server error", "details": str(e)}), 500

@app.route('/list_devices', methods=['GET'])
def list_devices():
    """
    Endpoint to list all known device hostnames.
    """
    try:
        with sqlite3.connect(DATABASE) as conn:
            cursor = conn.cursor()
            cursor.execute('SELECT hostname FROM devices ORDER BY hostname')
            results = cursor.fetchall()

        hostnames = [row[0] for row in results]

        return jsonify({"devices": hostnames}), 200

    except sqlite3.Error as e:
        return jsonify({"error": "Database error", "details": str(e)}), 500

if __name__ == '__main__':
    # Initialize the database when the application starts
    init_db()
    # Run the Flask app
    # host='0.0.0.0' makes it accessible from other devices on the network
    # port=5000 is the default Flask port, you can change it if needed
    app.run(host='0.0.0.0', port=5000)
