#################################################################################################
# Get Weather (for Terminal) -- Version 1.0
# Jeffrey D. Shaffer
# 2025-07-13
#
#################################################################################################
# This simplified version of "Get Weather" fetches the current weather conditions
# for the hard-coded latitude and longitude (Shizuoka Station, Shizuoka-shi)
# and displays it nicely in the terminal.
#
# No API key is necessary.
#
#################################################################################################

import requests
import sys


# CONFIGURATION FOR WEATHER API (Open-Metro https://open-meteo.com/en/docs/jma-api)
DEFAULT_LATITUDE = '34.9717465'
DEFAULT_LONGITUDE = '138.378599'


# Function to convert wind direction (degrees) to compass directions
def convert_wind_to_compass(wind_dir):
    if wind_dir >= 0 and wind_dir < 22.5:
        return "N"
    elif wind_dir >= 22.5 and wind_dir < 45:
        return "NNE"
    elif wind_dir >= 45 and wind_dir < 67.5:
        return "NE"
    elif wind_dir >= 67.5 and wind_dir < 90:
        return "ENE"
    elif wind_dir >= 90 and wind_dir < 112.5:
        return "E"
    elif wind_dir >= 112.5 and wind_dir < 135:
        return "ESE"
    elif wind_dir >= 135 and wind_dir < 157.5:
        return "SE"
    elif wind_dir >= 157.5 and wind_dir < 180:
        return "SSE"
    elif wind_dir >= 180 and wind_dir < 202.5:
        return "S"
    elif wind_dir >= 202.5 and wind_dir < 225:
        return "SSW"
    elif wind_dir >= 225 and wind_dir < 247.5:
        return "SW"
    elif wind_dir >= 247.5 and wind_dir < 270:
        return "WSW"
    elif wind_dir >= 270 and wind_dir < 292.5:
        return "W"
    elif wind_dir >= 292.5 and wind_dir < 315:
        return "WNW"
    elif wind_dir >= 315 and wind_dir < 337.5:
        return "NW"
    elif wind_dir >= 337.5 and wind_dir < 360:
        return "NNW"
    elif wind_dir == 360:
        return "N"
    else: # Handle potential unexpected values
        return "Unknown"



# Main function to get weather data and display it
if __name__ == '__main__':

    # Check if custom latitude and longitude are given at the command line
    if len(sys.argv) == 3:
        try:
            LATITUDE = float(sys.argv[1])
            LONGITUDE = float(sys.argv[2])
            print("")
            print(f"Looking up the weather for latitude {LATITUDE} and longitude {LONGITUDE}...")
        except ValueError:
            print("")
            print("Invalid latitude or longitude. Please provide numerical values.")
            print(f"Usage: python3 {sys.argv[0]} [latitude] [longitude]")
            sys.exit(1) # Exit with an error code
    elif len(sys.argv) == 1:
        print("")
        print(f"Looking up the weather for latitude {DEFAULT_LATITUDE} and longitude {DEFAULT_LONGITUDE}...")
        LATITUDE = DEFAULT_LATITUDE
        LONGITUDE = DEFAULT_LONGITUDE
    else:
        print("")
        print("Incorrect number of arguments.")
        print(f"Usage: python3 {sys.argv[0]} [latitude] [longitude]")
        sys.exit(1) # Exit with an error code


    WEATHER_API_URL = f'https://api.open-meteo.com/v1/forecast?latitude={LATITUDE}&longitude={LONGITUDE}&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,cloud_cover,surface_pressure,wind_speed_10m,wind_direction_10m&timezone=Asia%2FTokyo&models=jma_seamless'

    # Fetch weather data
    weather_data = None
    try:
        response_weather = requests.get(WEATHER_API_URL)
        response_weather.raise_for_status()
        weather_data = response_weather.json()
    except requests.exceptions.RequestException as e:
        print(f"Error fetching weather data: {e}")

    if weather_data:
        # Grab individual values from python dictionary
        current_weather = weather_data['current']
        temp_c = current_weather['temperature_2m']
        feels_like_c = current_weather['apparent_temperature']
        humidity_percent = current_weather['relative_humidity_2m']
        pressure_hpa = current_weather['surface_pressure']
        wind_speed_kph = current_weather['wind_speed_10m']
        wind_direction_deg = current_weather['wind_direction_10m']
        wind_direction_deg = current_weather['wind_direction_10m']
        cloud_cover_percent = current_weather['cloud_cover']
        precipitation_mm = current_weather['precipitation']
        
        # Print everything prettily to the terminal
        print(f" ")
        print(f"-----------------------------------")
        print(f"    Current Weather Conditions    ")
        print(f"-----------------------------------")
        print(f"   Temperature    :  {temp_c:>6}  °C")
        print(f"   Feels Like     :  {feels_like_c:>6}  °C")
        print(f"   Humidity       :  {humidity_percent:>6}  %")
        print(f"   Pressure       :  {pressure_hpa:>6}  hPa")
        print(f"   Wind Speed     :  {(wind_speed_kph * (1000 / 3600)):>6.1f}  mps")
        print(f"   Wind Direction :  {convert_wind_to_compass(wind_direction_deg):>6}")
        print(f"   Cloud Coverage :  {cloud_cover_percent:>6}  %")
        print(f"   Precipitation  :  {precipitation_mm:>6}  mm")
        print(f"-----------------------------------")
        print(f" ")
