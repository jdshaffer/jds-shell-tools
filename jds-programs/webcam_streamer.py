#-----------------------------------------------------------------------
# Webcam-Streamer -- v1.2
# Jeffrey D. Shaffer & Gemini
# 2025-07-25
#
# Notes:
#    - Broadcasts the default webcam via a webserver at this address:
#         http://<DEVICE_IP_ADDRESS>:8080
#    - Requires the "opencv-python" and "flask" python modules:
#         pip install opencv-python flask
#    - Also requires special permission for the user to access video:
#         sudo usermod -a -G video $USER
#
#-----------------------------------------------------------------------


import cv2
from flask import Flask, Response

app = Flask(__name__)


# --- Configuration for Webcam ---
WEBCAM_INDEX      =    0   # Default webcam = 0
RESOLUTION_WIDTH  = 1280
RESOLUTION_HEIGHT = 1024
FRAMERATE         =   30
EXPOSURE          =  -12   # Between -10 and -12 are good for outdoors


# Capture frames from the webcam and encode them
def generate_frames():
    cap = cv2.VideoCapture(WEBCAM_INDEX)

    if not cap.isOpened():
        print(f"Error: Could not open webcam at index {WEBCAM_INDEX}. Make sure it's connected and not in use by another application.")
        yield (b'--frame\r\n'
               b'Content-Type: text/plain\r\n\r\n'
               b'Error: Webcam not accessible.\r\n')
        return

    # Set preferred Codec before setting resolution and framerate
    cap.set(cv2.CAP_PROP_FOURCC, cv2.VideoWriter_fourcc(*'MJPG'))
    print("Attempting to set codec to MJPG.")

    # --- Set Resolution ---
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, RESOLUTION_WIDTH)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, RESOLUTION_HEIGHT)

    # --- Set Framerate ---
    cap.set(cv2.CAP_PROP_FPS, FRAMERATE)

    # --- Set Exposure ---
    cap.set(cv2.CAP_PROP_EXPOSURE, EXPOSURE)

    # Optional: Verify if the settings were applied (not all webcams support all resolutions/framerates)
    actual_width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    actual_height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    actual_fps = int(cap.get(cv2.CAP_PROP_FPS))
    print(f"Webcam opened with: {actual_width}x{actual_height} at {actual_fps} FPS")
    if actual_width != RESOLUTION_WIDTH or actual_height != RESOLUTION_HEIGHT:
        print(f"Warning: Desired resolution {RESOLUTION_WIDTH}x{RESOLUTION_HEIGHT} not fully supported. Actual: {actual_width}x{actual_height}")
    if actual_fps != FRAMERATE:
        print(f"Warning: Desired framerate {FRAMERATE} FPS not fully supported. Actual: {actual_fps} FPS")

    while True:
        ret, frame = cap.read()
        if not ret:
            print("Error: Failed to grab frame. End of stream or device error.")
            break

        # Encode the frame as JPEG
        ret, buffer = cv2.imencode('.jpg', frame)
        frame_bytes = buffer.tobytes()

        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + frame_bytes + b'\r\n')

    cap.release()
    print("Webcam released.")


@app.route('/video_feed')
def video_feed():
    return Response(generate_frames(), mimetype='multipart/x-mixed-replace; boundary=frame')


@app.route('/')
def index():
    return """
    <html>
    <head>
        <title>Webcam Stream</title>
        <style>
            body { font-family: sans-serif; text-align: center; background-color: #f0f0f0; }
            h1 { color: #333; }
            img { border: none; max-width: 100%; height: auto; }
        </style>
    </head>
    <body>
        <img src="/video_feed" onclick="this.requestFullscreen()" alt="Webcam Stream">
    </body>
    </html>
    """

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=False)
