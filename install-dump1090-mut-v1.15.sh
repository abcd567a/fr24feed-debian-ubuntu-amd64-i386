#!/bin/bash
echo -e "\e[33mupdating.....\e[39m"
apt update

echo -e "\e[33mDUMP1090-MUTABILITY ver 1.15~dev\e[39m"
echo "Installing packages needed to build, and needed to fulfill dependencies....\e[39m"
apt install -y git debhelper librtlsdr-dev lighttpd
apt install -y rtl-sdr build-essential cron curl
apt install -y fakeroot libusb-1.0-0-dev pkg-config
echo ""
echo ""
echo -e "\e[33mInstallation of dump1090-mut dependencies & tools completed...\e[39m"
echo ""
echo -e "\e[33mCLONING THE SOURCE FILES.....\e[39m"
git clone -b unmaintained https://github.com/mutability/dump1090.git dump1090-v1.15

echo ""
echo -e "\e[33mMOVING INTO CLONED DIRECTORY ....\e[39m"
cd ${PWD}/dump1090-v1.15
echo ""
echo -e "\e[33mBUILDING DUMP1090-MUTABILITY PACKAGE ....\e[39m"
dpkg-buildpackage -b
echo ""
echo -e "\e[33mINSTALLING THE DUMP1090-MUTABILITY PACKAGE ....\e[39m"
cd ../
dpkg -i dump1090-mutability_1.15~dev_*.deb
echo ""
lighty-enable-mod dump1090
systemctl force-reload lighttpd
echo ""
echo -e "\e[33mWORKAROUND (Ajax call Failure) ....\e[39m"
wget -O  /etc/udev/rules.d/rtl-sdr.rules "https://raw.githubusercontent.com/osmocom/rtl-sdr/master/rtl-sdr.rules"
echo ""
echo -e "\e[33mConfiguring dump1090-mutability...\e[39m"
dpkg-reconfigure dump1090-mutability
echo ""
echo -e "\e[32m===============\e[39m"
echo -e "\e[32mALL DONE (ver 1.15~dev)\e[39m"
echo -e "\e[32m===============\e[39m"
echo -e "\e[32m(1) In your browser, go to web interface at\e[39m"
echo -e "\e[39m     http://$(ip route | grep -m1 -o -P 'src \K[0-9,.]*')/dump1090/gmap.html \e[39m"
echo " "
echo -e "\e[31mREBOOT YOUR COMPUTER IF MAP DOES NOT SHOW, OR SHOWS ERROR MESSAGE\e[39m"
echo -e "\e[33mTo configure dump1090-mutability ver 1.15~dev any time use following command:\e[39m"
echo "  sudo dpkg-reconfigure dump1090-mutability "
echo ""
