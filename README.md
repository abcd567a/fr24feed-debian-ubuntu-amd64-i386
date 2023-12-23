# fr24feed-debian-ubuntu-amd64
## Installation of FlightRadar24 data feeder on Debian 9, 10 & 11 amd64 / Ubuntu 18, 20, 22 amd64 </br> 
### IMPORTANT: </br> FIRST Install Decoder dump1090 </br> Only AFTER installing dump1090, Install Flightradar24 Data Feeder fr24feed

</br>



## STEP-1 of 2: INSTALL DUMP1090:
**Caution:** </br>
Install only ONE of following three options. Installing more than one version of dump1090 will break the installation </br>

 **OPTION (1): dump1090-mutability ver 1.15 (Only for Debian 9 and Ubuntu 18)** </br>
`sudo bash -c "$(wget -O - https://raw.githubusercontent.com/abcd567a/fr24feed-debian-ubuntu-amd64/master/install-dump1090-mut-v1.15.sh)"` </br></br>

 **OPTION (2): dump1090-mutability EB_VERSION (Only for Debian 10, 11, 12 and Ubuntu 20 & 22)** </br>
`sudo bash -c "$(wget -O - https://raw.githubusercontent.com/abcd567a/fr24feed-debian-ubuntu-amd64/master/install-dump1090-mut-eb-ver.sh)"`  </br></br>

 **OPTION (3) dump1090-fa (For Debian 9, 10, 11 & 12 and Ubuntu 18, 20, & 22)** </br>
`sudo bash -c "$(wget -O - https://raw.githubusercontent.com/abcd567a/fr24feed-debian-ubuntu-amd64/master/install-dump1090-fa.sh)"` </br></br>
</br>


## STEP-2 of 2: INSTALL FR24FEED: 
**(2.1) Download fr24feed debian Package** </br>
`wget https://repo-feed.flightradar24.com/linux_x86_64_binaries/fr24feed_1.0.44-0_amd64.deb   ` 
</br></br>
**(2.2) Install downloaded package** </br>
`sudo dpkg -i fr24feed_1.0.44-0_amd64.deb  `
</br></br>
**(2.3) Signup (for NEW installs only. For upgrade of EXISTING installs, skip this step)** </br>
`sudo fr24feed --signup   `
</br></br>
**(2.4) Restart fr24feed** </br>
`sudo systemctl restart fr24feed   `
</br></br>
**(2.5) After restart of fr24feed, wait few minutes, then check status** </br>
`sudo fr24feed-status   `

</br></br>
## CONFIGURATION

**(1) CONFIGURATION OF FR24FEED** </br>
The configuration file can be edited by following command; </br>
`sudo nano /etc/fr24feed.ini` </br></br>
**Default contents of FR24FEED config file**</br>
Default setting are for a decoder like dump1090-mutability or dump1090-fa running on the Computer. </br>
This can be changed by editing config file</br>

```
receiver="avr-tcp"
host="127.0.0.1:30002"
fr24key=""

bs="no"
raw="no"
logmode="1"
logpath="/var/log/fr24feed/"
mlat="yes"
mlat-without-gps="yes"

```

**(2) CONFIGURING OF dump1090-mutability** </br>

**Method 1** </br>
```
sudo dpkg-reconfigure dump1090-mutability
```
</br>

**Method 2** </br>
```
sudo nano etc/default/dump1090-mutability

sudo nano /usr/share/dump1090-mutability/html/config.js
```

**(3) CONFIGURING OF dump1090-fa** </br>
```
sudo nano etc/default/dump1090-fa

sudo nano /usr/share/skyaware/html/config.js
```

</br></br>

## UNINSTALL </br>
**(1) TO UNINSTALL FR24FEED** </br>
To completely remove configuration and all files, give following commands:
```
sudo systemctl stop fr24feed 

sudo dpkg --purge fr24feed  
```

</br>

**(2) TO UNINSTALL dump1090-mutability (ver 1.15~dev and EB_VERSION)** </br>
To completely remove configuration and all files, give following 6 commands: </br>
```
sudo dpkg --purge dump1090-mutability
sudo apt purge lighttpd
sudo apt autoremove
sudo rm -rf /var/www/html
sudo rm -rf /etc/lighttpd
sudo rm -rf /usr/share/dump1090-mutability
```

</br>

**(3) TO UNINSTALL dump1090-fa** </br>
To completely remove configuration and all files, give following 7 commands: </br>
```
sudo dpkg --purge dump1090-fa
sudo apt purge lighttpd
sudo apt autoremove
sudo rm -rf /var/www/html
sudo rm -rf /etc/lighttpd
sudo rm -rf /usr/share/dump1090-fa
sudo rm -rf /usr/share/skyaware
```
