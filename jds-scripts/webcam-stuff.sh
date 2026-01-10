# ----------------------------------------------------------------------------------
# Webcam Related Bash Scripts
# Jeffrey D. Shaffer
# Updated -- 2025-07-03
#
# Notes:
#    - Requires a Python venv named "opencv"
#    - opencv should include the python modules "opencv-python" and "flask"
#    - These modules can be installed using
#          pip install opencv-python flask
#
# ----------------------------------------------------------------------------------


stream-webcam(){
   source $HOME/.venvs/opencv/bin/activate
   python3 $HOME/jds-programs/webcam_streamer.py 2>/dev/null   #sends camera errors to null
   deactivate
}
