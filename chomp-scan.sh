#!/bin/bash

# Colors
NC='\033[0m';
RED='\033[0;31m';
GREEN='\033[0;32m';
BLUE='\033[0;34m';
ORANGE='\033[0;33m';
DOMAIN=$1;

# Wordlists
SHORT=wordlists/subdomains-top1mil-20000.txt;
LONG=wordlists/sortedcombined-knock-dnsrecon-fierce-reconng.txt;
HUGE=wordlists/huge-200k.txt;
SMALL=wordlists/big.txt;
MEDIUM=wordlists/raft-large-combined.txt;
LARGE=wordlists/seclists-combined.txt;
XL=wordlists/haddix_content_discovery_all.txt;
XXL=wordlists/haddix-seclists-combined.txt;

# Tool paths
SUBFINDER=$(command -v subfinder);
SUBLIST3R=$(command -v sublist3r);
SUBJACK=$(command -v subjack);
FFUF=$(command -v ffuf);
WHATWEB=$(command -v whatweb);
WAFW00F=$(command -v wafw00f);
#GOBUSTER=$(command -v gobuster);
CHROMIUM=$(command -v chromium);
DNSCAN=~/bounty/tools/dnscan/dnscan.py;
ALTDNS=~/bounty/tools/altdns/altdns.py;
MASSDNS_BIN=~/bounty/tools/massdns/bin/massdns;
MASSDNS_RESOLVERS=~/bounty/tools/massdns/lists/resolvers.txt;
AQUATONE=~/bounty/tools/aquatone/aquatone;
BFAC=~/bounty/tools/bfac/bfac;

# Other variables
INTERESTING=interesting.txt;
BLACKLIST=blacklist.txt;
ALL_IP=all_ip.txt;
ALL_DOMAIN=all_domain.txt;
WORKING_DIR="$1"-$(date +%T);

