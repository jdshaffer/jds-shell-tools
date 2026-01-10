#--------------------------------------------------------------------------------------
# CalculateAQI (Google API)
# Jeffrey D. Shaffer and Gemini
# Updated 2025-07-13
#
# A simple python program that grabs the current air quality data for
# Shizuoka, Japan, calculates the AQI, then returns the AQI and air particulate data
#
# Note -- A Google API Key is needed for this to work...
#
#--------------------------------------------------------------------------------------

import json
import requests
import sys

# CONFIGURATION
GOOGLE_API_KEY = ""
# SHIZUOKA STATION, SHIZUOKA-SHI, SHIZUOKA-KEN, JAPAN
DEFAULT_LATITUDE = 34.9717465
DEFAULT_LONGITUDE = 138.378599


# Take in the data from the API call (data_list) and return the requested pollutant's (code) concentration
def get_pollutant_value(data_list, code):
    for pollutant in data_list:
        if pollutant.get('code') == code:
            return pollutant.get('concentration', {}).get('value')
    return None


def calculate_aqi_from_data(pollutants_data):
    pollutants_data = api_data.get('pollutants', [])

    # Get each pollutant's value from the pollutants_data using a helper function
    pm2_5_ugm3 = get_pollutant_value(pollutants_data, "pm25")
    pm10_ugm3 = get_pollutant_value(pollutants_data, "pm10")
    carbon_monoxide_ugm3 = get_pollutant_value(pollutants_data, "co") / 0.873   # convert ppb to ugm3
    nitrogen_dioxide_ugm3 = get_pollutant_value(pollutants_data, "no2") / 0.532 # convert ppb to ugm3
    sulphur_dioxide_ugm3 = get_pollutant_value(pollutants_data, "so2") / 0.375  # convert ppb to ugm3
    ozone_ugm3 = get_pollutant_value(pollutants_data, "o3") / 0.5               # convert ppb to ugm3

    # Store all pollutant values in a dictionary to return them
    pollutant_data = {
        "pm2_5": pm2_5_ugm3,
        "carbon_monoxide": carbon_monoxide_ugm3,
        "nitrogen_dioxide": nitrogen_dioxide_ugm3,
        "sulphur_dioxide": sulphur_dioxide_ugm3,
        "ozone": ozone_ugm3,
        "pm10": pm10_ugm3,
    }

    # --- Conversion Factors (approximate, at 25°C and 1 atm) ---
    # CO: 1 μg/m³ = 0.873 ppb (1 mg/m³ = 0.873 ppm)
    # NO2: 1 μg/m³ = 0.532 ppb
    # SO2: 1 μg/m³ = 0.375 ppb
    # Ozone: 1 μg/m³ = 0.5 ppb

    # --- US EPA AQI Breakpoints (Concentration Hi/Lo and AQI Hi/Lo) ---
    # Structure: { pollutant_name: [(C_Lo, C_Hi, I_Lo, I_Hi), ...] }
    aqi_breakpoints = {
        "pm2_5": [
            (0.0, 12.0, 0, 50),
            (12.1, 35.4, 51, 100),
            (35.5, 55.4, 101, 150),
            (55.5, 150.4, 151, 200),
            (150.5, 250.4, 201, 300),
            (250.5, 350.4, 301, 400),
            (350.5, 500.4, 401, 500),
        ],
        "pm10": [
            (0, 54, 0, 50),
            (55, 154, 51, 100),
            (155, 254, 101, 150),
            (255, 354, 151, 200),
            (355, 424, 201, 300),
            (425, 504, 301, 400),
            (505, 604, 401, 500),
        ],
        "carbon_monoxide": [ # in ppm
            (0.0, 4.4, 0, 50),
            (4.5, 9.4, 51, 100),
            (9.5, 12.4, 101, 150),
            (12.5, 15.4, 151, 200),
            (15.5, 30.4, 201, 300),
            (30.5, 40.4, 301, 400),
            (40.5, 50.4, 401, 500),
        ],
        "nitrogen_dioxide": [ # in ppb (1-hour average, used for AQI only if 1-hour ozone is not available or very high)
            (0, 53, 0, 50),
            (54, 100, 51, 100),
            (101, 360, 101, 150),
            (361, 649, 151, 200),
            (650, 1249, 201, 300),
            (1250, 1649, 301, 400),
            (1650, 2049, 401, 500),
        ],
        "sulphur_dioxide": [ # in ppb (1-hour average)
            (0, 35, 0, 50),
            (36, 75, 51, 100),
            (76, 185, 101, 150),
            (186, 304, 151, 200),
            (305, 604, 201, 300),
            (605, 804, 301, 400),
            (805, 1004, 401, 500),
        ],
        "ozone": [ # in ppb (8-hour average for 0-100, 1-hour for higher)
            (0, 54, 0, 50),
            (55, 70, 51, 100),
            (71, 85, 101, 150),
            (86, 105, 151, 200),
            (106, 200, 201, 300),
        ],
    }

    def get_aqi_category(aqi_value):
        if   aqi_value >= 300: return "Hazardous"
        elif aqi_value >= 200: return "Very Unhealthy"
        elif aqi_value >= 150: return "Unhealthy"
        elif aqi_value >= 100: return "Unhealthy for Sensitive Groups"
        elif aqi_value >=  50: return "Bothers Sensitive Groups"
        elif aqi_value >=   0: return "Good"
        else: return "Unknown"

    def calculate_sub_aqi(pollutant_value, pollutant_type):
        if pollutant_value is None:
            return 0 # Handle as missing data

        breakpoints = aqi_breakpoints.get(pollutant_type)
        if not breakpoints:
            return 0 # Unknown pollutant type

        # Find the correct breakpoint range
        for C_Lo, C_Hi, I_Lo, I_Hi in breakpoints:
            # Check if value is within the segment
            if C_Lo <= pollutant_value <= C_Hi:
                # Linear interpolation formula
                if C_Hi == C_Lo: # Avoid division by zero if range is single point
                    return I_Lo
                aqi_sub = ((I_Hi - I_Lo) / (C_Hi - C_Lo)) * (pollutant_value - C_Lo) + I_Lo
                return round(aqi_sub)
            # If the value is above the highest breakpoint, cap it at 500 or extrapolate beyond
            # For simplicity, if it's beyond the last defined highest point, we'll mark as 501 (Hazardous)
            elif pollutant_value > breakpoints[-1][1] and (C_Hi == breakpoints[-1][1]):
                # This simple cap is a common practice for values far beyond the "Hazardous" scale.
                return 501 # Indicate value is in "Beyond AQI" or "Hazardous"
        return 0 # Should not happen if breakpoints cover all ranges, but as a safeguard

    # --- Convert and Calculate Sub-AQIs ---
    sub_aqis = []

    if pm2_5_ugm3 is not None:
        sub_aqis.append(calculate_sub_aqi(pm2_5_ugm3, "pm2_5"))

    if pm10_ugm3 is not None:
        sub_aqis.append(calculate_sub_aqi(pm10_ugm3, "pm10"))

    if carbon_monoxide_ugm3 is not None:
        # Convert μg/m³ to ppm for CO
        co_ppm = carbon_monoxide_ugm3 * (0.873 / 1000)
        sub_aqis.append(calculate_sub_aqi(co_ppm, "carbon_monoxide"))

    if nitrogen_dioxide_ugm3 is not None:
        # Convert μg/m³ to ppb for NO2
        no2_ppb = nitrogen_dioxide_ugm3 * 0.532
        sub_aqis.append(calculate_sub_aqi(no2_ppb, "nitrogen_dioxide"))

    if sulphur_dioxide_ugm3 is not None:
        # Convert μg/m³ to ppb for SO2
        so2_ppb = sulphur_dioxide_ugm3 * 0.375
        sub_aqis.append(calculate_sub_aqi(so2_ppb, "sulphur_dioxide"))

    if ozone_ugm3 is not None:
        # Convert μg/m³ to ppb for Ozone
        o3_ppb = ozone_ugm3 * 0.5
        sub_aqis.append(calculate_sub_aqi(o3_ppb, "ozone"))

    # The overall AQI is the maximum of the individual sub-indices
    final_aqi = max(sub_aqis) if sub_aqis else 0
    category = get_aqi_category(final_aqi)

    return final_aqi, category, pollutant_data


