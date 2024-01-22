# fr24feed on debian & ubuntu, amd64/x86_64 and i386/i686
## Installation of FlightRadar24 data feeder on amd64/x86_64 and i386/i686 on Debian 9, 10, 11, & 12 and on Ubuntu 18, 20, 22, 23, & 24 </br> 
### IMPORTANT: </br> FIRST Install Decoder dump1090 </br> Only AFTER installing dump1090, Install Flightradar24 Data Feeder fr24feed

</br>



## STEP-1 of 2: INSTALL DUMP1090:
**CAUTION:** </br>
Install only ONE of following three options. Installing more than one version of dump1090 will break the installation </br>

 **OPTION (1): dump1090-mutability ver 1.15 (Only for Debian 9 and Ubuntu 18)** </br>
`sudo bash -c "$(wget -O - https://github.com/abcd567a/fr24feed-debian-ubuntu-amd64-i386/raw/master/install-dump1090-mut-v1.15.sh)"` </br></br>

**OPTION (2): dump1090-mutability EB_VERSION (Only for Debian 10, 11, 12 and Ubuntu 20, 22, 23 & 24)** </br>
`sudo apt update  ` </br>
`sudo apt install dump1090-mutability  ` </br>
`sudo usermod -a -G plugdev dump1090  ` </br>
`sudo reboot  ` </br>
</br>

**OPTION (3) dump1090-fa (For Debian 9, 10, 11 & 12 and Ubuntu 18, 20, 22, 23, & 24)** </br>
`sudo bash -c "$(wget -O - https://github.com/abcd567a/fr24feed-debian-ubuntu-amd64-i386/raw/master/install-dump1090-fa.sh)"` </br></br>
</br>
## STEP-2 of 2: INSTALL FR24FEED:
First determine architecture of your Computer/OS by issuing following command: </br>
`uname -m  `
</br>
#### If command `uname -m ` outputs `x86_64` or `amd64`, then follow steps **2.1** and **2.2** </br>
#### If command `uname -m ` outputs `i386` or `i686`, then follow steps **2.3** and **2.4** </br></br>

### x86_64 or amd64
**(2.1) Download fr24feed x86_64/amd64 debian Package** </br>
`wget https://repo-feed.flightradar24.com/linux_binaries/fr24feed_1.0.46-1_amd64.deb`
</br></br>
**(2.2) Install downloaded x86_64/amd64 package** </br>
`sudo dpkg -i fr24feed_1.0.46-1_amd64.deb  `
</br></br>
### i386 or i686
**(2.3) Download fr24feed debian i386 Package** </br>
`wget https://repo-feed.flightradar24.com/linux_binaries/fr24feed_1.0.46-1_i386.deb `
</br></br>
**(2.4) Install downloaded  i386 package** </br>
`sudo dpkg -i fr24feed_1.0.46-1_i386.deb `
</br></br>


**(2.5) SIGNUP (for NEW installs only). </br>For upgrade of EXISTING installs, skip this step** </br>
`sudo fr24feed --signup   `
</br></br>
**(2.6) Restart fr24feed** </br>
`sudo systemctl restart fr24feed   `
</br></br>
**(2.7) After restart of fr24feed, wait few minutes, then check status** </br>
`sudo fr24feed-status   `

</br></br>
## CONFIGURATION

**(1) CONFIGURATION OF FR24FEED** </br>
The configuration file can be edited by following command; </br></br>
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
`sudo dpkg-reconfigure dump1090-mutability  `
</br>

**Method 2** </br>
`sudo nano etc/default/dump1090-mutability  ` </br>
`sudo nano /usr/share/dump1090-mutability/html/config.js  ` </br>


**(3) CONFIGURING OF dump1090-fa** </br>
`sudo nano etc/default/dump1090-fa  ` </br>
`sudo nano /usr/share/skyaware/html/config.js  ` </br>
</br>

## UNINSTALL </br>
**(1) TO UNINSTALL FR24FEED** </br>
To completely remove configuration and all files, give following commands:</br>

`sudo systemctl stop fr24feed ` </br>
`sudo dpkg --purge fr24feed  ` </br>
`sudo rm -rf /usr/lib/fr24  ` </br>


**(2) TO UNINSTALL dump1090-mutability (ver 1.15~dev and EB_VERSION)** </br>
To completely remove configuration and all files, give following commands: </br>

`sudo dpkg --purge dump1090-mutability  ` </br>
`sudo apt purge dump1090-mutability  ` </br>
`sudo apt purge lighttpd  ` </br>
`sudo apt autoremove  ` </br>
`sudo rm -rf /var/www/html  ` </br>
`sudo rm -rf /etc/lighttpd  ` </br>
`sudo rm -rf /usr/share/dump1090-mutability  ` </br>


</br>

**(3) TO UNINSTALL dump1090-fa** </br>
To completely remove configuration and all files, give following 7 commands: </br>

`sudo dpkg --purge dump1090-fa  ` </br>
`sudo apt purge lighttpd  ` </br>
`sudo apt autoremove  ` </br>
`sudo rm -rf /var/www/html  ` </br>
`sudo rm -rf /etc/lighttpd  ` </br>
`sudo rm -rf /usr/share/dump1090-fa  ` </br>
`sudo rm -rf /usr/share/skyaware  ` </br>

