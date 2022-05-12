#!/bin/bash

#Establish OS 32 or 64 bit
CPU_ARCH=`getconf LONG_BIT`
echo "OS getconf LONG_BIT $CPU_ARCH" >> debug.log
if [[ $CPU_ARCH -eq 64 ]]
then
  echo "ARCH: 64-bit"
elif [[ $CPU_ARCH -eq 32 ]]
then
  echo "ARCH: 32-bit"
else
  echo "OS Unknown"
fi
sleep 3

##Open Sources:
# Monero github https://github.com/moneroexamples/monero-compilation/blob/master/README.md
# Monero Blockchain Explorer https://github.com/moneroexamples/onion-monero-blockchain-explorer

whiptail --title "PiNode-XMR Continue Install" --msgbox "Your PiNode-XMR is taking shape...\n\nHowever this next part will take several hours. When testing this installation I would leave it overnight.\n\nSelect ok to continue setup" 16 60

#Create debug file for handling install errors:
touch debug.log
echo "
####################
" >>debug.log
echo "Start raspbian-pinodexmr.sh script $(date)" >>debug.log
echo "
####################
" >>debug.log

###Continue as 'pinodexmr'
cd
echo -e "\e[32mLock old user 'pi'\e[0m"
sleep 2
sudo passwd --lock pi
echo -e "\e[32mUser 'pi' Locked\e[0m"
sleep 3

##Update and Upgrade system
	echo "Update and Upgrade system" >>debug.log
echo -e "\e[32mReceiving and applying Raspbian updates to latest versions\e[0m"
sleep 3
sudo apt update 2> >(tee -a debug.log >&2) && sudo apt upgrade -y 2> >(tee -a debug.log >&2)

##Installing dependencies for --- Web Interface
	echo "Installing dependencies for --- Web Interface" >>debug.log
echo -e "\e[32mInstalling dependencies for --- Web Interface\e[0m"
sleep 3
sudo apt install apache2 shellinabox php php-common -y 2> >(tee -a debug.log >&2)
sleep 3

##Installing dependencies for --- Monero
	echo "Installing dependencies for --- Monero" >>debug.log
echo -e "\e[32mInstalling dependencies for --- Monero\e[0m"
sleep 3
sudo apt update && sudo apt install build-essential cmake libminiupnpc-dev libhidapi-libusb0 libboost-all-dev libgtest-dev libcurl4-openssl-dev libssl-dev libzmq3-dev libunbound-dev libsodium-dev libunwind8-dev liblzma-dev libreadline6-dev libldns-dev libexpat1-dev libpgm-dev qttools5-dev-tools libhidapi-dev libusb-1.0-0-dev libprotobuf-dev protobuf-compiler libudev-dev libboost-chrono-dev libboost-date-time-dev libboost-filesystem-dev libboost-locale-dev libboost-program-options-dev libboost-regex-dev libboost-serialization-dev libboost-system-dev libboost-thread-dev ccache doxygen graphviz -y 2> >(tee -a debug.log >&2)
sleep 3

##Installing dependencies for --- miscellaneous (security tools-fail2ban-ufw, menu tool-dialog, screen, mariadb)
	echo "Installing dependencies for --- miscellaneous" >>debug.log
echo -e "\e[32mInstalling dependencies for --- Miscellaneous\e[0m"
sleep 3
sudo apt install git mariadb-client mariadb-server screen exfat-fuse exfat-utils fail2ban ufw dialog jq -y 2> >(tee -a debug.log >&2)
sleep 3

##Configure Swap file
	echo "Configure Swap file" >>debug.log
echo -e "\e[32mConfiguring 2GB Swap file (required for Monero build)\e[0m"
sleep 3

wget https://raw.githubusercontent.com/monero-ecosystem/PiNode-XMR/Raspbian-install/etc/dphys-swapfile 2> >(tee -a debug.log >&2)

sudo mv /home/pinodexmr/dphys-swapfile /etc/dphys-swapfile 2> >(tee -a debug.log >&2)
sudo chmod 664 /etc/dphys-swapfile 2> >(tee -a debug.log >&2)
sudo chown root /etc/dphys-swapfile 2> >(tee -a debug.log >&2)
sudo dphys-swapfile setup 2> >(tee -a debug.log >&2)
sleep 5
sudo dphys-swapfile swapon 2> >(tee -a debug.log >&2)
echo -e "\e[32mSwap file of 2GB Configured and enabled\e[0m"
sleep 3