def get_pm2_5_category(pm2_5_value):
    if   pm2_5_value >= 250: return "Hazardous"
    elif pm2_5_value >= 150: return "Very Unhealthy"
    elif pm2_5_value >=  55: return "Unhealthy"
    elif pm2_5_value >=  35: return "Unhealthy for Sensitive Groups"
    elif pm2_5_value >=  12: return "Bothers Sensitive Groups"
    elif pm2_5_value >=   0: return "Good"
    else: return "Unknown"


def get_pm10_category(pm10_value):
    if   pm10_value >= 425: return "Hazardous"
    elif pm10_value >= 355: return "Very Unhealthy"
    elif pm10_value >= 255: return "Unhealthy"
    elif pm10_value >= 155: return "Unhealthy for Sensitive Groups"
    elif pm10_value >=  55: return "Bothers Sensitive Groups"
    elif pm10_value >=   0: return "Good"
    else: return "Unknown"

    
def get_ozone_category(ozone_value):
    if   ozone_value >= 393: return "Hazardous"
    elif ozone_value >= 207: return "Very Unhealthy"
    elif ozone_value >= 168: return "Unhealthy"
    elif ozone_value >= 138: return "Unhealthy for Sensitive Groups"
    elif ozone_value >= 108: return "Bothers Sensitive Groups"
    elif ozone_value >=   0: return "Good"
    else: return "Unknown"
    