# Check for domain argument
if [ $# -eq 0 ]; then
		    echo -e "$RED""No domain provided!\\n""$NC";
			echo -e "$GREEN""Usage: $0 example.com""$NC";
			exit;
fi

BANNER='
*****************************************************************************************************
*   ______  __                                              ______                                  *
*  /      \/  |                                            /      \                                 *
* /$$$$$$  $$ |____   ______  _____  ____   ______        /$$$$$$  | _______  ______  _______       *
* $$ |  $$/$$      \ /      \/     \/    \ /      \       $$ \__$$/ /       |/      \/       \      *
* $$ |     $$$$$$$  /$$$$$$  $$$$$$ $$$$  /$$$$$$  |      $$      \/$$$$$$$/ $$$$$$  $$$$$$$  |     *
* $$ |   __$$ |  $$ $$ |  $$ $$ | $$ | $$ $$ |  $$ |       $$$$$$  $$ |      /    $$ $$ |  $$ |     *
* $$ \__/  $$ |  $$ $$ \__$$ $$ | $$ | $$ $$ |__$$ |      /  \__$$ $$ \_____/$$$$$$$ $$ |  $$ |     *
* $$    $$/$$ |  $$ $$    $$/$$ | $$ | $$ $$    $$/       $$    $$/$$       $$    $$ $$ |  $$ |     *
*  $$$$$$/ $$/   $$/ $$$$$$/ $$/  $$/  $$/$$$$$$$/         $$$$$$/  $$$$$$$/ $$$$$$$/$$/   $$/      *
*                                         $$ |                                                      *
*                                         $$ |                                                      *
*                                         $$/                                                       *
*                                                                                                   *
*****************************************************************************************************
By SolomonSklash - github.com/SolomonSklash/chomp-scan
';
echo -e "$BLUE""$BANNER";

function check_paths() {
		# Check that all paths are set
		if [[ "$DNSCAN" == "" ]] || [[ ! -f "$DNSCAN" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for dnscan does not exit.";
				exit;
		fi
		if [[ "$SUBFINDER" == "" ]] || [[ ! -f "$SUBFINDER" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for subfinder does not exit.";
				exit;
		fi
		if [[ "$SUBLIST3R" == "" ]] || [[ ! -f "$SUBLIST3R" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for sublist3r does not exit.";
				exit;
		fi
		if [[ "$SUBJACK" == "" ]] || [[ ! -f "$SUBJACK" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for subjack does not exit.";
				exit;
		fi
		if [[ "$ALTDNS" == "" ]] || [[ ! -f "$ALTDNS" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for altdns does not exit.";
				exit;
		fi
		if [[ "$MASSDNS_BIN" == "" ]] || [[ ! -f "$MASSDNS_BIN" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for the massdns binary does not exit.";
				exit;
		fi
		if [[ "$MASSDNS_RESOLVERS" == "" ]] || [[ ! -f "$MASSDNS_RESOLVERS" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for massdns resolver file does not exit.";
				exit;
		fi
		if [[ "$AQUATONE" == "" ]] || [[ ! -f "$AQUATONE" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for aquatone does not exit.";
				exit;
		fi
		if [[ "$FFUF" == "" ]] || [[ ! -f "$FFUF" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for ffuf does not exit.";
				exit;
		fi
		if [[ "$BFAC" == "" ]] || [[ ! -f "$BFAC" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for bfac does not exit.";
				exit;
		fi
		if [[ "$CHROMIUM" == "" ]] || [[ ! -f "$CHROMIUM" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for chromium does not exit.";
				exit;
		fi
		# if [[ "$GOBUSTER" == "" ]] || [[ ! -f "$GOBUSTER" ]]; then
		# 		echo -e "$RED""[!] The path or the file specified by the path for gobuster does not exit.";
		# 		exit;
		# fi
		if [[ "$WHATWEB" == "" ]] || [[ ! -f "$WHATWEB" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for whatweb does not exit.";
				exit;
		fi
		if [[ "$WAFW00F" == "" ]] || [[ ! -f "$WAFW00F" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for wafw00f does not exit.";
				exit;
		fi
}

check_paths;

SCAN_START=$(date +%s);
mkdir "$WORKING_DIR";
touch "$WORKING_DIR"/interesting-domains.txt;
INTERESTING_DOMAINS=interesting-domains.txt;
touch "$WORKING_DIR"/"$ALL_DOMAIN";
touch "$WORKING_DIR"/"$ALL_IP";

function unique() {
		# Remove domains from blacklist
		if [[ ! -z $BLACKLIST ]]; then 
				while read -r bad; do
						grep -v "$bad" "$WORKING_DIR"/$ALL_DOMAIN > "$WORKING_DIR"/temp1;
						mv "$WORKING_DIR"/temp1  "$WORKING_DIR"/$ALL_DOMAIN;
				done < $BLACKLIST;
		fi

		# Get unique list of IPs and domains, ignoring case
		sort "$WORKING_DIR"/$ALL_DOMAIN | uniq -i > "$WORKING_DIR"/temp2;
		mv "$WORKING_DIR"/temp2 "$WORKING_DIR"/$ALL_DOMAIN;
		sort -V "$WORKING_DIR"/$ALL_IP | uniq -i > "$WORKING_DIR"/temp2;
		mv "$WORKING_DIR"/temp2 "$WORKING_DIR"/$ALL_IP;
}

function list_found() {
		unique;
		echo -e "$GREEN""[+] Found $(wc -l "$WORKING_DIR"/$ALL_IP | cut -d ' ' -f 1) unique IPs so far.""$NC"
		echo -e "$GREEN""[+] Found $(wc -l "$WORKING_DIR"/$ALL_DOMAIN | cut -d ' ' -f 1) unique domains so far.""$NC"
}

function get_interesting() {
		while read -r word; do
				grep "$word" "$WORKING_DIR"/$ALL_DOMAIN >> "$WORKING_DIR"/"$INTERESTING_DOMAINS";
		done < $INTERESTING;

		# Make sure no there are duplicates
		sort -u "$WORKING_DIR"/"$INTERESTING_DOMAINS" > "$WORKING_DIR"/tmp3;
		mv "$WORKING_DIR"/tmp3 "$WORKING_DIR"/"$INTERESTING_DOMAINS";

		# Make sure > 0 domains are found
		FOUND=$(wc -l "$WORKING_DIR"/interesting-domains.txt | cut -d ' ' -f 1);
		if [[ $FOUND -gt 0 ]]; then
				echo -e "$RED""[!] The following $(wc -l "$WORKING_DIR"/interesting-domains.txt | cut -d ' ' -f 1) potentially interesting subdomains have been found ($WORKING_DIR/interesting-domains.txt):""$ORANGE";
				cat "$WORKING_DIR"/"$INTERESTING_DOMAINS";
				sleep 1;
		else
				echo -e "$RED""[!] No interesting domains have been found yet.""$NC";
				sleep 1;
		fi
}

function cancel() {
		echo -e "$RED""\\n[!] Cancelling command.""$NC";
}

function run_dnscan() {
		# Call with domain as $1 and wordlist as $2

		# Trap SIGINT so broken dnscan runs can be cancelled
		trap cancel SIGINT;

		echo -e "$GREEN""[i]$BLUE Scanning $1 with dnscan.""$NC";
		echo -e "$GREEN""[i]$ORANGE Command: $DNSCAN -d $1 -t 25 -o $WORKING_DIR/dnscan_out.txt -w $2.""$NC";
		START=$(date +%s);
		$DNSCAN -d "$1" -t 25 -o "$WORKING_DIR"/dnscan_out.txt -w "$2";
		END=$(date +%s);
		DIFF=$(( END - START ));

		# Remove headers and leading spaces
		sed '1,/A records/d' "$WORKING_DIR"/dnscan_out.txt | tr -d ' ' > "$WORKING_DIR"/trimmed;
		cut "$WORKING_DIR"/trimmed -d '-' -f 1 > "$WORKING_DIR"/dnscan-ips.txt;
		cut "$WORKING_DIR"/trimmed -d '-' -f 2 > "$WORKING_DIR"/dnscan-domains.txt;
		rm "$WORKING_DIR"/trimmed;

		# Cat output into main lists
		cat "$WORKING_DIR"/dnscan-ips.txt >> "$WORKING_DIR"/$ALL_IP;
		cat "$WORKING_DIR"/dnscan-domains.txt >> "$WORKING_DIR"/"$ALL_DOMAIN";

		echo -e "$GREEN""[i]$BLUE dnsscan took $DIFF seconds to run.""$NC";
		echo -e "$GREEN""[!]$ORANGE dnscan found $(wc -l "$WORKING_DIR"/dnscan-ips.txt | cut -d ' ' -f 1) IP/domain pairs.""$NC";
		list_found;
		sleep 1;

		# Check if Ctrl+C was pressed and added to domain and IP files
		grep -v 'KeyboardInterrupt' "$WORKING_DIR"/"$ALL_DOMAIN" > "$WORKING_DIR"/tmp;
		mv "$WORKING_DIR"/tmp "$WORKING_DIR"/"$ALL_DOMAIN";
		grep -v 'KeyboardInterrupt' "$WORKING_DIR"/"$ALL_IP" > "$WORKING_DIR"/tmp2;
		mv "$WORKING_DIR"/tmp2 "$WORKING_DIR"/"$ALL_IP";
}

function run_subfinder() {
		# Call with domain as $1 and wordlist as $2

		# Trap SIGINT so broken subfinder runs can be cancelled
		trap cancel SIGINT;

		# Check for wordlist argument, else run without
		echo -e "$GREEN""[i]$BLUE Scanning $1 with subfinder.""$NC";
		echo -e "$GREEN""[i]$ORANGE Command: subfinder -d $1 -o $WORKING_DIR/subfinder-domains.txt -t 25 -w $2.""$NC";
		START=$(date +%s);
		"$SUBFINDER" -d "$1" -o "$WORKING_DIR"/subfinder-domains.txt -t 25 -w "$2";
		END=$(date +%s);
		DIFF=$(( END - START ));
		
		cat "$WORKING_DIR"/subfinder-domains.txt >> "$WORKING_DIR"/$ALL_DOMAIN;

		echo -e "$GREEN""[i]$BLUE Subfinder took $DIFF seconds to run.""$NC";
		echo -e "$GREEN""[!]$ORANGE Subfinder found $(wc -l "$WORKING_DIR"/subfinder-domains.txt | cut -d ' ' -f 1) domains.""$N";
		list_found;
		sleep 1;
}

function run_sublist3r() {
		# Call with domain as $1, doesn't support wordlists

		# Trap SIGINT so broken sublist3r runs can be cancelled
		trap cancel SIGINT;

		echo -e "$GREEN""[i]$BLUE Scanning $1 with sublist3r.""$NC";
		echo -e "$GREEN""[i]$ORANGE Command: $SUBLIST3R -d $1 -o $WORKING_DIR/sublist3r-output.txt.""$NC";
		START=$(date +%s);
		"$SUBLIST3R" -d "$1" -o "$WORKING_DIR"/sublist3r-output.txt
		END=$(date +%s);
		DIFF=$(( END - START ));

		# Check that output file exists
		if [[ -f "$WORKING_DIR"/sublist3r-output.txt ]]; then
				# Cat output into main lists
				cat "$WORKING_DIR"/sublist3r-output.txt >> "$WORKING_DIR"/$ALL_DOMAIN;
				echo -e "$GREEN""[i]$BLUE sublist3r took $DIFF seconds to run.""$NC";
				echo -e "$GREEN""[!]$ORANGE sublist3r found $(wc -l "$WORKING_DIR"/sublist3r-output.txt | cut -d ' ' -f 1) domains.""$NC";
		fi

		list_found;
		sleep 1;
}

function run_altdns() {
		# Run altdns with found subdomains combined with altdns-wordlist.txt

		echo -e "$GREEN""[i]$BLUE Running altdns against all $(wc -l "$WORKING_DIR"/$ALL_DOMAIN | cut -d ' ' -f 1) unique discovered subdomains to generate domains for masscan to resolve.""$NC";
		echo -e "$GREEN""[i]$ORANGE Command: altdns.py -i $WORKING_DIR/$ALL_DOMAIN -w wordlists/altdns-words.txt -o $WORKING_DIR/altdns-output.txt -t 20.""$NC";
		START=$(date +%s);
		"$ALTDNS" -i "$WORKING_DIR"/$ALL_DOMAIN -w wordlists/altdns-words.txt -o "$WORKING_DIR"/altdns-output.txt -t 20
		END=$(date +%s);
		DIFF=$(( END - START ));

		echo -e "$GREEN""[i]$BLUE Altdns took $DIFF seconds to run.""$NC";
		echo -e "$GREEN""[i]$BLUE Altdns generated $(wc -l "$WORKING_DIR"/altdns-output.txt | cut -d ' ' -f 1) subdomains.""$NC";
		sleep 1;
}

function run_massdns() {
		# Call with domain as $1 and wordlist as $2

		# Run altdns to get altered domains to resolve along with other found domains
		run_altdns;

		# Create wordlist with appended domain for massdns
		sed "/.*/ s/$/\.$1/" $2 > "$WORKING_DIR"/massdns-appended.txt;

		echo -e "$GREEN""[i]$BLUE Scanning $(cat "$WORKING_DIR"/$ALL_DOMAIN "$WORKING_DIR"/$ALL_IP "$WORKING_DIR"/altdns-output.txt "$WORKING_DIR"/massdns-appended.txt | sort | uniq | wc -l) current unique $1 domains and IPs, altdns generated domains, and domain-appended wordlist with massdns (in quiet mode).""$NC";
		echo -e "$GREEN""[i]$ORANGE Command: cat (all found domains and IPs) | $MASSDNS_BIN -r $MASSDNS_RESOLVERS -q -t A -o S -w $WORKING_DIR/massdns-result.txt.""$NC";
		START=$(date +%s);
		cat "$WORKING_DIR"/$ALL_DOMAIN "$WORKING_DIR"/$ALL_IP "$WORKING_DIR"/altdns-output.txt "$WORKING_DIR"/massdns-appended.txt | sort | uniq | $MASSDNS_BIN -r $MASSDNS_RESOLVERS -q -t A -o S -w "$WORKING_DIR"/massdns-result.txt;
		END=$(date +%s);
		DIFF=$(( END - START ));

		# Parse results
		grep CNAME "$WORKING_DIR"/massdns-result.txt > "$WORKING_DIR"/massdns-CNAMEs;
		grep -v CNAME "$WORKING_DIR"/massdns-result.txt | cut -d ' ' -f 3 >> "$WORKING_DIR"/$ALL_IP;

		# Add any new in-scope domains to main list
		cut -d ' ' -f 3 "$WORKING_DIR"/massdns-CNAMEs | grep "$DOMAIN.$" >> "$WORKING_DIR"/$ALL_DOMAIN;

		echo -e "$GREEN""[i]$BLUE Massdns took $DIFF seconds to run.""$NC";
		echo -e "$GREEN""[!]$ORANGE Check $WORKING_DIR/massdns-CNAMEs for a list of CNAMEs found.""$NC";
		sleep 1;

		list_found;
		sleep 1;
}

function run_subjack() {
		# Call with domain as $1 and wordlist as $2

		# Check for domain takeover on each found domain
		echo -e "$GREEN""[i]$BLUE Running subjack against all $(wc -l "$WORKING_DIR"/$ALL_DOMAIN | cut -d ' ' -f 1) unique discoverd subdomains to check for subdomain takeover.""$NC";
		echo -e "$GREEN""[i]$ORANGE Command: subjack -d $1 -w $2 -v -t 20 -ssl -m -o $WORKING_DIR/subjack-output.txt""$NC";
		START=$(date +%s);
		"$SUBJACK" -d "$1" -w "$2" -v -t 20 -ssl -m -o "$WORKING_DIR"/subjack-output.txt;
		END=$(date +%s);
		DIFF=$(( END - START ));

		echo -e "$GREEN""[i]$BLUE Subjack took $DIFF seconds to run.""$NC";
		echo -e "$GREEN""[i]$ORANGE Full Subjack results are at $WORKING_DIR/subjack-output.txt.""$NC";
		sleep 1;
}

function run_subdomain_brute() {
		# Ask user for wordlist size
		while true; do
		  echo -e "$ORANGE""[i] Beginning subdomain enumeration. This will use dnscan, subfinder, sublist3r, and massdns + altdns.";
		  echo -e "$GREEN""[?] What size wordlist would you like to use for subdomain bruteforcing?";
		  echo -e "$GREEN""[i] Sizes are [S]mall (22k domains), [L]arge (102k domains), and [H]uge (199k domains).";
		  echo -e "$ORANGE";
		  read -rp "[?] Please enter S/s, L/l, or H/h. " ANSWER

		  case $ANSWER in
		   [sS]* ) 
				   run_dnscan "$DOMAIN" "$SHORT";
				   run_subfinder "$DOMAIN" "$SHORT";
				   run_sublist3r "$DOMAIN";
				   run_massdns "$DOMAIN" "$SHORT";
				   run_subjack "$DOMAIN" "$WORKING_DIR"/"$ALL_DOMAIN";
				   break
				   ;;

		   [lL]* ) 
				   run_dnscan "$DOMAIN" "$LONG";
				   run_subfinder "$DOMAIN" "$LONG";
				   run_sublist3r "$DOMAIN";
				   run_massdns "$DOMAIN" "$LONG";
				   run_subjack "$DOMAIN" "$WORKING_DIR"/"$ALL_DOMAIN";
				   return;
				   ;;

		   [hH]* ) 
				   run_dnscan "$DOMAIN" "$SHORT";
				   run_subfinder "$DOMAIN" "$HUGE";
				   run_sublist3r "$DOMAIN";
				   run_massdns "$DOMAIN" "$HUGE";
				   run_subjack "$DOMAIN" "$WORKING_DIR"/"$ALL_DOMAIN";
				   break;
				   ;;
		   * )     
				   echo -e "$RED"""[!] Please enter S/s, L/l, or H/h. "$NC"
				   ;;
		  esac
		done
}

function run_aquatone () {
		# Ask user to run aquatone
		while true; do
		  echo -e "$ORANGE";
		  read -rp "[?] Do you want to screenshot discovered domains with aquatone? [Y/N] " ANSWER

		  case $ANSWER in
		   [yY]* ) 
				   break
				   ;;

		   [nN]* ) 
				   echo -e "$ORANGE""[!] Skipping aquatone.""$NC";
				   return;
				   ;;

		   * )     
				   echo -e "$RED""[!] Please enter Y/y or N/n. ""$NC"
				   ;;
		  esac
		done
		mkdir "$WORKING_DIR"/aquatone;

		echo -e "$GREEN""[i]$BLUE Running aquatone against all $(wc -l "$WORKING_DIR"/$ALL_DOMAIN | cut -d ' ' -f 1) unique discovered subdomains.""$NC";
		START=$(date +%s);
		$AQUATONE -threads 10 -chrome-path "$CHROMIUM" -ports medium -out "$WORKING_DIR"/aquatone < "$WORKING_DIR"/$ALL_DOMAIN;
		END=$(date +%s);
		DIFF=$(( END - START ));
		echo -e "$GREEN""[i]$BLUE Aquatone took $DIFF seconds to run.""$NC";
}

function run_masscan() {
		# Run masscan against all IPs found on all ports
		echo -e "$GREEN""[i]$BLUE Running masscan against all $(wc -l "$WORKING_DIR"/$ALL_IP | cut -d ' ' -f 1) unique discovered IP addresses.""$NC";
		echo -e "$GREEN""[i]$BLUE Command: masscan -p1-65535 -il $WORKING_DIR/$ALL_IP --rate=7000 -oL $WORKING_DIR/masscan-output.txt.""$NC";

		# Check that IP list is not empty
		IP_COUNT=$(wc -l "$WORKING_DIR"/$ALL_IP | cut -d ' ' -f 1);
		if [[ "$IP_COUNT" -lt 1 ]]; then
				echo -e "$RED""[i] No IP addresses have been found. Skipping masscan scan.""$NC";
				return;
		fi


		START=$(date +%s);
		sudo masscan -p1-65535 -iL "$WORKING_DIR"/$ALL_IP --rate=7000 -oL "$WORKING_DIR"/masscan-output.txt;
		END=$(date +%s);
		DIFF=$(( END - START ));
		echo -e "$GREEN""[i]$BLUE Masscan took $DIFF seconds to run.""$NC";

		# Trim # from first and last lines of output
		grep -v '#' "$WORKING_DIR"/masscan-output.txt > "$WORKING_DIR"/temp;
		sudo mv "$WORKING_DIR"/temp "$WORKING_DIR"/masscan-output.txt;
}

function run_nmap() {
		# Check that IP list is not empty
		IP_COUNT=$(wc -l "$WORKING_DIR"/$ALL_IP | cut -d ' ' -f 1);
		if [[ "$IP_COUNT" -lt 1 ]]; then
				echo -e "$RED""[i] No IP addresses have been found. Skipping nmap scan.""$NC";
				return;
		fi

		# Run nmap against all-ip.txt against ports found by masscan, unless alone arg is passed as $1
		if [[ "$1" == "alone" ]]; then
				echo -e "$GREEN""[i]$BLUE Running nmap against all $(wc -l "$WORKING_DIR"/"$ALL_IP" | cut -d ' ' -f 1) unique discovered IP addresses.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: nmap -n -v -sV -iL $WORKING_DIR/all_ip.txt -oA $WORKING_DIR/nmap-output.""$NC";
				START=$(date +%s);
				nmap -n -v -sV -iL "$WORKING_DIR"/"$ALL_IP" -oA "$WORKING_DIR"/nmap-output;
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE Nmap took $DIFF seconds to run.""$NC";
		# Make sure masscan actually created output
		elif [[ ! -s "$WORKING_DIR"/masscan-output.txt ]]; then
				echo -e "$GREEN""[i]$BLUE Running nmap against all $(wc -l "$WORKING_DIR"/"$ALL_IP" | cut -d ' ' -f 1) unique discovered IP addresses.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: nmap -n -v -sV -iL $WORKING_DIR/all_ip.txt -oA $WORKING_DIR/nmap-output.""$NC";
				START=$(date +%s);
				nmap -n -v -sV -iL "$WORKING_DIR"/"$ALL_IP" -oA "$WORKING_DIR"/nmap-output;
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE Nmap took $DIFF seconds to run.""$NC";
		else
				# Process masscan output for ports found
				cut -d ' ' -f 3  "$WORKING_DIR"/masscan-output.txt >> "$WORKING_DIR"/temp;
				sort "$WORKING_DIR"/temp | uniq > "$WORKING_DIR"/ports;
				rm "$WORKING_DIR"/temp;

				# Count ports in case it's over nmap's ~22k parameter limit, then run multiple scans
				PORT_NUMBER=$(wc -l "$WORKING_DIR"/ports | cut -d ' ' -f 1);

				if [[ $PORT_NUMBER -gt 22000 ]]; then
						echo -e "$GREEN""[!]$RED WARNING: Masscan found more than 22k open ports. This is more than nmap's port argument length limit, and likely indicates lots of false positives. Consider running nmap with -p- to scan all ports.""$NC";
						sleep 2;
						return;
				fi

				# Get live IPs from masscan
				cut -d ' ' -f 4 "$WORKING_DIR"/masscan-output.txt >> "$WORKING_DIR"/"$ALL_IP";
				
				echo -e "$GREEN""[i]$BLUE Running nmap against $(wc -l "$WORKING_DIR"/"$ALL_IP" | cut -d ' ' -f 1) unique discovered IP addresses and $(wc -l "$WORKING_DIR"/ports | cut -d ' ' -f 1) ports identified by masscan.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: nmap -n -v -sV -iL $WORKING_DIR/all_ip.txt -p $(tr '\n' , < "$WORKING_DIR"/ports) -oA $WORKING_DIR/nmap-output.""$NC";
				START=$(date +%s);
				nmap -n -v -sV -iL "$WORKING_DIR"/"$ALL_IP" -p "$(tr '\n' , < "$WORKING_DIR"/ports)" -oA "$WORKING_DIR"/nmap-output;
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE Nmap took $DIFF seconds to run.""$NC";
		fi
		echo -e "$GREEN""[i]$BLUE Nmap took $DIFF seconds to run.""$NC";
}

function run_portscan() {
		   while true; do
				   echo -e "$GREEN""[?] Do you want to perform port scanning?""$NC";
				   echo -e "$ORANGE""[i] This will use masscan and/or nmap.""$NC";
				   echo -e "$ORANGE";
				   read -rp "[i] Enter Y/N " CHOICE;
				   case $CHOICE in
						   [yY]* )
								   while true; do
										   echo -e "$GREEN""[i] Do you want to run [B]oth masscan and nmap, only [N]map, or only [M]asscan?";
										   read -rp "[i] Enter B/N/M " CHOICE;
										   case $CHOICE in
												   [bB]* )
														   run_masscan;
														   run_nmap;
														   break;
														   ;;
													[nN]* )
														   run_nmap alone;
														   break;
														   ;;
													[mM]* )
														   run_masscan;
														   break;
														   ;;
												   * )     
														   echo -e "$RED""[!] Please enter B/b, N/n, or M/m. ""$NC"
														   ;;
										   esac
								   done
								   break;
								   ;;
							[nN]* )
								   echo -e "$RED""[!] Cancelling port scan.""$NC";
								   return;
								   ;;
						        * )     
								   echo -e "$RED""[!] Please enter Y/y or N/n. ""$NC"
								   ;;
				   esac
		   done
}

function run_gobuster() {
		# Call with domain as $1, wordlist size as $2, and domain list as $3
		if [[ $3 == $WORKING_DIR/$ALL_DOMAIN ]]; then
				echo -e "$GREEN""[i]$BLUE Running gobuster against all $(wc -l "$3" | cut -d ' ' -f 1) unique discovered domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: gobuster -u https://$DOMAIN -s '200,201,202,204,307,308,401,403,405,500,501,503' -to 3s -e -k -t 20 -w $2 -o gobuster.""$NC";
				# Run gobuster
				mkdir "$WORKING_DIR"/gobuster;
				COUNT=$(wc -l "$3" | cut -d ' ' -f 1)
				START=$(date +%s);
				while read -r ADOMAIN; do
						"$GOBUSTER" -u https://"$ADOMAIN" -s '200,201,202,204,307,308,401,403,405,500,501,503' -to 3s -e -k -t 20 -w "$2" -o "$WORKING_DIR"/gobuster/"$ADOMAIN".txt;
						COUNT=$((COUNT - 1));
						echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
				done < "$3"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE Gobuster took $DIFF seconds to run.""$NC";
		else
				echo -e "$GREEN""[i]$BLUE Running gobuster against all $(wc -l "$3" | cut -d ' ' -f 1) discovered interesting domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: gobuster -u https://$DOMAIN -s '200,201,202,204,307,308,401,403,405,500,501,503' -to 3s -e -k -t 20 -w $2 -o $WORKING_DIR/gobuster""$NC";
				# Run gobuster
				mkdir "$WORKING_DIR"/gobuster;
				COUNT=$(wc -l "$3" | cut -d ' ' -f 1)
				START=$(date +%s);
				while read -r ADOMAIN; do
						"$GOBUSTER" -u https://"$ADOMAIN" -s '200,201,202,204,307,308,401,403,405,500,501,503' -to 3s -e -k -t 20 -w "$2" -o "$WORKING_DIR"/gobuster/"$ADOMAIN".txt;
						COUNT=$((COUNT - 1));
						echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
				done < "$3"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE Gobuster took $DIFF seconds to run.""$NC";
		fi
}

function run_ffuf() {
		# Trap SIGINT so broken ffuf runs can be cancelled
		trap cancel SIGINT;

		# Call with domain as $1, wordlist size as $2, and domain list as $3
		if [[ $3 == $WORKING_DIR/$ALL_DOMAIN ]]; then
				echo -e "$GREEN""[i]$BLUE Running ffuf against all $(wc -l "$3" | cut -d ' ' -f 1) unique discovered domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: ffuf -u https://$DOMAIN/FUZZ -w $2 -fc 301,302 -k | tee $WORKING_DIR/ffuf.""$NC";
				# Run ffuf
				mkdir "$WORKING_DIR"/ffuf;
				COUNT=$(wc -l "$3" | cut -d ' ' -f 1)
				START=$(date +%s);
				while read -r ADOMAIN; do
						"$FFUF" -u https://"$ADOMAIN"/FUZZ -w "$2" -fc 301,302 -k -mc 200,201,202,204,401,403,500,502,503 | tee "$WORKING_DIR"/ffuf/"$ADOMAIN";
						COUNT=$((COUNT - 1));
						echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
				done < "$3"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE ffuf took $DIFF seconds to run.""$NC";
		else
				echo -e "$GREEN""[i]$BLUE Running ffuf against all $(wc -l "$3" | cut -d ' ' -f 1) discovered interesting domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: ffuf -u https://$DOMAIN/FUZZ -w $2 -fc 301,302 -k | tee $WORKING_DIR/ffuf.""$NC";
				# Run ffuf
				mkdir "$WORKING_DIR"/ffuf;
				COUNT=$(wc -l "$3" | cut -d ' ' -f 1)
				START=$(date +%s);
				while read -r ADOMAIN; do
						"$FFUF" -u https://"$ADOMAIN"/FUZZ -w "$2" -fc 301,302 -k -mc 200,201,202,204,401,403,500,502,503 | tee "$WORKING_DIR"/ffuf/"$ADOMAIN";
						COUNT=$((COUNT - 1));
						echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
				done < "$3"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE ffuf took $DIFF seconds to run.""$NC";
		fi
}

function run_bfac() {
		# Call with domain list as $1
		if [[ $1 == $WORKING_DIR/$ALL_DOMAIN ]]; then
				echo -e "$GREEN""[i]$BLUE Running bfac against all $(wc -l "$1" | cut -d ' ' -f 1) unique discovered domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: bfac -u $DOMAIN -xsc 404,301,302,400 -o $WORKING_DIR/bfac.""$NC";
				# Run ffuf
				mkdir "$WORKING_DIR"/bfac;
				COUNT=$(wc -l "$1" | cut -d ' ' -f 1)
				START=$(date +%s);
				while read -r ADOMAIN; do
						$BFAC -u "$ADOMAIN" -xsc 404,301,302,400 -o "$WORKING_DIR"/bfac/"$ADOMAIN";
						COUNT=$((COUNT - 1));
						echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
				done < "$1"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE ffuf took $DIFF seconds to run.""$NC";
		else
				echo -e "$GREEN""[i]$BLUE Running bfac against all $(wc -l "$2" | cut -d ' ' -f 1) discovered interesting domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: bfac -u $DOMAIN -xsc 404,301,302,400 -o $WORKING_DIR/bfac.""$NC";
				# Run ffuf
				mkdir "$WORKING_DIR"/bfac;
				COUNT=$(wc -l "$1" | cut -d ' ' -f 1)
				START=$(date +%s);
				while read -r ADOMAIN; do
						$BFAC -u "$ADOMAIN" -xsc 404,301,302,400 -o "$WORKING_DIR"/bfac/"$ADOMAIN";
						COUNT=$((COUNT - 1));
						echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
				done < "$1"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE bfac took $DIFF seconds to run.""$NC";
		fi
}

function run_nikto() {
		# Call with domain list as $1
		if [[ $1 == $WORKING_DIR/$ALL_DOMAIN ]]; then
				echo -e "$GREEN""[i]$BLUE Running nikto against all $(wc -l "$1" | cut -d ' ' -f 1) unique discovered domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: nikto -h https://$DOMAIN -output $WORKING_DIR/nikto.""$NC";
				# Run nikto
				COUNT=$(wc -l "$1" | cut -d ' ' -f 1)
				mkdir "$WORKING_DIR"/nikto;
				START=$(date +%s);
				while read -r ADOMAIN; do
						nikto -h https://"$ADOMAIN" -output "$WORKING_DIR"/nikto/"$ADOMAIN".txt;
						COUNT=$((COUNT - 1));
						echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
				done < "$1"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE ffuf took $DIFF seconds to run.""$NC";
		else
				echo -e "$GREEN""[i]$BLUE Running nikto against all $(wc -l "$1" | cut -d ' ' -f 1) discovered interesting domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: nikto -h https://$DOMAIN -output $WORKING_DIR/nikto.""$NC";
				# Run nikto
				COUNT=$(wc -l "$1" | cut -d ' ' -f 1)
				mkdir "$WORKING_DIR"/nikto;
				START=$(date +%s);
				while read -r ADOMAIN; do
						nikto -h https://"$ADOMAIN" -output "$WORKING_DIR"/nikto/"$ADOMAIN".txt;
						COUNT=$((COUNT - 1));
						echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
				done < "$1"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE nikto took $DIFF seconds to run.""$NC";
		fi
}

function run_whatweb() {
		# Call with domain as $1 and domain list as $2
		if [[ $2 == $WORKING_DIR/$ALL_DOMAIN ]]; then
				echo -e "$GREEN""[i]$BLUE Running whatweb against all $(wc -l "$2" | cut -d ' ' -f 1) unique discovered domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: whatweb -v -a 3 -h https://$DOMAIN | tee $WORKING_DIR/whatweb.""$NC";
				# Run whatweb
				COUNT=$(wc -l "$2" | cut -d ' ' -f 1)
				mkdir "$WORKING_DIR"/whatweb;
				START=$(date +%s);
				while read -r ADOMAIN; do
						"$WHATWEB" -v -a 3 https://"$ADOMAIN" | tee "$WORKING_DIR"/whatweb/"$ADOMAIN";
						COUNT=$((COUNT - 1));
						echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
				done < "$2"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE whatweb took $DIFF seconds to run.""$NC";
		else
				echo -e "$GREEN""[i]$BLUE Running whatweb against all $(wc -l "$2" | cut -d ' ' -f 1) discovered interesting domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: whatweb -v -a 3 -h https://$DOMAIN | tee $WORKING_DIR/whatweb.""$NC";
				# Run whatweb
				COUNT=$(wc -l "$2" | cut -d ' ' -f 1)
				mkdir "$WORKING_DIR"/whatweb;
				START=$(date +%s);
				while read -r ADOMAIN; do
						"$WHATWEB" -v -a 3 https://"$ADOMAIN" | tee "$WORKING_DIR"/whatweb/"$ADOMAIN";
						COUNT=$((COUNT - 1));
						echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
				done < "$2"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE whatweb took $DIFF seconds to run.""$NC";
		fi
}

function run_content_discovery() {
# Ask user to do directory bruteforcing on discovered domains
while true; do
  echo -e "$GREEN""[?] Do you want to begin content bruteforcing on [A]ll/[I]nteresting/[N]o discovered domains?";
  echo -e "$ORANGE""[i] This will run ffuf, bfac, nikto, whatweb, and wafw00f.";
  read -rp "[?] Please enter A/a, I/i, or N/n. " ANSWER

  case $ANSWER in
   [aA]* ) 
		   echo -e "[i] Beginning directory bruteforcing on all discovered domains.";
		   while true; do
				   echo -e "$GREEN""[?] Which wordlist do you want to use?""$NC";
				   echo -e "$BLUE""   Small: ~20k words""$NC";
				   echo -e "$BLUE""   Medium: ~167k words""$NC";
				   echo -e "$BLUE""   Large: ~215k words""$NC";
				   echo -e "$BLUE""   XL: ~373k words""$NC";
				   echo -e "$BLUE""   2XL: ~486k words""$GREEN";
				   read -rp "[i] Enter S/M/L/X/2 " CHOICE;
				   case $CHOICE in
						   [sS]* )
								   run_ffuf "$DOMAIN" "$SMALL" "$WORKING_DIR"/"$ALL_DOMAIN";
								   # run_gobuster "$DOMAIN" "$SMALL" "$WORKING_DIR"/"$ALL_DOMAIN";
								   run_bfac "$WORKING_DIR"/"$ALL_DOMAIN";
								   run_nikto "$WORKING_DIR"/"$ALL_DOMAIN";
								   run_whatweb "$DOMAIN" "$WORKING_DIR"/"$ALL_DOMAIN";
								   run_wafw00f "$DOMAIN" "$WORKING_DIR"/"$ALL_DOMAIN";
								   break;
								   ;;
							[mM]* )
								   run_ffuf "$DOMAIN" "$MEDIUM" "$WORKING_DIR"/"$ALL_DOMAIN";
								   # run_gobuster "$DOMAIN" "$MEDIUM" "$WORKING_DIR"/"$ALL_DOMAIN";
								   run_bfac "$WORKING_DIR"/"$ALL_DOMAIN";
								   run_nikto "$WORKING_DIR"/"$ALL_DOMAIN";
								   run_whatweb "$DOMAIN" "$WORKING_DIR"/"$ALL_DOMAIN";
								   run_wafw00f "$DOMAIN" "$WORKING_DIR"/"$ALL_DOMAIN";
								   break;
								   ;;
							[lL]* )
								   run_ffuf "$DOMAIN" "$LARGE" "$WORKING_DIR"/"$ALL_DOMAIN";
								   # run_gobuster "$DOMAIN" "$LARGE" "$WORKING_DIR"/"$ALL_DOMAIN";
								   run_bfac "$WORKING_DIR"/"$ALL_DOMAIN";
								   run_nikto "$WORKING_DIR"/"$ALL_DOMAIN";
								   run_whatweb "$DOMAIN" "$WORKING_DIR"/"$ALL_DOMAIN";
								   run_wafw00f "$DOMAIN" "$WORKING_DIR"/"$ALL_DOMAIN";
								   break;
								   ;;
							[xX]* )
								   run_ffuf "$DOMAIN" "$XL" "$WORKING_DIR"/"$ALL_DOMAIN";
								   # run_gobuster "$DOMAIN" "$XL" "$WORKING_DIR"/"$ALL_DOMAIN";
								   run_bfac "$WORKING_DIR"/"$ALL_DOMAIN";
								   run_nikto "$WORKING_DIR"/"$ALL_DOMAIN";
								   run_whatweb "$DOMAIN" "$WORKING_DIR"/"$ALL_DOMAIN";
								   run_wafw00f "$DOMAIN" "$WORKING_DIR"/"$ALL_DOMAIN";
								   break;
								   ;;
							[2]* )
								   run_ffuf "$DOMAIN" "$XXL" "$WORKING_DIR"/"$ALL_DOMAIN";
								   # run_gobuster "$DOMAIN" "$XXL" "$WORKING_DIR"/"$ALL_DOMAIN";
								   run_bfac "$WORKING_DIR"/"$ALL_DOMAIN";
								   run_nikto "$WORKING_DIR"/"$ALL_DOMAIN";
								   run_whatweb "$DOMAIN" "$WORKING_DIR"/"$ALL_DOMAIN";
								   run_wafw00f "$DOMAIN" "$WORKING_DIR"/"$ALL_DOMAIN";
								   break;
								   ;;
				   esac
		   done
		   break;
		   ;;
   [nN]* ) 
		   echo -e "$RED""[!] Skipping directory bruteforcing on all domains.""$NC";
		   return;
		   ;;
   [iI]* ) 
		   # Check if any interesting domains have been found.'
		   COUNT=$(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | cut -d ' ' -f 1);
		   if [[ "$COUNT" -lt 1 ]]; then
				   echo -e "$RED""[!] No interesting domains have been discovered.""$NC";
				   return;
		   fi
				   
		   echo -e "[i] Beginning directory bruteforcing on interesting discovered domains.";
		   while true; do
				   echo -e "$GREEN""[?] Which wordlist do you want to use?""$NC";
				   echo -e "$BLUE""   Small: ~20k words""$NC";
				   echo -e "$BLUE""   Medium: ~167k words""$NC";
				   echo -e "$BLUE""   Large: ~215k words""$NC";
				   echo -e "$BLUE""   XL: ~373k words""$NC";
				   echo -e "$BLUE""   2XL: ~486k words""$GREEN";
				   read -rp "[i] Enter S/M/L/X/2 " CHOICE;
				   case $CHOICE in
						   [sS]* )
								   run_ffuf "$DOMAIN" "$SMALL" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   # run_gobuster "$DOMAIN" "$SMALL" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_bfac "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_nikto "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_whatweb "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_wafw00f "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   break;
								   ;;
							[mM]* )
								   run_ffuf "$DOMAIN" "$MEDIUM" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   # run_gobuster "$DOMAIN" "$MEDIUM" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_bfac "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_nikto "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_whatweb "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_wafw00f "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   break;
								   ;;
							[lL]* )
								   run_ffuf "$DOMAIN" "$LARGE" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   # run_gobuster "$DOMAIN" "$LARGE" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_bfac "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_nikto "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_whatweb "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_wafw00f "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   break;
								   ;;
							[xX]* )
								   run_ffuf "$DOMAIN" "$XL" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   # run_gobuster "$DOMAIN" "$XL" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_bfac "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_nikto "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_whatweb "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_wafw00f "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   break;
								   ;;
							[2]* )
								   run_ffuf "$DOMAIN" "$XXL" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   # run_gobuster "$DOMAIN" "$XXL" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_bfac "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_nikto "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_whatweb "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_wafw00f "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   break;
								   ;;
				   esac
		   done
		   break;
		   ;;
   * )     
		   echo -e "$RED""Please enter Y/y, N/n, or A/a. ""$NC";
		   ;;
  esac
