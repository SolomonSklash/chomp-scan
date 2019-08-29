#!/usr/bin/env bash

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
		echo -e "$GREEN""[+] Installing for Kali.""$NC";
		sudo apt-get update;
	 	sudo apt-get install git wget curl nmap masscan whatweb sublist3r gobuster nikto wafw00f chromium openssl libnet-ssleay-perl p7zip-full build-essential python-pip python3-pip unzip -y;
		install_pip;
		install_dnscan;
		install_bfac;
		install_massdns;
		install_aquatone;
		install_sublist3r;
		install_corstest;
		install_s3scanner;
		install_amass;
		install_dirsearch;
		install_knockpy;
		install_go;
		install_go_tools;
}
function install_parrot() {
		echo -e "$GREEN""[+] Installing for ParrotOS.""$NC";
		sudo apt-get update;
	 	sudo apt-get install git wget curl nmap masscan whatweb sublist3r gobuster nikto wafw00f chromium openssl libnet-ssleay-perl p7zip-full build-essential python-pip python3-pip unzip -y;
		install_pip;
		install_dnscan;
		install_bfac;
		install_massdns;
		install_aquatone;
		install_sublist3r;
		install_corstest;
		install_s3scanner;
		install_amass;
		install_dirsearch;
		install_knockpy;
		install_go;
		install_go_tools;
}
function install_debian() {
		echo -e "$GREEN""[+] Installing for Debian.""$NC";
		sudo apt-get update;
		sudo apt-get install git wget curl nmap masscan whatweb chromium openssl libnet-ssleay-perl p7zip-full build-essential python-pip python3-pip unzip -y;
		install_pip;
		sudo pip install wafw00f;
		install_dnscan;
		install_bfac;
		install_massdns;
		install_aquatone;
		install_sublist3r;
		install_corstest;
		install_s3scanner;
		install_nikto;
		install_amass;
		install_dirsearch;
		install_knockpy;
		install_go;
		install_go_tools;
}
function install_ubuntu() {
		echo -e "$GREEN""[+] Installing for Ubuntu.""$NC";
		sudo apt-get update;
		sudo apt-get install git wget curl nmap masscan nikto whatweb wafw00f chromium-browser python-pip python3-pip p7zip-full unzip -y;
		install_pip;
		install_dnscan;
		install_bfac;
		install_massdns;
		install_aquatone;
		install_sublist3r;
		install_corstest;
		install_s3scanner;
		install_amass;
		install_dirsearch;
		install_knockpy;
		install_go;
		install_go_tools;
}

function install_pip() {
		# Run both pip installs
		 echo -e "$GREEN""[+] Installing requirements for Python 2 and Python 3.""$NC";
		sudo pip2 install -q -r requirements2.txt;
		sudo pip3 install -q -r requirements3.txt;
}

function install_dnscan() {
		if [[ -d "$TOOLS"/dnscan ]]; then
				echo -e "$GREEN""[+] Updating dnscan.""$NC";
				cd "$TOOLS"/dnscan;
				git pull;
				cd -;
		else
		echo -e "$GREEN""[+] Installing dnscan from Github.""$NC";
		git clone https://github.com/rbsec/dnscan.git "$TOOLS"/dnscan;
		fi
}

function install_bfac() {
		if [[ -d "$TOOLS"/bfac ]]; then
				echo -e "$GREEN""[+] Updating bfac.""$NC";
				cd "$TOOLS"/bfac;
				git pull;
				cd -;
		else
		echo -e "$GREEN""[+] Installing bfac from Github.""$NC";
		git clone https://github.com/mazen160/bfac.git "$TOOLS"/bfac;
		fi
}

function install_massdns() {
		if [[ -d "$TOOLS"/massdns ]]; then
				echo -e "$GREEN""[+] Updating massdns.""$NC";
				cd "$TOOLS"/massdns;
				git pull;
				cd -;
		else
		echo -e "$GREEN""[+] Installing massdns from Github.""$NC";
		git clone https://github.com/blechschmidt/massdns.git "$TOOLS"/massdns;
		fi
		
		# Compile massdns
		echo -e "$GREEN""[+] Compiling massdns from source.""$NC";
		cd "$TOOLS"/massdns;
		make;
		cd -;
}

function install_aquatone() {
		echo -e "$GREEN""[+] Installing aquatone 1.7.0 from Github.""$NC";
		mkdir -pv "$TOOLS"/aquatone;
		wget -nv https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_amd64_1.7.0.zip -O "$TOOLS"/aquatone.zip;
		unzip -o "$TOOLS"/aquatone.zip -d "$TOOLS"/aquatone;
		rm "$TOOLS"/aquatone.zip;
}

function install_sublist3r() {
		if [[ -d "$TOOLS"/Sublist3r ]]; then
				echo -e "$GREEN""[+] Updating sublist3r.""$NC";
				cd "$TOOLS"/Sublist3r;
				git pull;
				cd -;
		else
		echo -e "$GREEN""[+] Installing sublist3r from Github.""$NC";
		git clone https://github.com/aboul3la/Sublist3r.git "$TOOLS"/Sublist3r;
		fi
}

function install_nikto() {
		if [[ -d "$TOOLS"/nikto ]]; then
				echo -e "$GREEN""[+] Updating nikto.""$NC";
				cd "$TOOLS"/nikto;
				git pull;
				cd -;
		else
		echo -e "$GREEN""[+] Installing nikto from Github.""$NC";
		git clone https://github.com/sullo/nikto.git "$TOOLS"/nikto;
		fi
}