# --- Main execution block to fetch data and calculate AQI ---
if __name__ == "__main__":
    # Check if custom latitude and longitude are given at the command line
    if len(sys.argv) == 3:
        try:
            LATITUDE = float(sys.argv[1])
            LONGITUDE = float(sys.argv[2])
            print("")
            print(f"Looking up the air quality for latitude {LATITUDE} and longitude {LONGITUDE}...")
        except ValueError:
            print("")
            print("Invalid latitude or longitude. Please provide numerical values.")
            print(f"Usage: python3 {sys.argv[0]} [latitude] [longitude]")
            sys.exit(1) # Exit with an error code
    elif len(sys.argv) == 1:
        print("")
        print(f"Looking up the air quality for latitude {DEFAULT_LATITUDE} and longitude {DEFAULT_LONGITUDE}...")
        LATITUDE = DEFAULT_LATITUDE
        LONGITUDE = DEFAULT_LONGITUDE
    else:
        print("")
        print("Incorrect number of arguments.")
        print(f"Usage: python3 {sys.argv[0]} [latitude] [longitude]")
        sys.exit(1) # Exit with an error code

    api_url = f"https://airquality.googleapis.com/v1/currentConditions:lookup?key={GOOGLE_API_KEY}"

    headers = {
        "Content-Type": "application/json"
    }

    data = {
        "universalAqi": False,
        "location": {
            "latitude": LATITUDE,
            "longitude": LONGITUDE
        },
        "extraComputations": [
            "POLLUTANT_CONCENTRATION" # We only need pollutant concentrations
        ],
        "languageCode": "en"
    }

    # Make the POST request to the API
    response = requests.post(url=api_url, headers=headers, data=json.dumps(data))
    response.raise_for_status() # Raise an exception for HTTP errors (4xx or 5xx)

    # Save the response
    api_data = response.json()

    # Send the aqi_data to a helper function that returns the aqi value, aqi category, and pollutant data
    aqi_value, aqi_category, pollutant_data = calculate_aqi_from_data(api_data)
    
    # Calculate PM2.5, PM10, and O3 categories
    pm2_5_category = get_pm2_5_category(pollutant_data.get('pm2_5'))
    pm10_category  = get_pm10_category(pollutant_data.get('pm10'))
    ozone_category = get_ozone_category(pollutant_data.get('ozone'))
    
    # Display results in an easy-to-read format
    print(f" ")
    print(f"----------------------------------------------------------------")
    print(f"                    Current Air Quality Data                    ")
    print(f"----------------------------------------------------------------")
    print(f"PM 2.5   {pollutant_data.get('pm2_5'): >7.0f}   µg/m³       {pm2_5_category}")
    print(f"PM 10    {pollutant_data.get('pm10' ): >7.0f}   µg/m³       {pm10_category}")
    print(f"Ozone    {pollutant_data.get('ozone'): >7.0f}   µg/m³       {ozone_category}")
    print(f"----------------------------------------------------------------")
    print(f"AQI           {aqi_value:<4}             {aqi_category}")
    print(f"----------------------------------------------------------------")
    print(f" ")