##Clone PiNode-XMR to device from git
	echo "Clone PiNode-XMR to device from git" >>debug.log
echo -e "\e[32mDownloading PiNode-XMR files\e[0m"
sleep 3

git clone -b Raspbian-install --single-branch https://github.com/monero-ecosystem/PiNode-XMR.git 2> >(tee -a debug.log >&2)



##Configure ssh security. Allow only user 'pinodexmr' & 'root' login disabled, restart config to make changes
	echo "Configure ssh security" >>debug.log
echo -e "\e[32mConfiguring SSH security\e[0m"
sleep 3
sudo mv /home/pinodexmr/PiNode-XMR/etc/ssh/sshd_config /etc/ssh/sshd_config 2> >(tee -a debug.log >&2)
sudo chmod 644 /etc/ssh/sshd_config 2> >(tee -a debug.log >&2)
sudo chown root /etc/ssh/sshd_config 2> >(tee -a debug.log >&2)
sudo /etc/init.d/ssh restart 2> >(tee -a debug.log >&2)
echo -e "\e[32mSSH security config complete\e[0m"
sleep 3

##Disable IPv6 on boot. Enabled causes errors as Raspbian generates a IPv4 and IPv6 address and Monerod will fail with both.
echo -e "\e[32mDisable IPv6 on boot\e[0m"
sleep 3
sudo sed -i '1s/$/ ipv6.disable=1/' /boot/cmdline.txt
echo -e "\e[32mIPv6 Disabled on boot\e[0m"
sleep 3

##Enable PiNode-XMR on boot
	echo "Enable PiNode-XMR on boot" >>debug.log
echo -e "\e[32mEnable PiNode-XMR on boot\e[0m"
sleep 3
sudo mv /home/pinodexmr/PiNode-XMR/etc/rc.local /etc/rc.local 2> >(tee -a debug.log >&2)
sudo chmod 755 /etc/rc.local 2> >(tee -a debug.log >&2)
sudo chown root /etc/rc.local 2> >(tee -a debug.log >&2)
echo -e "\e[32mSuccess\e[0m"
sleep 3

##Add PiNode-XMR systemd services
	echo "Add PiNode-XMR systemd services" >>debug.log
