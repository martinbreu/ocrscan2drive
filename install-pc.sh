wget https://github.com/raspberrypi/rpi-imager/releases/download/v1.4/rpi-imager_1.4_amd64.deb
sudo apt install ./rpi-imager_1.4_amd64.deb -y
rpi-imager
touch /media/martinbreu/boot/ssh
nano /media/martinbreu/boot/wpa_supplicant.conf

sudo apt-get install rclone -y
rclone config
rclone config

mkdir /home/martinbreu/.google-drive
sudo bash -c 'echo "[Unit]
Description=pull-drive
Requires=network-online.target
After=network-online.target
[Service]
Type=oneshot
User=martinbreu
Group=martinbreu
ExecStartPre=/bin/sh -c \"until ping -c1 google.com; do sleep 1; done;\"
ExecStart=-/usr/bin/rclone dedupe --dedupe-mode rename gdrive:
ExecStart=/usr/bin/rclone sync --exclude \"/toOCR/**\" gdrive: /home/martinbreu/.google-drive/
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/pull-drive.service'
sudo bash -c 'echo "[Unit]
Description=ocr2drive
Requires=network-online.target docker.service
After=network-online.target docker.service
[Service]
Type=oneshot
User=martinbreu
Group=martinbreu
ExecStartPre=/bin/sh -c \"until ping -c1 google.com >/dev/null 2>&1; do sleep 1; done;\"
ExecStart=/usr/bin/rclone move --retries 1 gdrive:/toOCR/ /home/martinbreu/.google-drive/toOCR/
ExecStart=-/usr/bin/find /home/martinbreu/.google-drive/toOCR -name \"*.*\" -exec /bin/echo \"{}\" \; -exec /usr/bin/docker run --rm -v \"/home/martinbreu/.google-drive/toOCR:/home/martinbreu/.google-drive/toOCR\" -i jbarlow83/ocrmypdf:v11.1.1 -l eng+deu --rotate-pages --rotate-pages-threshold 2.5 --image-dpi 300 --force-ocr --jbig2-lossy --optimize 2 \"{}\" \"{}\" \;
ExecStart=-/usr/bin/find /home/martinbreu/.google-drive/toOCR -name \"*.*\" -exec /bin/echo \"{}\" \; -exec /usr/bin/docker run --rm -v \"/home/martinbreu/.google-drive/toOCR:/home/martinbreu/.google-drive/toOCR\" -i jbarlow83/ocrmypdf:v11.1.1 -l eng+deu --deskew --rotate-pages-threshold 2.5 --image-dpi 300 --force-ocr --jbig2-lossy --optimize 2 \"{}\" \"{}.pdf\" \; -exec /bin/rm \"{}\" \;
ExecStart=/bin/sh -c \"/bin/cp -r /home/martinbreu/.google-drive/toOCR/. /home/martinbreu/.google-drive/Dokumente\"
ExecStart=-/usr/bin/rclone move --retries 1 /home/martinbreu/.google-drive/toOCR/Maddie/ gdriveMaddie:/Dokumente/
ExecStart=/usr/bin/rclone move --retries 1 /home/martinbreu/.google-drive/toOCR/ gdrive:/Dokumente/
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/ocr2drive.service'
sudo bash -c 'echo "[Unit]
Description=ocr2drive timer every 10sec
Requires=network-online.target docker.service
After=network-online.target docker.service
[Timer]
Unit=ocr2drive.service
OnUnitInactiveSec=10s
[Install]
WantedBy=timers.target" > /etc/systemd/system/ocr2drive.timer'
sudo chmod 644 /etc/systemd/system/pull-drive.service /etc/systemd/system/ocr2drive.service /etc/systemd/system/ocr2drive.timer
sudo chown root:root /etc/systemd/system/pull-drive.service /etc/systemd/system/ocr2drive.service /etc/systemd/system/ocr2drive.timer
sudo systemctl daemon-reload
sudo systemctl enable pull-drive.service ocr2drive.service ocr2drive.timer
sudo systemctl start pull-drive.service ocr2drive.service ocr2drive.timer
