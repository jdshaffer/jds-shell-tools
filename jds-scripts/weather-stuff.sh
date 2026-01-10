# ----------------------------------------------------------------------------------
# Weather Related Bash Scripts
# Jeffrey D. Shaffer
# Updated -- 2025-12-26
#
# Notes:
#    - Many of these functions require a python venv named "getWX"
#    - getWX should includes the python module "requests" and
#      the terminal program "xlsx2csv"
#    - Install requests using
#          pip install requests
#    - Install xlsx2cv with
#          brew install xlsx2csv    # MacOS
#          apt  install xlsx2csv    # Linux
#
# ----------------------------------------------------------------------------------


aqi(){      # Get current air quality data from the web and calculate the AQI
    echo
    echo "---------------------------"
    echo "    Select AQI Location    "
    echo "---------------------------"
    echo "      1)  Shizuoka"
    echo "      2)  Osaka"
    echo "      3)  Nara"
    echo "      4)  Custom"
    echo 
    read -p "Choose (1-4, or Enter to quit): " choice

    case "$choice" in
        1)  # Suruga-ku, Shizuoka-shi
         	source  ${HOME}/.venvs/getWX/bin/activate
        	python3 ${HOME}/jds-programs/calculateAQIg.py
        	deactivate
            ;;

        2) # Senri-chuo, Osaka
         	source  ${HOME}/.venvs/getWX/bin/activate
        	python3 ${HOME}/jds-programs/calculateAQIg.py 34.8046758 135.4971523
        	deactivate
            ;;

        3) # Kanmaki, Nara
        	source  ${HOME}/.venvs/getWX/bin/activate
        	python3 ${HOME}/jds-programs/calculateAQIg.py 34.5670411 135.7084905
        	deactivate
            ;;

        4)
            read -p "Enter the Latitude : " LATITUDE
            read -p "Enter the Longitude: " LONGITUDE
            echo
        	source  ${HOME}/.venvs/getWX/bin/activate
        	python3 ${HOME}/jds-programs/calculateAQIg.py $LATITUDE $LONGITUDE
        	deactivate
            ;;
    esac
}


aqi-levels(){
   echo " "
   echo ".------------------------------------------------------------------. "
   echo "|      Air Quality     |   PM2.5  |   PM10   |    O3    |    AQI   | "
   echo "|----------------------|----------|----------|----------|----------| "
   echo "| Good                 |     0 >  |     0 >  |     0 >  |     0 >  | "
   echo "| Bother Sensitives    |    12 >  |    55 >  |   108 >  |    50 >  | "
   echo "| Unhealthy Sensitives |    35 >  |   155 >  |   138 >  |   100 >  | "
   echo "| Unhealthy            |    55 >  |   255 >  |   168 >  |   150 >  | "
   echo "| Very Unhealthy       |   150 >  |   355 >  |   207 >  |   200 >  | "
   echo "| Hazardous            |   250 >  |   425 >  |   393 >  |   300 >  | "
   echo "'------------------------------------------------------------------' "
   echo " "
   }


wx(){      # Get current air quality data from the web and calculate the AQI
    echo
    echo "---------------------------"
    echo "  Select Weather Location  "
    echo "---------------------------"
    echo "     1)  Shizuoka"
    echo "     2)  Osaka"
    echo "     3)  Nara"
    echo "     4)  Custom"
    echo 
    read -p "Choose (1-4, or Enter to quit): " choice

    case "$choice" in
        1)  # Suruga-ku, Shizuoka-shi
            source  ${HOME}/.venvs/getWX/bin/activate
            python3 ${HOME}/jds-programs/get_weather_terminal.py
            deactivate
            ;;

        2) # Senri-chuo, Osaka
        	source  ${HOME}/.venvs/getWX/bin/activate
        	python3 ${HOME}/jds-programs/get_weather_terminal.py 34.8046758 135.4971523
        	deactivate
            ;;

        3) # Kanmaki, Nara
        	source  ${HOME}/.venvs/getWX/bin/activate
        	python3 ${HOME}/jds-programs/get_weather_terminal.py 34.5670411 135.7084905
        	deactivate
            ;;

        4)
            read -p "Enter the Latitude : " LATITUDE
            read -p "Enter the Longitude: " LONGITUDE
            echo
        	source  ${HOME}/.venvs/getWX/bin/activate
        	python3 ${HOME}/jds-programs/get_weather_terminal.py $LATITUDE $LONGITUDE
        	deactivate
            ;;
    esac
}


pullwx(){    # Grab a copy of hourly-downloaded weather data from my local RasPi machine
   cd ${HOME}/Downloads
   echo "Fetching weather data from RasPi..."
   LOCAL_FILENAME="wx_data_$(date +"%Y-%m-%d").xlsx"
   scp jds@192.168.1.1:/home/jds/get_weather/wx_data.xlsx ${LOCAL_FILENAME}
   }


viewxlsx(){   # Convert an XLSX file to CSV and display it in the terminal
	source ${HOME}/.venvs/getWX/bin/activate
   xlsx2csv $1 > /tmp/temp_file_converted_from_xlsx.csv
	deactivate
   cat /tmp/temp_file_converted_from_xlsx.csv | column -s, -t | less -S
   echo " "
   }
