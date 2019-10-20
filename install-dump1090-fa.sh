#!/bin/bash
echo -e "\e[33mupdating.....\e[39m"
apt update

echo -e "\e[33mDUMP1090-FA\e[39m"
echo "Installing packages needed to build, and needed to fulfill dependencies....\e[39m"
apt install -y git lighttpd build-essential debhelper librtlsdr-dev
apt install -y pkg-config dh-systemd libncurses5-dev libbladerf-dev 

echo ""
echo ""
echo -e "\e[33mInstallation of dump1090-fa dependencies & tools completed...\e[39m"
echo ""
echo -e "\e[33mCLONING THE SOURCE FILES.....\e[39m"
git clone https://github.com/flightaware/dump1090.git dump1090-fa

echo ""
echo -e "\e[33mMOVING INTO CLONED DIRECTORY ....\e[39m"
cd ${PWD}/dump1090-fa
echo ""
echo -e "\e[33mBUILDING DUMP1090-MUTABILITY PACKAGE ....\e[39m"
dpkg-buildpackage -b
echo ""
echo -e "\e[33mINSTALLING THE DUMP1090-FA PACKAGE ....\e[39m"
cd ../
dpkg -i dump1090-fa_*.deb
echo ""
echo ""
echo -e "\e[33mWORKAROUND (Ajax call Failure) ....\e[39m"
wget -O  /etc/udev/rules.d/rtl-sdr.rules "https://raw.githubusercontent.com/osmocom/rtl-sdr/master/rtl-sdr.rules"
echo ""
echo ""
echo -e "\e[32m===============\e[39m"
echo -e "\e[32mALL DONE - dump1090-fa (Flightaware version)\e[39m"
echo -e "\e[32m===============\e[39m"
echo -e "\e[32m(1) In your browser, go to web interface at\e[39m"
echo -e "\e[39m     http://$(ip route | grep -m1 -o -P 'src \K[0-9,.]*')/dump1090-fa/ \e[39m"
echo " "
echo -e "\e[31mREBOOT YOUR COMPUTER IF MAP DOES NOT SHOW, OR SHOWS ERROR MESSAGE\e[39m"
echo -e "\e[33mIn case you want to change/add settings of dump1090-fa, edit following files:\e[39m"
echo "  sudo nano /etc/default/dump1090-fa "
echo "  sudo nano /usr/share/dump1090-fa/html/config.js "
echo ""
