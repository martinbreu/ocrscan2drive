#!/usr/bin/python3
import os
import RPi.GPIO as GPIO
from datetime import datetime, timedelta
import time
import subprocess
import threading

drivePathMartin = "gdrive:toOCR/"
drivePathMaddie = "gdrive:toOCR/Maddie/"
pinLight = 24
pinButton = 18
tempDir = "/home/pi/scan2drive/upload/"
scanFormat = "jpeg"
scanCommand = ("scanimage", "--format", scanFormat, "--resolution", "300")
scanFileName = "%Y-%m-%d_%H-%M-%S"

def error_blink(e):
    print("error: " + str(e))
    for x in range(8):
        GPIO.output(pinLight, 0)
        time.sleep(0.8)
        GPIO.output(pinLight, 1)
        time.sleep(0.8)


def scan_upload():
    global drivePath
    GPIO.output(pinLight, 1)
    try:
        timestamp = (datetime.now() + timedelta(hours=1)).strftime(scanFileName)
        file = tempDir + timestamp + "." + scanFormat
        print("Scan and upload " + file)
        with open(file, 'w') as f:
            subprocess.run(scanCommand, stdout=f, check=True)
        print("Upload: " + tempDir + " to " + drivePath)
        subprocess.run(("rclone", "move", tempDir, drivePath), check=True)
        print("Successfully uploaded to " + drivePath)
        GPIO.output(pinLight, 0)
    except Exception as e:
        error_blink(e)


GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)
GPIO.setup(pinLight, GPIO.OUT)
GPIO.setup(pinButton, GPIO.IN, pull_up_down=GPIO.PUD_UP)

try:
    print("ocrscan2drive by martinbreu")
    subprocess.run(("mkdir", tempDir))
    while True:
        GPIO.wait_for_edge(pinButton, GPIO.RISING)
        drivePath = drivePathMartin
        thread = threading.Thread(target=scan_upload)
        thread.start()
        time.sleep(0.5)
        while thread.is_alive():
            if not GPIO.input(pinButton):
                drivePath = drivePathMaddie
                GPIO.output(pinLight, 0)
                time.sleep(0.8)
                GPIO.output(pinLight, 1)
                time.sleep(0.8)
                continue
except Exception as e:
    error_blink(e)
    GPIO.cleanup()
