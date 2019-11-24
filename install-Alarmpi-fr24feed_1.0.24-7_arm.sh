#!/bin/bash

echo "Downloading binary fr24feed for arm from Github"
sudo wget -O /usr/bin/fr24feed "https://github.com/abcd567a/fr24feed-debian-ubuntu-amd64/releases/download/ver1/fr24feed"
sudo chmod +x /usr/bin/fr24feed

echo "Creating config file fr24feed.ini"
CONFIG_FILE=/etc/fr24feed.ini
sudo touch ${CONFIG_FILE}
sudo chmod 777 ${CONFIG_FILE}
echo "Writing code to config file fr24feed.ini"
/bin/cat <<EOM >${CONFIG_FILE}
receiver="beast-tcp"
host="127.0.0.1:30005"
fr24key=""

bs="no"
raw="no"
logmode="1"
windowmode="0"
mpx="no"
mlat="yes"
mlat-without-gps="yes"
use-http=yes
http-timeout=20

EOM

sudo chmod 666 ${CONFIG_FILE}

echo "Creating user fr24 to run service"
sudo useradd --system fr24

echo "Creating Service file fr24feed.service"
SERVICE_FILE=/usr/lib/systemd/system/fr24feed.service
sudo touch ${SERVICE_FILE}
sudo chmod 777 ${SERVICE_FILE}
/bin/cat <<EOM >${SERVICE_FILE}
[Unit]
Description=Flightradar24 Feeder
After=network-online.target

[Service]
Type=simple
Restart=always
LimitCORE=infinity
RuntimeDirectory=fr24feed
RuntimeDirectoryMode=0755
ExecStartPre=-/bin/mkdir -p /var/log/fr24feed
ExecStartPre=-/bin/chown fr24 /var/log/fr24feed
ExecStart=/usr/bin/fr24feed
User=fr24
PermissionsStartOnly=true
StandardOutput=null

[Install]
WantedBy=multi-user.target

EOM

sudo chmod 644 ${SERVICE_FILE}
sudo systemctl enable fr24feed
sudo systemctl restart fr24feed

echo " "
echo " "
echo -e "\e[32mINSTALLATION COMPLETED \e[39m"
echo -e "\e[32m=======================\e[39m"
echo -e "\e[32mPLEASE DO FOLLOWING:\e[39m"
echo -e "\e[32m=======================\e[39m"
echo -e "\e[32m(1) SIGNUP:\e[39m"
echo -e "\e[32m   (a) If you already have a feeder key,\e[39m"
echo -e "\e[33m       open file fr24feed.ini by following command and add fr24key:\e[39m"
echo -e "\e[39m           sudo nano /etc/fr24feed.ini \e[39m"
echo -e "\e[33m       Save (Ctrl+o) and Close (Ctrl+x) file fr24feed.ini \e[39m"
echo -e "\e[33m       then restart fr24feed by following command:\e[39m"
echo -e "\e[39m           sudo systemctl restart fr24feed \e[39m"
echo " "

echo -e "\e[32m   (b) Alternatively signup using following command\e[39m"
echo -e "\e[39m         sudo nano fr24feed --signup \e[39m"
echo " "
echo -e "\e[32m(2) In your browser, go to web interface at\e[39m"
echo -e "\e[39m     http://$(ip route | grep -m1 -o -P 'src \K[0-9,.]*'):8754 \e[39m"
echo " "
echo " "
echo -e "\e[32mTo see status\e[39m sudo systemctl status fr24feed"
echo -e "\e[32mTo restart\e[39m    sudo systemctl restart fr24feed"
echo -e "\e[32mTo stop\e[39m       sudo systemctl stop fr24feed"


