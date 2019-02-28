#!/bin/bash

# Grep /etc/issue for Ubuntu
# Check return code of grep
# If 0, assume Ubuntu
# Else, repeat with Debian
# Else, repeat with Kali
# Else, exit with unknown distro error

# If Ubuntu, run Ubuntu apt-get install list
sudo apt-get install git wget nmap masscan nikto whatweb wafw00f chromium-browser python-pip python3-pip p7zip-full;
# If Debian, run Debian apt-get install list
sudo apt-get install git wget nmap masscan whatweb chromium openssl libnet-ssleay-perl p7zip-full build-essential python-pip python3-pip;

# Run both pip installs
sudo pip2 install -r requirements2.txt;
sudo pip3 install -r requirements3.txt;

# Create ~/bounty/tools directory

# Clone all repos

# Attempt to install Go
# Check for Bash shell

# Install go tools

# Install gobuster (wget from github)

# Install aquatone

# Compile massdns
