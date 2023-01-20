# fr24feed-debian-ubuntu-amd64
### Installation of (1) Decoder (dump1090-mutability OR dump1090-fa) AND (2) FlightRadar24 data feeder on Debian 9, 10 & 11 amd64 / Ubuntu 18, 20, 22 amd64
</br>



### STEP-1: INSTALL DUMP1090:
Below are scripts which will install lighttpd (essential to display map), and dump1090-mutability / dump1090-fa. </br></br>
**Caution:** </br>
Install only ONE of following three versions of dump1090. Installing more than one version of dump1090 will break the installation </br>

 **Option (1): For Debian 9 and Ubuntu 18 (dump1090-mutability ver 1.15)** </br>
`sudo bash -c "$(wget -O - https://raw.githubusercontent.com/abcd567a/fr24feed-debian-ubuntu-amd64/master/install-dump1090-mut-v1.15.sh)"` </br></br>

 **Option (2): For Debian 10, 11 and Ubuntu 18, 20 & 22 (dump1090-mutability EB_VERSION)** </br>
`sudo bash -c "$(wget -O - https://raw.githubusercontent.com/abcd567a/fr24feed-debian-ubuntu-amd64/master/install-dump1090-mut-eb-ver.sh)"`  </br></br>

 **Option (3) For Debian 9, 10, & 11 and Ubuntu 18, 20, & 22 (dump1090-fa)** </br>
`sudo bash -c "$(wget -O - https://raw.githubusercontent.com/abcd567a/fr24feed-debian-ubuntu-amd64/master/install-dump1090-fa.sh)"` </br></br>
</br>


### STEP-2: INSTALL FR24FEED: 
**issue following commands:** </br>
**(2.1) Download fr24feed debian Package** </br>
`wget https://repo-feed.flightradar24.com/linux_x86_64_binaries/fr24feed_1.0.34-0_amd64.deb   ` 
</br></br>
**(2.2) Install downloaded package** </br>
`sudo dpkg -i fr24feed_1.0.34-0_amd64.deb  `
</br></br>
**(2.3) Signup (for new installs nly. For upgrade of existing installs, skip this step)** </br>
`sudo fr24feed --signup   `
</br></br>
**(2.4) Restart fr24feed** </br>
`sudo systemctl restart fr24feed   `
</br></br>
**(2.5) After restart of fr24feed, wait few minutes, then check status** </br>
`sudo fr24feed-status   `

</br></br></br>

**CONFIGURATION OF FR24FEED** </br>
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
</br>


**TO UNINSTALL FR24FEED** </br>
To completely remove configuration and all files, give following commands:
```
sudo systemctl stop fr24feed 

sudo dpkg --purge fr24feed  
```

</br>


**DUMP1090 CONFIGURING / CHANGING SETTINGS** </br>

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
