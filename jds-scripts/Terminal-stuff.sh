# ----------------------------------------------------------------------------------
# Terminal Related Bash Scripts
# Jeffrey D. Shaffer
# Updated -- 2026-01-11
#
# Notes:
#   - This script's name starts with an uppercase "T" to make sure it's
#     run before all the other lower-case scripts. This allows for
#     custom prompts (such as in dm200-stuff.sh) to be run later.
#
# 2025-12-25 -- Added "ambient", a menu of some relaxing-to-watch 
#               terminal commands (add "watch" on macos with
#               "brew install watch"), and added macos commands 
#               to ambient, but will also need to add htop with 
#               "brew install htop"
# 2026-01-11 -- Updated ambient to loop
#            -- Prettified screen-help and ambient with boxes
#
# ----------------------------------------------------------------------------------


commands(){   # Lists all of the user loaded bash aliases and functions
    echo " "
    echo "--------------------------------------------------"
    echo "  Personal aliases and functions loaded at login  "
    echo "--------------------------------------------------"
   (
    # Get function names currently defined in the shell
    # Only search files that exist
    for f in \
        "${HOME}/.bash_aliases" \
        "${HOME}/jds-scripts"/*.sh; do              # Ensure this path is correct
        if [[ -f "$f" ]]; then
            # Find function definitions within files and extract name
            grep -Eo '^[[:space:]]*(function[[:space:]]+)?([a-zA-Z0-9_-]+)[[:space:]]*\(\)[[:space:]]*($|[[:space:]]*\{)' "$f" | \
            sed -E 's/^[[:space:]]*(function[[:space:]]+)?([a-zA-Z0-9_-]+)[[:space:]]*\(\)[[:space:]]*($|[[:space:]]*\{)/\2/'

            # Find alias definitions within files (if not already covered by 'alias' command)
          # grep -Eo '^[[:space:]]*alias[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*=' "$f" | sed -E 's/^\s*alias\s*([^=]+)=.*$/\1/'
          # grep -Eo '^[[:space:]]*alias[[:space:]]+([a-zA-Z0-9_-]+)=' "$f" | sed -E 's/^[[:space:]]*alias[[:space:]]+([^=]+)=.+/\1/'

            grep -Eo '^[[:space:]]*alias[[:space:]]+([a-zA-Z0-9_-]+)=' "$f" | \
            sed -E 's/^[[:space:]]*alias[[:space:]]+([a-zA-Z0-9_-]+)=.*/\1/'

        fi
    done
    ) | sort -u | column -x
    echo " "
    }


mkcd(){   #M ake a directory and cd into it
  \mkdir -p "$1"
  cd "$1"
}


now(){   # Display the time, day, date, and monthly calendar
    echo
    date "+  %l:%M%p, %A"
    date "+  %B %e, %Y"
    echo
    cal | grep -E "\b$(date '+%e')\b| "
}


screen-help(){
    echo
    echo ".---------------------------------------------------------."
    echo "|                 Helpful Screen Commands                 |"
    echo "|---------------------------------------------------------|"
    echo "|  Start a new screen      :   screen -S <session_name>   |"
    echo "|  Detatch from a screen   :   Ctrl-A, D                  |"
    echo "|  List running screens    :   screen -ls                 |"
    echo "|  Rejoin a running screen :   screen -r <session_name>   |"
    echo "'---------------------------------------------------------'"
    echo
    }


ambient(){
    while true; do
        echo
        echo ".-----------------------------------------."
        echo "|         Ambient Terminal Modes          |"
        echo "|-----------------------------------------|"
        echo "|  1) Time passing       (date)           |"
        echo "|  2) System heartbeat   (uptime)         |"
        echo "|  3) Memory breathing   (/proc/meminfo)  |"
        echo "|  4) Virtual Memory     (vmstat)         |"
        echo "|  5) Network trickle    (proc/net/dev)   |"
        echo "|  6) CPU weather        (htop)           |"
        echo "'-----------------------------------------'"
        echo
        read -p "Choose 1-6 or Enter to quit: " choice

        case "$choice" in
          1) watch -d -n 1 date ;;
          2) watch -d -n 1 uptime ;;
          3) if [ "$machine_name" = "mm" ] || [ "$machine_name" = "mba" ]; then
              watch -d -n 1 "vm_stat | egrep 'Pages free|Pages active|Pages inactive|Pages wired'"
            else
              watch -d -n 1 "cat /proc/meminfo"
            fi ;;
          4) if [ "$machine_name" = "mm" ] || [ "$machine_name" = "mba" ]; then
              vm_stat 1
            else
              vmstat 1
            fi ;;
          5) if [ "$machine_name" = "mm" ] || [ "$machine_name" = "mba" ]; then
              watch -d -n 1 "netstat -ib | awk 'NR>1 && \$7 ~ /[0-9]/ {printf \"%-8s   RX:%10d     TX:%10d\n\", \$1, \$7, \$10}'"
            else
              watch -d -n 1 "awk 'NR>2 {printf \"%-8s   RX:%10d     TX:%10d\n\", \$1, \$2, \$10}' /proc/net/dev"
            fi ;;

          6) htop ;;
          *) return 0 ;;
        esac
    done
    }


alias c="clear"


alias ll="ls -al"


alias fish="asciiquarium"     # brew install asciiquarium


# ----------------------------------------------------------------------------------
# Nicer Terminal Colors
# ----------------------------------------------------------------------------------
export CLICOLOR=1
export LSCOLORS=exfxcxdxbxegedabagacad
export PS1="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\W\[\033[m\]$ "
