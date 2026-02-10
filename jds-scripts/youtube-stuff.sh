# ----------------------------------------------------------------------------------
# YouTube Related Bash Scripts
# Jeffrey D. Shaffer
# Updated -- 2026-02-11
#
# Notes:
#    - These functions require the program yt-dlp
#    - yt-dlp can be installed via the terminal
#          brew install yt-dlp   # MacOS
#          apt  install yt-dlp   # Linux
#    - ytmusic depents on the program mpv 
#          brew install mpv      # MacOS
#
# ----------------------------------------------------------------------------------


downloadmp3(){      # Download the given YouTube video as an MP3 file
    echo
    cd ${HOME}/Downloads
    echo "Downloading YouTube as MP3..."
    yt-dlp -x --audio-format mp3 "$1"
    echo
    }


downloadmp4(){      # Download the given YouTube video as an MP4 file
    echo
    cd ${HOME}/Downloads
    echo "Downloading YouTube as MP4..."
    yt-dlp -f "bv*[vcodec^=avc]+ba[ext=m4a]/b[ext=mp4]/b" "$1"
    echo
    }


ytmusic() {
    set +m   # disable job completion messages
    
    local timer=""
    local duration=0
    local url

    # --- parse optional -t flag ---
    if [[ "$1" == "-t" ]]; then
        timer="$2"
        shift 2
        url="$1"

        case "$timer" in
            *h) duration=$(( ${timer%h} * 3600 )) ;;
            *m) duration=$(( ${timer%m} * 60 )) ;;
            *s) duration=${timer%s} ;;
            *)  duration=$timer ;;
        esac
    else
        url="$1"
    fi

    echo
    echo "Connecting to YouTube and opening audio stream..."
    echo "(Tip: Use the -t flag to set a stop timer!)"
    echo

    if [[ $duration -gt 0 ]]; then
        (
            # wait until mpv starts and grab its PID
            while true; do
                mpv_pid=$(pgrep -n mpv)
                [[ -n "$mpv_pid" ]] && break
                sleep 0.2
            done

            sleep "$duration"
            echo
            echo "The timer has finishd. Stopping playback..."
            kill -TERM "$mpv_pid" 2>/dev/null
        ) & disown
    fi

    # --- run mpv as normal ---
    mpv --no-video "$url"
    
    echo
    }


web2pdf(){          # Save the given URL as a PDF file
    echo " "
    cd ${HOME}/Downloads
    ${HOME}/jds-programs/Webpage-to-PDF.sh "$1"
    open web2pdf-output.pdf
    echo " "
    }


web2txt(){          # Save the given URL as a TXT file
    echo " "
    cd ${HOME}/Downloads
    lynx -dump "$1" > web2txt-output.txt
    open web2txt-output.txt
    echo " "
    }
