#!/bin/bash

		#HEIGHT=20
		#WIDTH=60
		#CHOICE_HEIGHT=8
		CHOICE=$(whiptail --backtitle "Welcome" --title "PiNode-XMR Settings" --menu "\n\nWhat would you like to configure?" 20 60 10 \
	"1)" "Exit to Command line" \
    "2)" "System Settings" \
	"3)" "Update Tools" \
	"4)" "Node Tools" \
	"5)" "Extra Network Tools" 2>&1 >/dev/tty)
	
	case $CHOICE in
		
		"1)")
		;;
				
		"2)")CHOICE2=$(whiptail --backtitle "Welcome" --title "PiNode-XMR Settings" --menu "\n\nSystem Settings" 20 60 10 \
				"1)" "Hardware & WiFi Settings (raspi-config)" \
				"2)" "Master Login Password Set" \
				"3)" "Monero RPC Username and Password setup" \
				"4)" "USB storage setup" \
				"5)" "SD Card Health Checker" 2>&1 >/dev/tty)
				
				case $CHOICE2 in
		
					"1)")	whiptail --title "PiNode-XMR Settings" --msgbox "You will now be taken to the Raspbian menu to configure your hardware" 8 78;
							sudo raspi-config; . /home/pinodexmr/setup.sh
					;;
				
					"2)") 	if (whiptail --title "PiNode-XMR Set Password" --yesno "This will change your SSH/Web terminal log in password\n\nWould you like to continue?" 12 78); then
					. /home/pinodexmr/setup-password-master.sh
							else
					. /home/pinodexmr/setup.sh
							fi
					;;
					
					"3)") 	if (whiptail --title "PiNode-XMR Set Password" --yesno "This will set your credentials needed to connect your wallet to your node\n\nWould you like to continue?" 12 78); then
					. /home/pinodexmr/setup-password-monerorpc.sh
							else
					. /home/pinodexmr/setup.sh
							fi
					;;
			
					"4)")	if (whiptail --title "PiNode-XMR configure storage" --yesno "This will allow you to add USB storage for the Monero blockchain.\n\nConnect your device now.\n\nWould you like to continue?" 16 78); then
					. /home/pinodexmr/setup-usb-select-device.sh
							else
					. /home/pinodexmr/setup.sh
							fi
					;;
					
					"5)")	if (whiptail --title "PiNode-XMR MicroSD Health Check" --yesno "This utility (agnostics) will run speed tests on your SD card read/write functions to give an indication of its current health.\n\nBefore starting this check, stop all services that are currently reading/writing (Node and BlockExplorer) for most accurate results.\n\nWould you like to continue?" 16 78); then
					 clear;
					 echo -e "\e[32mChecking for required tools...\e[0m";
					 sudo apt install agnostics -y
					 echo -e "\e[32mSuccess\e[0m";
					 sleep 2;
					 echo -e "\e[32mRunning test script. This will take a few minutes...\e[0m";
					 sudo sh /usr/share/agnostics/sdtest.sh;
					 read -n 1 -s -r -p "Press any key to return to Menu"
							else
					. /home/pinodexmr/setup.sh
							fi
					;;
				esac
				. /home/pinodexmr/setup.sh
				;;
				
		"3)")CHOICE3=$(whiptail --backtitle "Welcome" --title "PiNode-XMR Settings" --menu "\n\nUpdate Tools" 20 60 10 \
				"1)" "Update Monero" \
				"2)" "Update PiNode-XMR" \
				"3)" "Update Blockchain Explorer" \
				"4)" "Update system packages and dependencies" 2>&1 >/dev/tty)
				
				case $CHOICE3 in
		
					"1)")	if (whiptail --title "PiNode-XMR Update Monero" --yesno "This will run a check to see if a Monero update is available\n\nIf an update is found PiNode-XMR will perform the update.\n\n***This will take several hours***\n\nWould you like to continue?" 12 78); then
							. /home/pinodexmr/setup-update-monero.sh
							else
							. /home/pinodexmr/setup.sh
							fi
						;;
				
					"2)")	if (whiptail --title "Update PiNode-XMR" --yesno "This will check for updates to PiNode-XMR Including performance, features and web interface\n\nWould you like to continue?" 12 78); then
							. /home/pinodexmr/setup-update-pinodexmr.sh
							else
							. /home/pinodexmr/setup.sh
							fi
						;;
			
					"3)")	if (whiptail --title "Update Onion-Blockchain-Explorer" --yesno "This will check for and install updates to your Blockchain Explorer\n\nIf updates are found they will be installed\n\nWould you like to continue?" 12 78); then
							. /home/pinodexmr/setup-update-explorer.sh
							else
							. /home/pinodexmr/setup.sh
							fi
						;;
						
					"4)")	if (whiptail --title "Update System" --yesno "PiNode-XMR will perform a check for background system updates of your OS's packages and dependencies.\n\nWould you like to continue?" 12 78); then
							clear; sudo apt-get update && sudo apt-get upgrade -y; sleep 3;
							. /home/pinodexmr/setup.sh
							else
							. /home/pinodexmr/setup.sh
							fi
						;;
				esac
				. /home/pinodexmr/setup.sh
				;;

		"4)")CHOICE4=$(whiptail --backtitle "Welcome" --title "PiNode-XMR Settings" --menu "\n\nNode Tools" 20 60 10 \
				"1)" "Start/Stop Blockchain Explorer" \
				"2)" "Prune Node" \
				"3)" "Pop Blocks" 2>&1 >/dev/tty)
				
				case $CHOICE4 in
							"1)") . /home/pinodexmr/setup-explorer.sh	#Has functional legacy script, will change this format one day.
								;;
								
							"2)")	if (whiptail --title "PiNode-XMR Prune Monero Node" --yesno "This will configure your node to run 'pruned' to reduce storage space required for the blockchain\n\n***This command only be run once and cannot be undone***\n\nAre you sure you want to continue?" 12 78); then
									. /home/pinodexmr/setup-prune-node.sh
									else
									. /home/pinodexmr/setup.sh
									fi
								;;
				
							"3)")	if (whiptail --title "PiNode-XMR Pop Blocks" --yesno "If you have errors for duplicate transactions in your log file, you may be able to 'pop' off the last blocks from the chain to un-freeze the sync process without syncing from scratch\n\nStop your Monero node before performing this action\n\nWould you like to continue?" 14 78); then
									. /home/pinodexmr/pop-blocks.sh
									else
									. /home/pinodexmr/setup.sh
									fi
								;;
			
				esac
				. /home/pinodexmr/setup.sh
				;;

		"5)")CHOICE5=$(whiptail --backtitle "Welcome" --title "PiNode-XMR Settings" --menu "\n\nExtra Network Tools" 30 60 15 \
				"1)" "Install tor" \
				"2)" "View tor NYX interface" \
				"3)" "Start/Stop tor Service" \
				"4)" "Install I2P Server/Router" \
				"5)" "Start/Stop I2P Server/Router" \
				"6)" "Install PiVPN" \
				"7)" "Install NoIP.com Dynamic DNS" 2>&1 >/dev/tty)
				
				case $CHOICE5 in
		
							"1)")	if (whiptail --title "PiNode-XMR Install tor" --yesno "Some countries for censorship, political or legal reasons do not look favorably on tor and other anonymity services, so tor is not installed on this device by default. However this option can install it now for you.\n\nWould you like to continue?" 14 78); then
									. /home/pinodexmr/setup-tor.sh
									else
									. /home/pinodexmr/setup.sh
									fi
								;;

							"2)")if (whiptail --title "PiNode-XMR tor NYX" --yesno "This tool will allow you to monitor tor bandwidth usage\n\nWhen prompted for a password, enter 'PiNodeXMR'\nAnd to exit the utility press 'CTRL+C' \n\nWould you like to continue?" 12 78); then
									nyx; . /home/pinodexmr/setup.sh
									else
									. /home/pinodexmr/setup.sh
									fi
								;;
								
							"3)")if (whiptail --title "PiNode-XMR Start/Stop tor" --yesno "Manually Start or Stop the service." --yes-button "Start tor" --no-button "Stop tor"  14 78); then
									sudo systemctl start tor
									sudo systemctl enable tor
									whiptail --title "PiNode-XMR tor" --msgbox "The tor service has been started" 12 78;
									. /home/pinodexmr/setup.sh
									else
									sudo systemctl stop tor
									sudo systemctl disable tor
									whiptail --title "PiNode-XMR tor" --msgbox "The tor service has been stopped" 12 78;
									. /home/pinodexmr/setup.sh
									fi
								;;
								
							"4)")if (whiptail --title "PiNode-XMR Install I2P" --yesno "This will install the I2P server/router onto your PiNode-XMR\n\nWould you like to continue?" 14 78); then
									. /home/pinodexmr/setup-i2p.sh
									else
									. /home/pinodexmr/setup.sh
									fi
								;;
							
							"5)")if (whiptail --title "PiNode-XMR Start/Stop I2P" --yesno "Manually Start or Stop the service." --yes-button "Start I2P" --no-button "Stop I2P"  14 78); then
									i2prouter start;
									whiptail --title "PiNode-XMR I2P" --msgbox "I2P server has been started\n\nYou now have access to the I2P config menu found at $(hostname -I | awk '{print $1}'):7657" 12 78;
									. /home/pinodexmr/setup.sh
									else
									i2prouter stop;
									whiptail --title "PiNode-XMR I2P" --msgbox "I2P server has been stopped" 12 78;
									. /home/pinodexmr/setup.sh
									fi
								;;
								
							"6)")	if (whiptail --title "PiNode-XMR PiVPN Install" --yesno "This feature will install PiVPN on your PiNode-XMR\n\nPiVPN is a simple to configure openVPN server.\n\nFor more info see https://pivpn.dev/\n\nWould you like to continue?" 12 78); then
									. /home/pinodexmr/setup-PiVPN.sh
									else
									. /home/pinodexmr/setup.sh
									fi
								;;
								
							"7)")	if (whiptail --title "PiNode-XMR Configure Dynamic DNS" --yesno "This will configure Dynamic DNS from NoIP.com\n\nFirst create a free account with them and have your username and password before continuing\n\nWould you like to continue?" 12 78); then
									. /home/pinodexmr/setup-noip.sh
									else
									. /home/pinodexmr/setup.sh
									fi
								;;								

				esac
				. /home/pinodexmr/setup.sh
				;;
esac
clear
