# ----------------------------------------------------------------------------------
# Terminal Related Bash Scripts
# Jeffrey D. Shaffer
# Updated -- 2026-02-11
#
# Notes:
#   - This script's name starts with an uppercase "T" to make sure it's
#     run before all the other lower-case scripts. This allows for
#     custom prompts (such as in dm200-stuff.sh) to be run later.
#
# 2026-02-11
#   - Added tmux helper functions
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


now(){   # Display the time, day, date, and monthly calendar
    echo
    date "+  %l:%M%p, %A"
    date "+  %B %e, %Y"
    echo
    cal | grep -E "\b$(date '+%e')\b| "
    }


tmuxnew(){
    if [[ -z "$1" ]]; then
        echo "Usage: tmuxnew <session-name>"
        return 1
    fi
    echo "Running: tmux new -s $1"
    tmux new -s "$1"
}


tmuxkill(){
    read -p "Kill all tmux sessions? (y/N): " ans
    [[ "$ans" == "y" ]] && tmux kill-server
    }


tmuxhelp(){
    echo
    echo ".---------------------------------------------------------."
    echo "|                  Helpful Tmux Commands                  |"
    echo "|---------------------------------------------------------|"
    echo "|  Start a new session        :   tmux new -s main        |"
    echo "|  Join a running session     :   tmux attach -t main     |"
    echo "|  Force-join a session       :   tmux attach -d -t main  |"
    echo "|  List running sessions      :   tmux ls                 |"
    echo "|                                                         |"
    echo "|  Detach from a session      :   Ctrl-b  d               |"
    echo "|  New window                 :   Ctrl-b  c               |"
    echo "|  Next / previous window     :   Ctrl-b  n / p           |"
    echo "|  Jump to window #           :   Ctrl-b  0..9            |"
    echo "|  Rename window              :   Ctrl-b  ,               |"
    echo "|  Rename session             :   Ctrl-b  $               |"
    echo "|                                                         |"
    echo "|  Split screen horizontally  :   Ctrl-b  %               |"
    echo "|  Split screen vertically    :   Ctrl-b  \"               |"
    echo "|  Kill current pane          :   Ctrl-b  x               |"
    echo "|  Kill current window        :   Ctrl-b  &               |"
    echo "|                                                         |"
    echo "|  Move between panes         :   Ctrl-b  ← ↑ ↓ →         |"
    echo "|  Resize pane                :   Ctrl-b  Ctrl-arrow      |"
    echo "|  Scroll / copy mode        :   Ctrl-b  [               |"
    echo "|                                                         |"
    echo "|  Exit a session             :   exit                    |"
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


winterbear(){
   cd ~/jds-programs
   ./shutdown_after_charge.sh
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
