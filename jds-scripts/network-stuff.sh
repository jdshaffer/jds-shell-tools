# -------------------------------------------------------------------------------------
# Network Related Bash Scripts
# Jeffrey D. Shaffer
# Updated -- 2025-12-24
#
# Notes:
#    - "connect_to_machine" takes in the machine name and user name, then
#      asks the ip_hub_server for the given machine's IP address, then
#      it finally connects to the machine.
#    - The individual "gomba" and "gomm" functions are to set the target
#      machine name and login username
#
# -------------------------------------------------------------------------------------


alias sendIP="${HOME}/jds-programs/send_ip.sh"


getIP(){
    ${HOME}/jds-programs/get_ip.sh $1
    }



# ----------------------------------------------------------------------------------
# SSH Stuff
# ----------------------------------------------------------------------------------

# Updated to pass machine and username directly to connect_to_machine()
sshj() {
    case "$1" in
        "")
            echo ""
            echo "SSH into a local machine using its nickname"
            echo "Usage: sshj MACHINE"
            echo " "
            echo "Available Machines:"
            echo "   asus    -- Small Asus laptop"
            echo "   dm200   -- Pomera DM200"
            echo " "
            echo " "
            return 0
            ;;

       "asus")
            echo " "
            echo "Connecting to the Asus Laptop..."
            ssh2machine "asus" "user"   # Pass in "machine" and "username" as arguments
            ;;

       "dm200")
            echo " "
            echo "Connecting to the Pomera DM200..."
            ssh2machine "dm200" "user"
            ;;
    esac
    }


# Updated to take TARGET_HOST and USER_NAME as arguments
ssh2machine(){
    local TARGET_HOST="$1"   # Use local to prevent polluting global scope
    local USER_NAME="$2"     # Use local

    echo " "
    REMOTE_IP=$(${HOME}/jds-programs/get_ip.sh "${TARGET_HOST}" | tail -n 1)
    if [[ "$REMOTE_IP" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo "Successfully retrieved IP for ${TARGET_HOST} from IP-Hub: ${REMOTE_IP}"
        echo " "
    else
        echo "Error: Could not retrieve a valid IP for ${TARGET_HOST}."
        echo "Remote IP value: '${REMOTE_IP}'"
        exit 1
    fi
    }



# ----------------------------------------------------------------------------------
# SFTP Stuff
# ----------------------------------------------------------------------------------

# Updated to pass machine and username directly to sftp_to_machine()
sftpj() {
    case "$1" in
        "")
            echo ""
            echo "SFTP into a local machine using its nickname"
            echo "Usage: sftpj MACHINE"
            echo " "
            echo "Available Machines:"
            echo "   asus   -- Small Asus laptop"
            echo "   dm200  -- Pomera DM200"
            echo " "
            echo " "
            return 0
            ;;

       "asus")
            echo " "
            echo "Connecting to the Asus Laptop..."
            sftp2machine "asus" "user"
            ;;

       "dm200")
            echo " "
            echo "Connecting to the Pomera DM200..."
            sftp2machine "dm200" "user"
            ;;
    }


