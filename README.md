# fr24feed-debian-ubuntu-amd64
## (1) FlightRadar24 data feeder installation script for Debian 9 & 10 amd64 / Ubuntu 18.04 amd64 on 64bit Intel CPU
## (2) dump1090 (mutability and flightaware) installation script for Debian 9 & 10 amd64 / Ubuntu 18.04 amd64 on 64bit Intel CPU
</br>

### INSTALL FR24FEED: 
**Copy-paste following command in SSH console and press Enter key. </br>
The script will install and configure fr24feed.** </br></br>
`sudo bash -c "$(wget -O - https://raw.githubusercontent.com/abcd567a/fr24feed-debian-ubuntu-amd64/master/install-fr24feed_1.0.25-3_amd64.tgz.sh)"` </br></br></br>

**Caution:** </br>
MLAT is supported only for Raspberry Pi feeder. </br>
For x86 amd64 feeders, in settings choose mlat=no. </br>
Setting mlat=yes will result in fr24feed failing with "segmentation fault". </br>


### INSTALL DUMP1090:
The above fr24feed install script does **NOT** install or include installation of lighttpd and any version of dump1090. </br>
The user should himself/herself install lighttpd and dump1090 (mutability or flightaware version) </br>
Below are scripts which will install lighttpd and dump1090-mutability / dump1090-fa. </br></br>
**Caution:** </br>
Install only ONE of following three versions of dump1090. Installing more than one version of dump1090 will break the installation </br>

> **(1) For Debian 9 and Ubuntu 18 (dump1090-mutability ver 1.15)** </br>
`sudo bash -c "$(wget -O - https://raw.githubusercontent.com/abcd567a/fr24feed-debian-ubuntu-amd64/master/install-dump1090-mut-v1.15.sh)"` </br></br>

> **(2) For Debian 10 and Ubuntu 19 (dump1090-mutability EB_VERSION)** </br>
`sudo bash -c "$(wget -O - https://raw.githubusercontent.com/abcd567a/fr24feed-debian-ubuntu-amd64/master/install-dump1090-mut-eb-ver.sh)"`  </br></br>

> **(3) For Debian 9 & 10 and Ubuntu 18 & 19 (dump1090-fa)** </br>
`sudo bash -c "$(wget -O - https://raw.githubusercontent.com/abcd567a/fr24feed-debian-ubuntu-amd64/master/install-dump1090-fa.sh)"` </br></br>
</br>

## FR24FEED - Post install instructions
**After FR24 Feeder installation script finishes, it displays following message:**
```
INSTALLATION COMPLETED
=======================
PLEASE DO FOLLOWING:
=======================
(1) SIGNUP:
   (a) If you already have a feeder key,
       open file fr24feed.ini by following command and add fr24key:
           sudo nano /etc/fr24feed.ini
       Save (Ctrl+o) and Close (Ctrl+x) file fr24feed.ini
       then restart fr24feed by following command:
           sudo systemctl restart fr24feed

   (b) Alternatively signup using following command
         sudo nano fr24feed --signup

(2) In your browser, go to web interface at
     http://localhost:8754


To see status sudo systemctl status fr24feed
To restart    sudo systemctl restart fr24feed
To stop       sudo systemctl stop fr24feed
```

**CONFIGURATION OF FR24FEED** </br>
The configuration file can be edited by following command; </br>
`sudo nano /etc/fr24feed.ini` </br></br>
**Default contents of FR24FEED config file**</br>
Default setting are for a decoder like dump1090-mutability or dump1090-fa running on the Computer. </br>
This can be changed by editing config file</br>

```
receiver="beast-tcp"
host="127.0.0.1:30005"
fr24key=""

bs="no"
raw="no"
logmode="1"
logpath="/var/log/fr24feed/"
windowmode="0"
mpx="no"
mlat="no"
mlat-without-gps="no"
use-http=yes
http-timeout=20

```
</br>


**TO UNINSTALL FR24FEED** </br>
To completely remove configuration and all files, give following 7 commands:
```
sudo systemctl stop fr24feed 
sudo systemctl disable fr24feed 
sudo rm /lib/systemd/system/fr24feed.service
sudo rm -rf /usr/share/fr24 
sudo rm /usr/bin/fr24feed
sudo rm /etc/fr24feed.ini 
sudo rm -rf /var/log/fr24feed  
```

</br>

## DUMP1090 - Post install instructions </br>

**CONFIGURING / CHANGING SETTINGS** </br>

**dump1090-mutability, method 1** </br>
```
sudo dpkg-reconfigure dump1090-mutability
```
</br>

**dump1090-mutability, method 2** </br>
```
sudo nano etc/default/dump1090-mutability

sudo nano /usr/share/dump1090-mutability/html/config.js
```

**dump1090-fa** </br>
```
sudo nano etc/default/dump1090-fa

sudo nano /usr/share/dump1090-fa/html/config.js
```

</br></br>

**TO UNINSTALL DUMP1090** </br>
To completely remove configuration and all files, give following 6 commands: </br>

**dump1090-mutability (ver 1.15~dev and EB_VERSION)** </br>

```
sudo dpkg --purge dump1090-mutability
sudo apt purge lighttpd
sudo apt autoremove
sudo rm -rf /var/www/html
sudo rm -rf /etc/lighttpd
sudo rm -rf /usr/share/dump1090-mutability
```

</br>

**dump1090-fa** </br>

```
sudo dpkg --purge dump1090-fa
sudo apt purge lighttpd
sudo apt autoremove
sudo rm -rf /var/www/html
sudo rm -rf /etc/lighttpd
sudo rm -rf /usr/share/dump1090-fa
```