done
}

function run_wafw00f() {
		# Call with domain as $1 and domain list as $2
		if [[ $2 == $WORKING_DIR/$ALL_DOMAIN ]]; then
				echo -e "$GREEN""[i]$BLUE Running wafw00f against all $(wc -l "$2" | cut -d ' ' -f 1) unique discovered domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: wafw00f https://$1 -a | tee $WORKING_DIR/wafw00f.""$NC";
				# Run wafw00f
				COUNT=$(wc -l "$2" | cut -d ' ' -f 1)
				mkdir "$WORKING_DIR"/wafw00f;
				START=$(date +%s);
				while read -r ADOMAIN; do
						"$WAFW00F" https://"$ADOMAIN" -a | tee "$WORKING_DIR"/wafw00f/"$ADOMAIN";
						COUNT=$((COUNT - 1));
						echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
				done < "$2"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE whatweb took $DIFF seconds to run.""$NC";
		else
				echo -e "$GREEN""[i]$BLUE Running wafw00f against all $(wc -l "$2" | cut -d ' ' -f 1) discovered interesting domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: wafw00f https://$1 -a | tee $WORKING_DIR/wafw00f.""$NC";
				# Run wafw00f
				COUNT=$(wc -l "$2" | cut -d ' ' -f 1)
				mkdir "$WORKING_DIR"/wafw00f;
				START=$(date +%s);
				while read -r ADOMAIN; do
						"$WAFW00F" https://"$ADOMAIN" -a | tee "$WORKING_DIR"/wafw00f/"$ADOMAIN";
						COUNT=$((COUNT - 1));
						echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
				done < "$2"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE wafw00f took $DIFF seconds to run.""$NC";
		fi
}

run_subdomain_brute;
run_aquatone;
get_interesting;
run_portscan;
run_content_discovery;
get_interesting;
list_found;
SCAN_END=$(date +%s);
SCAN_DIFF=$(( SCAN_END - SCAN_START ));
echo -e "$BLUE""[i] Total script run time: $SCAN_DIFF seconds.""$NC";
