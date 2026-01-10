#!/bin/bash
# -----------------------------------------------------------------
# Webpage-to-PDF.sh
# Jeffrey D. Shaffer & Gemini
# 2025-02-02
#
# A bash script that takes in a URL and returns a PDF version of the webpage.
# Uses the Chrome engine (so Google Chrome needs to be installed)
#
# How to Use:
#    1. Save it as `Webpage-to-PDF.sh`
#    2. Make it executable: `chmod +x Webpage-to-PDF.sh`
#    3. Run it: ./Webpage-to-PDF.sh https://example.com
#
# -----------------------------------------------------------------

cd
cd $HOME/Downloads

url=$1

"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless --disable-gpu --ignore-certificate-errors --print-to-pdf="web2pdf-output.pdf" "$url"
