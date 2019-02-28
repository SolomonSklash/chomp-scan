#!/bin/bash

# Colors
NC='\033[0m';
RED='\033[0;31m';
GREEN='\033[0;32m';
BLUE='\033[0;34m';
ORANGE='\033[0;33m';

# Grep /etc/issue for Ubuntu
# Check return code of grep
# If 0, assume Ubuntu
UBUNTU=;
DEBIAN=;
KALI=;

function install_kali() {
		echo -e "$GREEN""Installing for Kali.""$NC";
	 	# sudo apt-get install git wget nmap masscan whatweb sublist3r gobuster chromium openssl libnet-ssleay-perl p7zip-full build-essential python-pip python3-pip;
		install_pip;
}
function install_debian() {
		echo -e "$GREEN""Installing for Debian.""$NC";
		# sudo apt-get install git wget nmap masscan whatweb chromium openssl libnet-ssleay-perl p7zip-full build-essential python-pip python3-pip;
		install_pip;
}
function install_ubuntu() {
		echo -e "$GREEN""Installing for Ubuntu.""$NC";
		# sudo apt-get install git wget nmap masscan nikto whatweb wafw00f chromium-browser python-pip python3-pip p7zip-full;
		install_pip;
}

function install_pip() {
		# Run both pip installs
		 echo -e "$GREEN""Installing requirements for Python 2 and Python 3.""$NC";
		# sudo pip2 install -r requirements2.txt;
		# sudo pip3 install -r requirements3.txt;
}

grep 'Ubuntu' /etc/issue 1>/dev/null;
UBUNTU="$?";
grep 'Debian' /etc/issue 1>/dev/null;
DEBIAN="$?";
grep 'Kali' /etc/issue 1>/dev/null;
KALI="$?";
if [[ "$UBUNTU" == 0 ]]; then 
		install_ubuntu;
elif [[ "$DEBIAN" == 0 ]]; then
		install_debian;
elif [[ "$KALI" == 0 ]]; then
		install_kali;
else
		echo -e "$RED""Unsupported distro detected. Exiting...""$NC";
		exit 1;
fi

# Create ~/bounty/tools directory

# Clone repos for each distro

# Attempt to install Go
# Check for Bash shell

# Install go tools

# Install gobuster (wget from github)

# Install aquatone

# Compile massdns

