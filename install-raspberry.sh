sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install cups -y
sudo sed -i "s%Listen localhost:631%Port 631\nBrowseAddress @LOCAL%" /etc/cups/cupsd.conf
sudo sed -i "s%</Location>%  Allow @LOCAL\n</Location>%" /etc/cups/cupsd.conf
sudo adduser pi lp
sudo usermod -aG lpadmin pi
sudo usermod -aG lp pi
sudo apt install sane sane-utils -y
sudo systemctl start saned.socket
sudo systemctl enable saned.socket
sudo apt-get install python-rpi.gpio python3-rpi.gpio -y
sudo sane-find-scanner
sudo apt-get install build-essential libcups2-dev libavahi-client-dev git bzr -y
git apt-get install golang
go version
go get github.com/google/cloud-print-connector/gcp-cups-connector
go get github.com/google/cloud-print-connector/gcp-connector-util
sudo useradd -s /usr/sbin/nologin -r -M cloud-print-connector
sudo mkdir /opt/cloud-print-connector
sudo mv ~/go/bin/gcp-cups-connector /opt/cloud-print-connector
sudo mv ~/go/bin/gcp-connector-util /opt/cloud-print-connector
sudo chmod 755 /opt/cloud-print-connector/gcp-cups-connector
sudo chmod 755 /opt/cloud-print-connector/gcp-connector-util
sudo chown cloud-print-connector:cloud-print-connector /opt/cloud-print-connector/gcp-cups-connector
sudo chown cloud-print-connector:cloud-print-connector /opt/cloud-print-connector/gcp-connector-util
rm -f ~/go/bin/gcp*
sudo /opt/cloud-print-connector/gcp-connector-util init
sudo mv ~/gcp-cups-connector.config.json /opt/cloud-print-connector/
sudo chmod 660 /opt/cloud-print-connector/gcp-cups-connector.config.json
sudo chown cloud-print-connector:cloud-print-connector /opt/cloud-print-connector/gcp-cups-connector.config.json
wget https://raw.githubusercontent.com/google/cloud-print-connector/master/systemd/cloud-print-connector.service
sudo install -o root -m 0664 cloud-print-connector.service /etc/systemd/system
sudo systemctl enable cloud-print-connector.service
sudo systemctl start cloud-print-connector.service
sudo apt-get install rclone -y
mkdir /home/pi/ocrscan2drive/upload
sudo chmod +x /home/pi/ocrscan2drive/scan2drive.py
rclone config
sudo bash -c 'echo "[Unit]
Description=scan2drive
After=multi-user.target
[Service]
Type=idle
User=pi
Group=pi
ExecStart=/usr/bin/python3 -u /home/pi/ocrscan2drive/scan2drive.py
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/scan2drive.service'
sudo chmod 644 /etc/systemd/system/scan2drive.service
sudo chown root:root /etc/systemd/system/scan2drive.service
sudo systemctl daemon-reload
sudo systemctl start scan2drive.service
sudo systemctl enable scan2drive.service
sudo reboot