function install_dirsearch() {
		if [[ -d "$TOOLS"/dirsearch ]]; then
				echo -e "$GREEN""[+] Updating dirsearch.""$NC";
				cd "$TOOLS"/dirsearch;
				git pull;
				cd -;
		else
		echo -e "$GREEN""[+] Installing dirsearch from Github.""$NC";
		git clone https://github.com/maurosoria/dirsearch.git "$TOOLS"/dirsearch;
		fi
}

function install_corstest() {
		if [[ -d "$TOOLS"/CORStest ]]; then
				echo -e "$GREEN""[+] Updating CORStest.""$NC";
				cd "$TOOLS"/CORStest;
				git pull;
				cd -;
		else
		echo -e "$GREEN""[+] Installing CORStest from Github.""$NC";
		git clone https://github.com/RUB-NDS/CORStest.git "$TOOLS"/CORStest;
		fi
}

function install_s3scanner() {
		if [[ -d "$TOOLS"/S3Scanner ]]; then
				echo -e "$GREEN""[+] Updating S3Scanner.""$NC";
				cd "$TOOLS"/S3Scanner;
				git pull;
				cd -;
		else
		echo -e "$GREEN""[+] Installing S3Scanner from Github.""$NC";
		git clone https://github.com/sa7mon/S3Scanner.git "$TOOLS"/S3Scanner;
		fi
}

function install_knockpy() {
		if [[ -d "$TOOLS"/knock ]]; then
				echo -e "$GREEN""[+] Updating Knockpy.""$NC";
				cd "$TOOLS"/knock;
				git pull;
				cd -;
		else
		echo -e "$GREEN""[+] Installing Knockpy from Github.""$NC";
		git clone https://github.com/SolomonSklash/knock.git "$TOOLS"/knock;
		cd "$TOOLS"/knock;
		sudo python setup.py install;
		cd -;
		fi
}

function install_go_tools() {
		source $HOME/.profile;
		echo -e "$GREEN""[+] Installing Go tools from Github.""$NC";
		sleep 1;
		echo -e "$GREEN""[+] Installing subfinder from Github.""$NC";
		go get -u github.com/subfinder/subfinder;
		echo -e "$GREEN""[+] Installing subjack from Github.""$NC";
		go get -u github.com/haccer/subjack;
		echo -e "$GREEN""[+] Installing ffuf from Github.""$NC";
		go get -u github.com/ffuf/ffuf;
		echo -e "$GREEN""[+] Installing gobuster from Github.""$NC";
		go get -u github.com/OJ/gobuster;
		echo -e "$GREEN""[+] Installing inception from Github.""$NC";
		go get -u github.com/proabiral/inception;
		echo -e "$GREEN""[+] Installing waybackurls from Github.""$NC";
		go get -u github.com/tomnomnom/waybackurls;
		echo -e "$GREEN""[+] Installing goaltdns from Github.""$NC";
		go get -u github.com/subfinder/goaltdns;
		echo -e "$GREEN""[+] Installing rescope from Github.""$NC";
        go get -u github.com/root4loot/rescope;
		echo -e "$GREEN""[+] Installing httprobe from Github.""$NC";
		go get -u github.com/tomnomnom/httprobe;
}

function install_go() {
		if [[ -e /usr/local/go/bin/go ]]; then
				echo -e "$GREEN""[i] Go is already installed, skipping installation.""$NC";
				return;
		fi
		echo -e "$GREEN""[+] Installing Go 1.12 from golang.org.""$NC";
		wget -nv https://dl.google.com/go/go1.12.linux-amd64.tar.gz;
		sudo tar -C /usr/local -xzf go1.12.linux-amd64.tar.gz;
		echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin:" >> "$HOME"/.profile;
		echo "export GOPATH=$HOME/go" >> "$HOME"/.profile;
		source "$HOME"/.profile;
		rm -rf go1.12.linux-amd64.tar.gz;
}

function install_amass() {
		if [[ -d "$TOOLS"/amass ]]; then
				rm -rf "$TOOLS"/amass;
		fi
		echo -e "$GREEN""[+] Installing amass 3.0.27 from Github.""$NC";
		wget -nv https://github.com/OWASP/Amass/releases/download/v3.0.27/amass_v3.0.27_linux_amd64.zip -O "$TOOLS"/amass.zip;
		unzip -j "$TOOLS"/amass.zip -d "$TOOLS"/amass;
		rm "$TOOLS"/amass.zip;
}

# Check for custom path
CUSTOM_PATH=$1;
if [[ "$CUSTOM_PATH" != "" ]]; then
		if [[ -e "$1" ]]; then
				TOOLS="$CUSTOM_PATH";
		else
				echo -e "$RED""The path provided does not exist or can't be opened""$NC";
				exit 1;
		fi
fi

# Create install directory
mkdir -pv "$HOME"/bounty/tools;

grep 'Ubuntu' /etc/issue 1>/dev/null;
UBUNTU="$?";
grep 'Debian' /etc/issue 1>/dev/null;
DEBIAN="$?";
grep 'Kali' /etc/issue 1>/dev/null;
KALI="$?";
grep 'Parrot' /etc/issue 1>/dev/null;
PARROT="$?";
if [[ "$UBUNTU" == 0 ]]; then 
		install_ubuntu;
elif [[ "$DEBIAN" == 0 ]]; then
		install_debian;
elif [[ "$KALI" == 0 ]]; then
		install_kali;
elif [[ "$PARROT" == 0 ]]; then
		install_parrot;
else
		echo -e "$RED""Unsupported distro detected. Exiting...""$NC";
		exit 1;
fi

echo -e "$BLUE""[i] Please run 'source ~/.profile' to add the Go binary path to your \$PATH variable, then run Chomp Scan.""$NC";
echo -e "$ORANGE""[i] Note: In order to use S3Scanner, you must configure your personal AWS credentials in the aws CLI tool.""$NC";
echo -e "$ORANGE""[i] See https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html for details.""$NC";
