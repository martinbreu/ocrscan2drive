# OCRscan2drive

## Goal
##### Digitize my private document folder
When I get a letter at home, I place it on the scanner, press one button, and store the letter in a simple box underneath.

From everywhere, I open Google Drive and use the search bar to find my document (for this I create searchable PDFs)

My girlfriend likes this idea, so she can long press the button for her Google Drive.

To be able to print from everywhere (Windows, Android, Linux, IOS), I install cups and, in the past google-cloud-print-connector (deprecated and commented out)

## State
It runs 2 months without any error, but I did not test the installer scripts from scratch or any other distribution than Ubuntu 18 and Raspbian Full.

Only Canon MX495 is tested, but using 'scannimage' with basic parameters (resolution=300, format=jpeg) should work on most scanners.

Please give [feedback](https://github.com/martinbreu/ocrscan2drive/issues/new) on any error or improvement suggestions and feel free to open a PR.

## Features
* Make Canon MX495 accessible for Windows/Linux/Android/Iphone with Raspberry Pi Zero (WLAN)
* Scan jpeg using scanimage and upload to Google Drive using rclone
* On PC create Backup of Google Drive on every boot up (Google Drive allows same folder/file names, so rclone dedupe combines folders and renames files)
* Every 10 seconds: download scanned images and ocr using ocrmypdf (rotate 0-360°), to upload pdf's using rclone
* Short button-press for me, long for girlfriend (indicated by light)
* Upload a pdf or an image in any folder structure to gdrive/toOCR and it will get ocr-d and moved to gdrive/Dokumente (gdrive/toOCR/Maddie to gdriveMaddie/Dokumente)

## Requirements
* Client ID + Secret from Google Drive

        https://console.developers.google.com
        NEW PROJECT, CREATE, Credentials, CREATE CREDENTIALS, OAuth client ID, (CONFIGURE CONSENT SREEN, EXTERNAL, Enter any "Application name", Save, back to "Credentials"), Application type=Dektop app, CREATE

* Raspberry Pi (I use Zero WH): https://www.amazon.de/dp/B07C7FHJDX/ref=cm_sw_em_r_mt_dp_BdjDFbKCMQB2K
* Button(GPIO 18 - Button - GND) + Light(GPIO 24 - ~220 Ohm Resistor - Light - GND), details see here: https://www.makeuseof.com/tag/add-button-raspberry-pi-project/
* micro-usb to "printer adapter" or usb: https://www.amazon.de/dp/B07MGFRHHR/ref=cm_sw_em_r_mt_dp_ufjDFbRPJJK0J
* Linux PC with [Docker Desktop](https://hub.docker.com/search?q=&type=edition&offering=community&operating_system=linux)


## Install

* On PC:

        git clone https://github.com/martinbreu/ocrscan2drive.git
        sed -i "s/martinbreu/$HOSTNAME/g" ocrscan2drive/install-pc.sh
        sudo chmod +x ocrscan2drive/install-pc.sh
        ./!$
        
        # (n, gdrive, 7, CLIENT-ID, CLIENT-SECRET, y, y, q)
        # If you want just one Google Drive, quit the second rclone configuration and remove "while thread.is_alive():"-loop from scan2drive.py
        # (n, gdriveMaddie, 7, CLIENT-ID, CLIENT-SECRET, y, y, q)
        # For /media/martinbreu/boot/wpa_supplicant.conf (replace XXXXXXXX):
        country=DE
        ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
        update_config=1
        network={
        ssid="XXXXXXXX"
        psk="XXXXXXXXX"
        key_mgmt=WPA-PSK
        }

* Insert sd, connect printer, power up and connect with:

        ssh-copy-id pi@raspberrypi  # password=raspberry
        ssh pi@raspberrypi

* On Pi:
        
        passwd
        sudo raspi-config  # set hostname
        cd /home/pi
        git clone https://github.com/martinbreu/ocrscan2drive.git
        sudo chmod +x /home/pi/ocrscan2drive/install-raspberry.sh
        ./!$
        
        # (n, gdrive, 12, CLIENT-ID, CLIENT-SECRET, 1, , , n, n), copy link to get code, (code, n, y, q)
        # Add Printer: open http://{HOSTNAME}:631 (user=pi, password=set before with passwd)



## Roadmap/Bugs:
* Create PR on sane to add ADF-Document-Feeder support for MX495, then double-scan and sort out empty pages
* --rotate-pages recognized but does not rotate. if only rotate param, it rotates. Workaround for now is to OCR twice!
* Create an image of SD-Card and test because re-install takes very long
* Add Gmail attachments to Google Drive (extract from .mbox)?
* OCR on Pi (never tried, but Pi Zero could take hours to OCR, maybe test a bigger Pi in future)
