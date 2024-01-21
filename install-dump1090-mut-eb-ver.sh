#!/bin/bash
echo -e "\e[33mupdating.....\e[39m"
apt update

echo -e "\e[33mDUMP1090-MUTABILITY - EB_VERSION\e[39m"
echo "Installing packages needed to build, and needed to fulfill dependencies....\e[39m"
apt install -y git lighttpd build-essential apache2-dev pkg-config
apt install -y debhelper librtlsdr-dev libusb-1.0-0-dev
apt install -y libjs-excanvas libjs-jquery libjs-jquery-ui libjs-jquery-ui-theme-smoothness 
echo ""
echo -e "\e[33mInstallation of dump1090-mut dependencies & tools completed...\e[39m"
echo ""
echo -e "\e[33mCLONING THE SOURCE FILES.....\e[39m"
git clone https://salsa.debian.org/debian-hamradio-team/dump1090-mutability dump1090-mut-eb-ver  

echo ""
echo -e "\e[33mMOVING INTO CLONED DIRECTORY ....\e[39m"
cd ${PWD}/dump1090-mut-eb-ver
echo ""
echo -e "\e[33mBUILDING DUMP1090-MUTABILITY PACKAGE ....\e[39m"
dpkg-buildpackage -b
echo ""
echo -e "\e[33mINSTALLING THE DUMP1090-MUTABILITY PACKAGE ....\e[39m"
cd ../
dpkg -i dump1090-mutability_1.15~*.deb
echo ""
lighty-enable-mod dump1090
systemctl force-reload lighttpd
echo ""
echo -e "\e[33mWORKAROUND (Ajax call Failure) ....\e[39m"
wget -O  /etc/udev/rules.d/rtl-sdr.rules "https://raw.githubusercontent.com/osmocom/rtl-sdr/master/rtl-sdr.rules"
usermod -a -G plugdev dump1090
echo ""
echo -e "\e[33mConfiguring dump1090-mutability...\e[39m"
dpkg-reconfigure dump1090-mutability
echo ""
echo -e "\e[32m===============\e[39m"
echo -e "\e[32mALL DONE (EB_VERSION)\e[39m"
echo -e "\e[32m===============\e[39m"
echo -e "\e[32m(1) In your browser, go to web interface at\e[39m"
echo -e "\e[39m     http://$(ip route | grep -m1 -o -P 'src \K[0-9,.]*')/dump1090/gmap.html \e[39m"
echo " "
echo -e "\e[31mREBOOT YOUR COMPUTER IF MAP DOES NOT SHOW, OR SHOWS ERROR MESSAGE\e[39m"
echo -e "\e[33mTo configure dump1090-mutability EB_VERSION any time use following command:\e[39m"
echo "  sudo dpkg-reconfigure dump1090-mutability "
echo ""
