#!/bin/bash
# ----------------------------------------------------------------------------------
# Logging Related Bash Scripts
# Jeffrey D. Shaffer
# 2026-01-11
#
# A simple terminal tool to help me learn more about my local systems.
# Yes, I like boxes around things. *laugh*
#
# 2026-01-13 -- Added the ability to reset (delete) journalctl logs, with a
#               confirmation dialog.
#
# ----------------------------------------------------------------------------------



logs(){
    echo
    echo "   .----------------------."
    echo "   |     Logging Style    |"
    echo "   |----------------------|"
    echo "   |   1) Classic Linux   |"
    echo "   |   2) Journalctl      |"
    echo "   |   3) MacOS           |"
    echo "   '----------------------'"
    echo
    read -p "Choose 1-3 or Enter to Quit: " choice
    case "$choice" in
        1)
            echo
            echo ".-----------------------------------------------------------------------."
            echo "|                     Classic Linux Logging Commands                    |"
            echo "|-----------------------------------------------------------------------|"
            echo "|  1) All logs (live)         tail -f /var/log/syslog                   |"
            echo "|  2) Kernel Messages         tail -f /var/log/kern.log                 |"
            echo "|  3) Authentication Logs     tail -f /var/log/auth.log                 |"
            echo "|  4) System Messages         tail -f /var/log/messages                 |"
            echo "|  5) Dmesg (boot messages)   dmesg                                     |"
            echo "|  6) Dmesg (live)            dmesg --follow                            |"
            echo "|  7) Failed SSH logins       grep 'Failed password' /var/log/auth.log  |"
            echo "|  8) Successful SSH logins   grep 'Accepted' /var/log/auth.log         |"
            echo "'-----------------------------------------------------------------------'"
            echo
            read -p "Choose 1-10 or Enter to quit: " subchoice
            case "$subchoice" in
                1) tail -f /var/log/syslog;;
                2) tail -f /var/log/kern.log;;
                3) tail -f /var/log/auth.log;;
                4) tail -f /var/log/messages;;
                5) dmesg;;
                6) dmesg --follow;;
                7) grep "Failed password" /var/log/auth.log;;
                8) grep "Accepted" /var/log/auth.log;;
                *) echo
                 return 0;;
            esac ;;
        2)
            echo
            echo ".---------------------------------------------------------------."
            echo "|                 journalctl Logging Commands                   |"
            echo "|---------------------------------------------------------------|"
            echo "|  1) All logs (live)          journalctl -f                    |"
            echo "|  2) Logs Since Boot          journalctl -b                    |"
            echo "|  3) Successful Logins        journalctl -u ssh -g \"Accepted\"  |"
            echo "|  4) Failed Logins            journalctl -g \"Failed password\"  |"
            echo "|  5) SSH Logs                 journalctl -u ssh                |"
            echo "|  6) Sudo Usage Logs          journalctl -t sudo               |"
            echo "|  7) Kernel Messages          journalctl -k                    |"
            echo "|  8) Kernel Messages (live)   journalctl -kf                   |"
            echo "|  9) Errors and Warnings      journalctl -p warning            |"
            echo "| 10) Boot Errors              journalctl -b -p err             |"
            echo "| 11) Reset Logs               (USE WITH CAUTION)               |"
            echo "'---------------------------------------------------------------'"
            echo
            read -p "Choose 1-11 or Enter to quit: " subchoice
            case "$subchoice" in
                1) journalctl -f;;
                2) journalctl -b;;
                3) journalctl -u ssh -g "Accepted";;
                4) journalctl -g "Failed password";;
                5) journalctl -u ssh;;
                6) journalctl -t sudo;;
                7) journalctl -k;;
                8) journalctl -kf;;
                9) journalctl -p warning;;
                10) journalctl -b -p err;;
                11)
                    echo
                    echo "Are you sure you want to reset all logs?"
                    read -p "Press 1 for yes, any other key to cancel: " deletechoice
                    case "$deletechoice" in
                        1)
                           sudo dmesg -C
                           sudo systemctl restart systemd-journald
                           sudo journalctl --rotate
                           sudo journalctl --vacuum-time=1s
                           echo
                           echo "Logs have been reset."
                           echo;;
                        *) echo
                           echo "Reset Cancelled. (Logs have not been touched.)"
                           echo
                           return 0;;
                    esac ;;
                *) echo
                 return 0;;
            esac ;;
        3)
            echo
            echo ".----------------------------------------------------------------------------------------."
            echo "|                                 MacOS Logging Commands                                 |"
            echo "|----------------------------------------------------------------------------------------|"
            echo "|  1) All logs (live)          log stream                                                |"
            echo "|  2) Kernel Messages (live)   log stream --predicate 'subsystem == \"com.apple.kernel\"'  |"
            echo "|  3) Authentication Logs      log stream --predicate 'eventMessage contains \"auth\"'     |"
            echo "|  4) System.log (live)        tail -f /var/log/system.log                               |"
            echo "|  5) Dmesg                    sudo dmesg                                                |"
            echo "|  6) Dmesg (live)             sudo dmesg -w                                             |"
            echo "|  7) Failed SSH logins        grep 'Failed password' /var/log/system.log                |"
            echo "|  8) Successful SSH logins    grep 'Accepted' /var/log/system.log                       |"
            echo "'----------------------------------------------------------------------------------------'"
            echo
            read -p "Choose 1-10 or Enter to quit: " choice
            case "$choice" in
                1) log stream;;
                2) log stream --predicate 'subsystem == "com.apple.kernel"' ;;
                3) log stream --predicate 'eventMessage contains "auth"' ;;
                4) tail -f /var/log/system.log;;
                5) sudo dmesg;;
                6) sudo dmesg -w;;
                7) grep "Failed password" /var/log/system.log;;
                8) grep "Accepted" /var/log/system.log;;
                *) echo
                   return 0;;
            esac;;
        *) return 0 ;;
    esac
}
