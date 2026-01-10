# ----------------------------------------------------------------------------------
# Download Related Bash Scripts
# Jeffrey D. Shaffer
# Updated -- 2025-06-20
#
# Notes:
#    - These functions require the program yt-dlp
#    - yt-dlp can be installed via the terminal
#          brew install yt-dlp   # MacOS
#          apt  install yt-dlp   # Linux
#
# ----------------------------------------------------------------------------------


downloadmp3(){      # Download the given YouTube video as an MP3 file
    echo " "
    cd ${HOME}/Downloads
    echo "Downloading YouTube as MP3..."
    yt-dlp -x --audio-format mp3 "$1"
    echo " "
    }


downloadmp4(){      # Download the given YouTube video as an MP4 file
    echo " "
    cd ${HOME}/Downloads
    echo "Downloading YouTube as MP4..."
    yt-dlp -f "bv*[vcodec^=avc]+ba[ext=m4a]/b[ext=mp4]/b" "$1"
    echo " "
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


grabtrans(){       # Download YouTube video transcript to a file called "transcript.txt"
    echo " "
    cd ${HOME}/Downloads
    echo "Downloading YouTube Transcript..."
    yt-dlp --skip-download --write-subs --write-auto-subs --sub-lang en --sub-format ttml --convert-subs srt --output "transcript.%(ext)s" "$1" && sed -i '' -e '/^[0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9] --> [0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9]$/d' -e '/^[[:digit:]]\{1,4\}$/d' -e 's/<[^>]*>//g' ./transcript.en.srt && sed -e 's/<[^>]*>//g' -e '/^[[:space:]]*$/d' transcript.en.srt > transcript.txt && rm transcript.en.srt
    open transcript.txt
    echo " "
    }


summary(){         # Summarize the contents of a YouTube video using the transcripts and Ollama
    echo " "
    cd ${HOME}/Downloads
    echo "Downloading YouTube Transcript..."
    yt-dlp --skip-download --write-subs --write-auto-subs --sub-lang en --sub-format ttml --convert-subs srt --output "transcript.%(ext)s" "$1" && sed -i '' -e '/^[0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9] --> [0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9]$/d' -e '/^[[:digit:]]\{1,4\}$/d' -e 's/<[^>]*>//g' ./transcript.en.srt && sed -e 's/<[^>]*>//g' -e '/^[[:space:]]*$/d' transcript.en.srt > transcript.txt && rm transcript.en.srt
    echo " "
    echo "Sharing the transcript with Ollama..."
    ollama run gemma3:4b "Can you summarize this please?" < transcript.txt > summary.txt
    rm transcript.txt
	more summary.txt
    echo " "
    }


say-summ(){         # Have the terminal read the video summary aloud
    echo " "
    cd ${HOME}/Downloads
    echo "Downloading YouTube Transcript..."
    yt-dlp --skip-download --write-subs --write-auto-subs --sub-lang en --sub-format ttml --convert-subs srt --output "transcript.%(ext)s" "$1" && sed -i '' -e '/^[0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9] --> [0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9]$/d' -e '/^[[:digit:]]\{1,4\}$/d' -e 's/<[^>]*>//g' ./transcript.en.srt && sed -e 's/<[^>]*>//g' -e '/^[[:space:]]*$/d' transcript.en.srt > transcript.txt && rm transcript.en.srt
    echo " "
    echo "Sharing the transcript with Ollama..."
    ollama run gemma3:4b "Can you summarize this please?" < transcript.txt > summary.txt
    rm transcript.txt
    say < summary.txt
    echo " "
    }

