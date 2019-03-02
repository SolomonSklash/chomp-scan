#!/bin/bash

# Colors
NC='\033[0m';
RED='\033[0;31m';
GREEN='\033[0;32m';
BLUE='\033[0;34m';
ORANGE='\033[0;33m';

UBUNTU=;
DEBIAN=;
KALI=;
TOOLS="$HOME/bounty/tools";

function install_kali() {
		echo -e "$GREEN""Installing for Kali.""$NC";
	 	sudo apt-get install git wget curl nmap masscan whatweb sublist3r gobuster nikto wafw00f chromium openssl libnet-ssleay-perl p7zip-full build-essential python-pip python3-pip -y;
		install_pip;
		install_dnscan;
		install_altdns;
		install_bfac;
		install_massdns;
		install_aquatone;
		install_gobuster;
		install_go_tools;
}
function install_debian() {
		echo -e "$GREEN""Installing for Debian.""$NC";
		sudo apt-get install git wget curl nmap masscan whatweb chromium openssl libnet-ssleay-perl p7zip-full build-essential python-pip python3-pip -y;
		install_pip;
		install_dnscan;
		install_altdns;
		install_bfac;
		install_massdns;
		install_aquatone;
		install_sublist3r;
		install_gobuster;
		install_nikto;
		install_wafw00f;
		install_go_tools;
		install_go;
}
function install_ubuntu() {
		echo -e "$GREEN""Installing for Ubuntu.""$NC";
		sudo apt-get install git wget curl nmap masscan nikto whatweb wafw00f chromium-browser python-pip python3-pip p7zip-full -y;
		install_pip;
		install_dnscan;
		install_altdns;
		install_bfac;
		install_massdns;
		install_aquatone;
		install_sublist3r;
		install_gobuster;
		install_go_tools;
		install_go;
}

function install_pip() {
		# Run both pip installs
		 echo -e "$GREEN""Installing requirements for Python 2 and Python 3.""$NC";
		sudo pip2 install -r requirements2.txt;
		sudo pip3 install -r requirements3.txt;
}

function install_dnscan() {
		echo -e "$GREEN""Installing dnscan from Github.""$NC";
		git clone https://github.com/rbsec/dnscan.git "$TOOLS"/dnscan;
}

function install_altdns() {
		echo -e "$GREEN""Installing altdns from Github.""$NC";
		git clone https://github.com/infosec-au/altdns.git "$TOOLS"/altdns;
}

function install_bfac() {
		echo -e "$GREEN""Installing bfac from Github.""$NC";
		git clone https://github.com/mazen160/bfac.git "$TOOLS"/bfac;
}

function install_massdns() {
		echo -e "$GREEN""Installing massdns from Github.""$NC";
		git clone https://github.com/blechschmidt/massdns.git "$TOOLS"/massdns;
		
		# Compile massdns
		echo -e "$GREEN""Compiling massdns from source.""$NC";
		cd "$TOOLS"/massdns;
		make;
		cd -;
}

function install_aquatone() {
		echo -e "$GREEN""Installing aquatone from Github.""$NC";
		wget https://github.com/michenriksen/aquatone/releases/download/v1.4.3/aquatone_linux_amd64_1.4.3.zip -O "$TOOLS"/aquatone/aquatone.zip;
		unzip "$TOOLS"/aquatone/aquatone.zip -d "$TOOLS"/aquatone;
}

function install_sublist3r() {
		echo -e "$GREEN""Installing sublist3r from Github.""$NC";
		git clone https://github.com/aboul3la/Sublist3r.git "$TOOLS"/Sublist3r;
}

function install_nikto() {
		echo -e "$GREEN""Installing nikto from Github.""$NC";
		git clone https://github.com/sullo/nikto.git "$TOOLS"/nikto;
}

function install_gobuster() {
		echo -e "$GREEN""Installing gobuster from Github.""$NC";
		mkdir -pv "$TOOLS"/gobuster;
		wget https://github.com/OJ/gobuster/releases/download/v2.0.1/gobuster-linux-amd64.7z -O "$TOOLS"/gobuster/gobuster-linux-amd64.7z;
		cd "$TOOLS"/gobuster;
		7z e gobuster-linux-amd64.7z;
		chmod +x "$TOOLS"/gobuster/gobuster;
		cd -;
}

function install_wafw00f() {
		echo -e "$GREEN""Installing wafw00f from Github.""$NC";
		git clone https://github.com/EnableSecurity/wafw00f.git "$TOOLS"/wafw00f;
}

function install_go_tools() {
		echo -e "$GREEN""Installing Go tools from Github.""$NC";
		echo -e "$GREEN""Installing subfinder from Github.""$NC";
		go get github.com/subfinder/subfinder;
		echo -e "$GREEN""Installing subjack from Github.""$NC";
		go get github.com/haccer/subjack;
		echo -e "$GREEN""Installing ffuf from Github.""$NC";
		go get github.com/ffuf/ffuf;
}

function install_go() {
		echo -e "$GREEN""Installing Go from golang.org.""$NC";
		wget https://dl.google.com/go/go1.12.linux-amd64.tar.gz;
		sudo tar -C /usr/local -xzf go1.12.linux-amd64.tar.gz;
		echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin:" >> ~/.profile;
		source ~/.profile;
		rm -rf go1.12.linux-amd64.tar.gz;
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

# Create install directory
mkdir -pv ~/bounty/tools;