# Updated to take TARGET_HOST and USER_NAME as arguments
sftp2machine(){
    local TARGET_HOST="$1"
    local USER_NAME="$2"

    echo " "
    REMOTE_IP=$(${HOME}/jds-programs/get_ip.sh "${TARGET_HOST}" | tail -n 1)
    if [[ "$REMOTE_IP" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo "Successfully retrieved IP for ${TARGET_HOST} from IP-Hub: ${REMOTE_IP}"
        echo " "
    else
        echo "Error: Could not retrieve a valid IP for ${TARGET_HOST}."
        echo "Remote IP value: '${REMOTE_IP}'"
        exit 1
    fi
    }



# ----------------------------------------------------------------------------------
# update_local -- Connects to a hub computer (RasPi) and pulls down updated copies
#                 of all the files in jds-programs and jds-scripts 
# ----------------------------------------------------------------------------------

updatelocal() {
    DATA_HUB="raspi"

    case "$1" in
        "")
            echo ""
            echo "This function copies the current jds-programs and jds-scripts from the data hub (RasPi)"
            echo " "
            echo "Usage: update_local [run|show|test|clean]"
            echo " "
            echo "   updatelocal        :  Display this help message"
            echo "   updatelocal run    :  Copy the current jds-programs and jds-scripts from the data hub"
            echo "   updatelocal show   :  Display the contents of jds-programs and jds-scripts (local)"
            echo "   updatelocal test   :  Copy test files from the data hub (i.e., a test run)"
            echo "   updatelocal clean  :  Remove the test files from the local machine"
            echo " "
            return 0
            ;;


        "run")
            echo " "
            REMOTE_IP=$(${HOME}/jds-programs/get_ip.sh "${DATA_HUB}" | tail -n 1)
            if [[ "$REMOTE_IP" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                echo "Successfully retrieved IP for ${DATA_HUB} from IP-Hub: ${REMOTE_IP}"
            else
                echo "Error: Could not retrieve a valid IP for ${DATA_HUB}."
                echo "Remote IP value: '${REMOTE_IP}'"
                exit 1
            fi

            echo "----------------------------------------------"
            echo "Copying jds-programs from data hub..."
            echo "----------------------------------------------"
            scp -r jds@$REMOTE_IP:~/jds-programs/. ~/jds-programs/
            if [ $? -ne 0 ]; then
                echo "Error: Failed to copy jds-programs. Exiting."
                exit 1
            fi
            echo " "

            echo "----------------------------------------------"
            echo "Copying jds-scripts from data hub..."
            echo "----------------------------------------------"
            scp -r jds@$REMOTE_IP:~/jds-scripts/. ~/jds-scripts/
            if [ $? -ne 0 ]; then
                echo "Error: Failed to copy jds-scripts. Exiting."
                exit 1
            fi
            echo "Done."
            echo " "
            ;;


        "show")
            REMOTE_IP=$(${HOME}/jds-programs/get_ip.sh "${DATA_HUB}" | tail -n 1)
            echo " "
            echo "----------------------------------------------"
            echo "Displaying contents of jds-programs (RasPi)..."
            echo "----------------------------------------------"
            ssh jds@$REMOTE_IP "LC_ALL=C ls -al ~/jds-programs"
            echo " "
            echo " "
            echo "----------------------------------------------"
            echo "Displaying contents of jds-programs (local)..."
            echo "----------------------------------------------"
            LC_ALL=C ls -al ~/jds-programs
            echo " "
            echo " "
            echo "---------------------------------------------------------------------"
            echo " "
            echo " "
            echo "----------------------------------------------"
            echo "Displaying contents of jds-scripts (RasPi)..."
            echo "----------------------------------------------"
            ssh jds@$REMOTE_IP "LC_ALL=C ls -al ~/jds-scripts"
            echo " "
            echo " "
            echo "----------------------------------------------"
            echo "Displaying contents of jds-scripts (local)..."
            echo "----------------------------------------------"
            LC_ALL=C ls -al ~/jds-scripts
            echo " "
            echo " "
            ;;


        "test")
            echo " "
            REMOTE_IP=$(${HOME}/jds-programs/get_ip.sh "${DATA_HUB}" | tail -n 1)
            if [[ "$REMOTE_IP" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                echo "Successfully retrieved IP for ${DATA_HUB} from IP-Hub: ${REMOTE_IP}"
            else
                echo "Error: Could not retrieve a valid IP for ${DATA_HUB}."
                echo "Remote IP value: '${REMOTE_IP}'"
                exit 1
            fi

            echo "Copying jds-programs/.test_file from data hub..."
            scp -r jds@$REMOTE_IP:~/jds-programs/.test_file ~/jds-programs/.test_file
            if [ $? -ne 0 ]; then
                echo "Error: Failed to copy jds-programs. Exiting."
                exit 1
            fi

            echo "Copying jds-scripts/.test_filefrom data hub..."
            scp -r jds@$REMOTE_IP:~/jds-scripts/.test_file ~/jds-scripts/.test_file
            if [ $? -ne 0 ]; then
                echo "Error: Failed to copy jds-scripts. Exiting."
                exit 1
            fi
            echo "Done."
            echo " "
            ;;


        "clean")
            echo " "
            echo "Removing test files from jds-programs and jds-scripts..."
            rm ~/jds-programs/.test_file
            rm ~/jds-scripts/.test_file
            echo "Done."
            echo " "
            ;;
    esac
    }