echo -e "\e[32mAdd PiNode-XMR systemd services\e[0m"
sleep 3
sudo mv /home/pinodexmr/PiNode-XMR/etc/systemd/system/*.service /etc/systemd/system/ 2> >(tee -a debug.log >&2)
sudo chmod 644 /etc/systemd/system/*.service 2> >(tee -a debug.log >&2)
sudo chown root /etc/systemd/system/*.service 2> >(tee -a debug.log >&2)
sudo systemctl daemon-reload 2> >(tee -a debug.log >&2)
sudo systemctl start statusOutputs.service 2> >(tee -a debug.log >&2)
sudo systemctl enable statusOutputs.service 2> >(tee -a debug.log >&2)
echo -e "\e[32mSuccess\e[0m"
sleep 3

#Configure apache server for access to monero log file
sudo mv /home/pinodexmr/PiNode-XMR/etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-enabled/000-default.conf 2> >(tee -a debug.log >&2)
sudo chmod 777 /etc/apache2/sites-enabled/000-default.conf 2> >(tee -a debug.log >&2)
sudo chown root /etc/apache2/sites-enabled/000-default.conf 2> >(tee -a debug.log >&2)
sudo /etc/init.d/apache2 restart 2> >(tee -a debug.log >&2)

echo -e "\e[32mSuccess\e[0m"
sleep 3

##Setup local hostname
	echo "Setup local hostname" >>debug.log
sudo mv /home/pinodexmr/PiNode-XMR/etc/avahi/avahi-daemon.conf /etc/avahi/avahi-daemon.conf 2> >(tee -a debug.log >&2)
sudo /etc/init.d/avahi-daemon restart 2> >(tee -a debug.log >&2)

##Copy PiNode-XMR scripts to home folder
	echo "Copy PiNode-XMR scripts to home folder" >>debug.log
echo -e "\e[32mMoving PiNode-XMR scripts into possition\e[0m"
sleep 3
mv /home/pinodexmr/PiNode-XMR/home/pinodexmr/* /home/pinodexmr/ 2> >(tee -a debug.log >&2)
mv /home/pinodexmr/PiNode-XMR/home/pinodexmr/.profile /home/pinodexmr/ 2> >(tee -a debug.log >&2)
sudo chmod 777 -R /home/pinodexmr/* 2> >(tee -a debug.log >&2)
echo -e "\e[32mSuccess\e[0m"
sleep 3

##Configure Web-UI
	echo "Configure Web-UI" >>debug.log
echo -e "\e[32mConfiguring Web-UI\e[0m"
sleep 3
#First move hidden file specifically .htaccess file then entire directory
sudo mv /home/pinodexmr/PiNode-XMR/HTML/.htaccess /var/www/html/ 2> >(tee -a debug.log >&2)
sudo mv /home/pinodexmr/PiNode-XMR/HTML/*.* /var/www/html/ 2> >(tee -a debug.log >&2)
sudo mv /home/pinodexmr/PiNode-XMR/HTML/images /var/www/html 2> >(tee -a debug.log >&2)
sudo chown www-data -R /var/www/html/ 2> >(tee -a debug.log >&2)
sudo chmod 777 -R /var/www/html/ 2> >(tee -a debug.log >&2)

# SECTION TEMP REMOVED DUE TO BUILD ERRORS https://github.com/monero-ecosystem/PiNode-XMR/issues/46
#********************************************
#******START OF TEMP REMOVE SOURCE BULD******
#********************************************
# ##Build Monero and Onion Blockchain Explorer (the simple but time comsuming bit)
# 	echo "Build Monero" >>debug.log
# #First build monero, single build directory

# 	#Download release number
# wget -q https://raw.githubusercontent.com/monero-ecosystem/PiNode-XMR/master/release.sh -O /home/pinodexmr/release.sh 2> >(tee -a debug.log >&2)
# chmod 755 /home/pinodexmr/release.sh 2> >(tee -a debug.log >&2)
# . /home/pinodexmr/release.sh 2> >(tee -a debug.log >&2)

# echo -e "\e[32mDownloading Monero $RELEASE\e[0m"
# sleep 3
# #git clone --recursive https://github.com/monero-project/monero.git       #Dev Branch
# git clone --recursive -b $RELEASE https://github.com/monero-project/monero.git 2> >(tee -a debug.log >&2) #Latest Stable Branch
# echo -e "\e[32mBuilding Monero $RELEASE\e[0m"
# echo -e "\e[32m****************************************************\e[0m"
# echo -e "\e[32m****************************************************\e[0m"
# echo -e "\e[32m***This will take a 3-8hours - Hardware Dependent***\e[0m"
# echo -e "\e[32m****************************************************\e[0m"
# echo -e "\e[32m****************************************************\e[0m"
# sleep 10
# cd monero
# USE_SINGLE_BUILDDIR=1 make 2> >(tee -a debug.log >&2)
# cd
# #Make dir .bitmonero to hold lmdb. Needs to be added before drive mounted to give mount point. Waiting for monerod to start fails mount.
# mkdir .bitmonero 2> >(tee -a debug.log >&2)

# echo -e "\e[32mBuilding Monero Blockchain Explorer[0m"
# echo -e "\e[32m*******************************************************\e[0m"
# echo -e "\e[32m***This will take a few minutes - Hardware Dependent***\e[0m"
# echo -e "\e[32m*******************************************************\e[0m"
# sleep 10
# 		echo "Build Monero Onion Block Explorer" >>debug.log
# git clone https://github.com/moneroexamples/onion-monero-blockchain-explorer.git 2> >(tee -a debug.log >&2)
# cd onion-monero-blockchain-explorer 2> >(tee -a debug.log >&2)
# mkdir build && cd build 2> >(tee -a debug.log >&2)
# cmake .. 2> >(tee -a debug.log >&2)
# make 2> >(tee -a debug.log >&2)
# cd
#********************************************
#******END OF TEMP REMOVE SOURCE BULD********
#********************************************

#********************************************
#*******START OF TEMP BINARY USE*******
#********************************************

#Define Install Monero function to reduce repeat script
function f_installMonero {
echo "Downloading pre-built Monero from get.monero" >>debug.log
#Make standard location for Monero
mkdir -p ~/monero/build/release/bin
if [[ $CPU_ARCH -eq 64 ]]
then
  #Download 64-bit Monero
wget https://downloads.getmonero.org/cli/linuxarm8
#Make temp folder to extract binaries
mkdir temp && tar -xvf linuxarm8 -C ~/temp
#Move Monerod files to standard location
mv /home/pinodexmr/temp/monero-aarch64-linux-gnu-v0.17.3.2/monero* /home/pinodexmr/monero/build/release/bin/
rm linuxarm8
else
  #Download 32-bit Monero
wget https://downloads.getmonero.org/cli/linuxarm7
#Make temp folder to extract binaries
mkdir temp && tar -xvf linuxarm7 -C ~/temp
#Move Monerod files to standard location
mv /home/pinodexmr/temp/monero-arm-linux-gnueabihf-v0.17.3.2/monero* /home/pinodexmr/monero/build/release/bin/
rm linuxarm7
fi
#Make dir .bitmonero to hold lmdb. Needs to be added before drive mounted to give mount point. Waiting for monerod to start fails mount.
mkdir .bitmonero 2> >(tee -a debug.log >&2)
#Clean-up used downloaded files
rm -R ~/temp
}


if [[ $CPU_ARCH -ne 64 ]] && [[ $CPU_ARCH -ne 32 ]]
then
  if (whiptail --title "OS version" --yesno "I've tried to auto-detect what version of Monero you need based on your OS but I've not been successful.\n\nPlease select your OS architecture..." 8 78 --no-button "32-bit" --yes-button "64-bit"); then
    CPU_ARCH=64
	f_installMonero
	else
    CPU_ARCH=32
	f_installMonero
  fi
else
 f_installMonero
fi

#********************************************
#*******END OF TEMP BINARY USE*******
#********************************************

##Install crontab
		echo "Install crontab" >>debug.log
echo -e "\e[32mSetup crontab\e[0m"
sleep 3
sudo crontab /home/pinodexmr/PiNode-XMR/var/spool/cron/crontabs/root 2> >(tee -a debug.log >&2)
crontab /home/pinodexmr/PiNode-XMR/var/spool/cron/crontabs/pinodexmr 2> >(tee -a debug.log >&2)
echo -e "\e[32mSuccess\e[0m"
sleep 3

##Set RAM Swappiness lower
		echo "Set RAM Swappiness lower" >>debug.log
sudo sysctl vm.swappiness=10 2> >(tee -a debug.log >&2)

## Remove left over files from git clone actions
	echo "Remove left over files from git clone actions" >>debug.log
echo -e "\e[32mCleanup leftover directories\e[0m"
sleep 3
sudo rm -r /home/pinodexmr/PiNode-XMR/ 2> >(tee -a debug.log >&2)

##Change log in menu to 'main'
#Delete line 28 (previous setting)
wget -O ~/.profile https://raw.githubusercontent.com/monero-ecosystem/PiNode-XMR/Raspbian-install/home/pinodexmr/.profile 2> >(tee -a debug.log >&2)

##End debug log
echo "
####################
" >>debug.log
echo "End raspbian-pinodexmr.sh script $(date)" >>debug.log
echo "
####################
" >>debug.log

## Install complete
echo -e "\e[32mAll Installs complete\e[0m"
whiptail --title "PiNode-XMR Continue Install" --msgbox "Your PiNode-XMR is ready\n\nInstall complete. When you log in after the reboot use the menu to change your passwords and other features.\n\nEnjoy your Private Node\n\nSelect ok to reboot" 16 60
echo -e "\e[32m****************************************\e[0m"
echo -e "\e[32m**********PiNode-XMR rebooting**********\e[0m"
echo -e "\e[32m**********Reminder:*********************\e[0m"
echo -e "\e[32m**********User: 'pinodexmr'*************\e[0m"
echo -e "\e[32m**********Password: 'PiNodeXMR'*********\e[0m"
echo -e "\e[32m****************************************\e[0m"
sleep 10
sudo reboot
