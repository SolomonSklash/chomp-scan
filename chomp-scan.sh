#!/bin/bash

# TODO
# Check for cloudflare/other CDNs or hosting via whois?
# Config file for tool options? Resolvers, which tools to run, which wordlists, etc.

# Colors
NC='\033[0m';
RED='\033[0;31m';
GREEN='\033[0;32m';
BLUE='\033[0;34m';
ORANGE='\033[0;33m';
DOMAIN=$1;
SHORT=wordlists/subdomains-top1mil-20000.txt;
LONG=wordlists/sortedcombined-knock-dnsrecon-fierce-reconng.txt;
HUGE=wordlists/huge-200k;
SMALL=wordlists/big.txt;
MEDIUM=wordlists/raft-large-combined.txt;
LARGE=wordlists/seclists-combined.txt;
XL=wordlists/haddix_content_discovery_all.txt;
XXL=wordlists/haddix-seclists-combined.txt;
DNSCAN_PATH=~/bounty/tools/dnscan/dnscan.py;
DNSCAN_IPS=dnscan_ip.txt;
DNSCAN_DOMAIN=dnscan_domain.txt;
SUBFINDER_PATH=
SUBFINDER_DOMAIN=subfinder_domain.txt;
SUBLIST3R_PATH=
SUBJACK_PATH=
ALTDNS_PATH=
MASSDNS_BIN=~/bounty/tools/massdns/bin/massdns;
MASSDNS_RESOLVERS=~/bounty/tools/massdns/lists/resolvers.txt;
AQUATONE=~/bounty/tools/aquatone/aquatone;
FFUF_PATH=
BFAC=~/bounty/tools/bfac/bfac;
INTERESTING=interesting.txt;
BLACKLIST=blacklist.txt;
CHROMIUM=$(command -v chromium);
ALL_IP=all_ip.txt;
ALL_DOMAIN=all_domain.txt;
WORKING_DIR="$1"-$(date +%T);

# Check for domain argument
if [ $# -eq 0 ]; then
		    echo -e "$RED""No domain provided!\\n""$NC";
			echo -e "$GREEN""Usage: $0 example.com""$NC";
			exit;
fi

mkdir "$WORKING_DIR";

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
		echo -e "$RED""[!] The following $(wc -l "$WORKING_DIR"/interesting-domains.txt | cut -d ' ' -f 1) potentially interesting subdomains have been found ($WORKING_DIR/interesting-domains.txt):""$ORANGE";
		while read -r word; do
				grep "$word" "$WORKING_DIR"/$ALL_DOMAIN >> "$WORKING_DIR"/interesting-domains.txt; 
		done < $INTERESTING;
		cat "$WORKING_DIR"/interesting-domains.txt;
}

function run_subdomain_brute() {
		# Ask user for wordlist size
		while true; do
		  echo -e "$GREEN""[i] What size wordlist would you like to use for subdomain bruteforcing?";
		  echo -e "$GREEN""[i] Sizes are [S]mall (22k domains), [L]arge (102k domains), and [H]uge (199k domains).";
		  echo -e "$ORANGE";
		  read -rp "[!] Please enter S/s, L/l, or H/h. " ANSWER

		  case $ANSWER in
		   [sS]* ) 
				   run_dnscan "$DOMAIN" "$SHORT";
				   run_subfinder "$DOMAIN" "$SHORT";
				   run_sublist3r "$DOMAIN";
				   run_massdns "$DOMAIN" "$SHORT";
				   run_subjack "$DOMAIN" "$SHORT";
				   break
				   ;;

		   [lL]* ) 
				   run_dnscan "$DOMAIN" "$LONG";
				   run_subfinder "$DOMAIN" "$LONG";
				   run_sublist3r "$DOMAIN";
				   run_massdns "$DOMAIN" "$LONG";
				   run_subjack "$DOMAIN" "$LONG";
				   return;
				   ;;

		   [hH]* ) 
				   run_dnscan "$DOMAIN" "$SHORT";
				   run_subfinder "$DOMAIN" "$HUGE";
				   run_sublist3r "$DOMAIN";
				   run_massdns "$DOMAIN" "$HUGE";
				   run_subjack "$DOMAIN" "$HUGE";
				   break;
				   ;;
		   * )     
				   echo -e "$RED"""[!] Please enter S/s, L/l, or H/h."$NC"
				   ;;
		  esac
		done
}

function run_dnscan() {
		# Call with domain as $1 and wordlist as $2

		# Check that DNSCAN_PATH is set
		if [[ "$DNSCAN_PATH" == "" ]]; then
				echo -e "$GREEN""[i]$RED Dnscan path has not been set. Skipping dnscan...""$NC";
				return;
		fi

		echo -e "$GREEN""[i]$BLUE Scanning $1 with dnscan.""$NC";

		echo -e "$GREEN""[i]$ORANGE Command: $DNSCAN_PATH -d $1 -t 25 -o $WORKING_DIR/dnscan_out.txt -w $2.""$NC";
		sleep 2;
		START=$(date +%s);
		$DNSCAN_PATH -d "$1" -t 25 -o "$WORKING_DIR"/dnscan_out.txt -w "$2";
		END=$(date +%s);
		DIFF=$(( END - START ));

		# Headers and leading spaces
		sed '1,/A records/d' "$WORKING_DIR"/dnscan_out.txt | tr -d ' ' > "$WORKING_DIR"/trimmed;
		cut "$WORKING_DIR"/trimmed -d '-' -f 1 > "$WORKING_DIR"/$DNSCAN_IPS;
		cut "$WORKING_DIR"/trimmed -d '-' -f 2 > "$WORKING_DIR"/$DNSCAN_DOMAIN;
		rm "$WORKING_DIR"/trimmed;

		# Cat output into main lists
		cat "$WORKING_DIR"/$DNSCAN_IPS >> "$WORKING_DIR"/$ALL_IP;
		cat "$WORKING_DIR"/$DNSCAN_DOMAIN >> "$WORKING_DIR"/$ALL_DOMAIN;

		echo -e "$GREEN""[i]$BLUE dnsscan took $DIFF seconds to run.""$NC";
		echo -e "$GREEN""[!]$ORANGE dnscan found $(wc -l "$WORKING_DIR"/$DNSCAN_IPS | cut -d ' ' -f 1) IP/domain pairs.""$NC";
		list_found;
		sleep 1;
}

function run_subfinder() {
		# Call with domain as $1 and wordlist as $2

		# Check for wordlist argument, else run without
		echo -e "$GREEN""[i]$BLUE Scanning $1 with subfinder.""$NC";

		echo -e "$GREEN""[i]$ORANGE Command: subfinder -d $1 -o $WORKING_DIR/$SUBFINDER_DOMAIN -t 25 -w $2.""$NC";
		sleep 2;

		START=$(date +%s);
		subfinder -d "$1" -o "$WORKING_DIR"/$SUBFINDER_DOMAIN -t 25 -w "$2";
		END=$(date +%s);
		DIFF=$(( END - START ));
		
		cat "$WORKING_DIR"/$SUBFINDER_DOMAIN >> "$WORKING_DIR"/$ALL_DOMAIN;

		echo -e "$GREEN""[i]$BLUE Subfinder took $DIFF seconds to run.""$NC";
		echo -e "$GREEN""[!]$ORANGE Subfinder found $(wc -l "$WORKING_DIR"/$SUBFINDER_DOMAIN | cut -d ' ' -f 1) domains.""$N";
		list_found;
		sleep 1;
}

function run_sublist3r() {
		echo -e "$GREEN""[i]$BLUE Scanning $1 with sublist3r.""$NC";
		echo -e "$GREEN""[i]$ORANGE Command: sublist3r -d $1 -o $WORKING_DIR/sublist3r-output.txt.""$NC";
		sleep 2;

		START=$(date +%s);
		sublist3r -d "$1" -o "$WORKING_DIR"/sublist3r-output.txt
		END=$(date +%s);
		DIFF=$(( END - START ));

		# Cat output into main lists
		cat "$WORKING_DIR"/sublist3r-output.txt >> "$WORKING_DIR"/$ALL_DOMAIN;

		echo -e "$GREEN""[i]$BLUE sublist3r took $DIFF seconds to run.""$NC";
		echo -e "$GREEN""[!]$ORANGE sublist3r found $(wc -l "$WORKING_DIR"/sublist3r-output.txt | cut -d ' ' -f 1) domains.""$NC";
		list_found;
		sleep 1;
}

function run_altdns() {
		# Run altdns with found subdomains combined with altdns-wordlist.txt

		echo -e "$GREEN""[i]$BLUE Running altdns against found subdomains to generate domains for masscan to resolve.""$NC";
		echo -e "$GREEN""[i]$ORANGE Command: ~/bounty/tools/altdns/altdns.py -i $WORKING_DIR/$ALL_DOMAIN -w wordlists/altdns-words.txt -o $WORKING_DIR/altdns-output.txt -t 20.""$NC";
		sleep 2;

		START=$(date +%s);
		~/bounty/tools/altdns/altdns.py -i "$WORKING_DIR"/$ALL_DOMAIN -w wordlists/altdns-words.txt -o "$WORKING_DIR"/altdns-output.txt -t 20
		END=$(date +%s);
		DIFF=$(( END - START ));


		echo -e "$GREEN""[i]$BLUE Altdns took $DIFF seconds to run.""$NC";
		echo -e "$GREEN""[i]$BLUE Altdns generated $(wc -l "$WORKING_DIR"/altdns-output.txt | cut -d ' ' -f 1) subdomains.""$NC";
		sleep 1;
}

function run_massdns() {
		# Call with domain as $1 and wordlist as $2

		# Make sure MASSDNS_BIN and MASSDNS_RESOLVERS paths are set
		if [[ "$MASSDNS_BIN" == "" ]]; then
			echo -e "$GREEN""[i]$RED MASSDNS_BIN path is not set.""$NC";
			return;
		fi
		if [[ "$MASSDNS_RESOLVERS" == "" ]]; then
			echo -e "$GREEN""[i]$RED MASSDNS_RESOLVERS path is not set.""$NC";
			return;
		fi

		# Run altdns to get altered domains to resolve along with other found domains
		run_altdns;

		# Create wordlist with appended domain for massdns
		sed "/.*/ s/$/\.$1/" $2 > "$WORKING_DIR"/massdns-appended.txt;

		echo -e "$GREEN""[i]$BLUE Scanning $(cat "$WORKING_DIR"/$ALL_DOMAIN "$WORKING_DIR"/$ALL_IP "$WORKING_DIR"/altdns-output.txt "$WORKING_DIR"/massdns-appended.txt | sort | uniq | wc -l) current unique $1 domains and IPs, altdns generated domains, and domain-appended wordlist with massdns (in quiet mode).""$NC";
		echo -e "$GREEN""[i]$ORANGE Command: cat (all found domains and IPs) | $MASSDNS_BIN -r $MASSDNS_RESOLVERS -q -t A -o S -w $WORKING_DIR/massdns-result.txt.""$NC";
		sleep 2;

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
		echo -e "$GREEN""[i]$BLUE Running subjack against all unique found domains to check for subdomain takeover.""$NC";

		echo -e "$GREEN""[i]$ORANGE Command: subjack -d $1 -w $2 -v -t 20 -ssl -o $WORKING_DIR/subjack-output.txt""$NC";
		sleep 2;

		START=$(date +%s);
		subjack -d "$1" -w "$2" -v -t 20 -ssl -o "$WORKING_DIR"/subjack-output.txt;
		END=$(date +%s);
		DIFF=$(( END - START ));

		echo -e "$GREEN""[i]$BLUE Subjack took $DIFF seconds to run.""$NC";
		echo -e "$GREEN""[!]$ORANGE Full Subjack results are at $WORKING_DIR/subjack-output.txt.""$NC";
		sleep 1;
}

function run_aquatone () {
		# Make sure AQUATONE path is set
		if [[ "$AQUATONE" == "" ]]; then
			echo -e "$GREEN""[i]$RED AQUATONE path is not set.""$NC";
			return;
		fi
		# Ask user to run aquatone
		while true; do
		  echo -e "$ORANGE";
		  read -rp "[!] Do you want to screenshot discovered domains with aquatone? [Y/N] " ANSWER

		  case $ANSWER in
		   [yY]* ) 
				   break
				   ;;

		   [nN]* ) 
				   echo -e "$ORANGE""[!] Skipping aquatone.""$NC";
				   return;
				   ;;

		   * )     
				   echo -e "$RED""[!] Please enter Y/y or N/n.""$NC"
				   ;;
		  esac
		done
		mkdir "$WORKING_DIR"/aquatone;

		echo -e "$GREEN""[i]$BLUE Running aquatone against all unique found domains.""$NC";
		START=$(date +%s);
		$AQUATONE -threads 10 -chrome-path "$CHROMIUM" -ports medium -out "$WORKING_DIR"/aquatone < "$WORKING_DIR"/$ALL_DOMAIN;
		END=$(date +%s);
		DIFF=$(( END - START ));
		echo -e "$GREEN""[i]$BLUE Aquatone took $DIFF seconds to run.""$NC";
}

function run_portscan() {
		   while true; do
				   echo -e "$GREEN""[i] Do you want to perform port scanning?""$NC";
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
														   echo -e "$RED""[!] Please enter B/b, N/n, or M/m.""$NC"
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
								   echo -e "$RED""[!] Please enter Y/y or N/n.""$NC"
								   ;;
				   esac
		   done
}

function run_masscan() {
		# Run masscan against all IPs found on all ports
		echo -e "$GREEN""[i]$BLUE Running masscan against $(wc -l "$WORKING_DIR"/$ALL_IP | cut -d ' ' -f 1) unique IP addresses.""$NC";
		echo -e "$GREEN""[i]$BLUE Command: masscan -p1-65535 -il $WORKING_DIR/$ALL_IP --rate=7000 -oL $WORKING_DIR/masscan-output.txt.""$NC";

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
		# Run nmap against all-ip.txt against ports found by masscan, unless alone arg is passed as $1
		if [[ "$1" == "alone" ]]; then
				echo -e "$GREEN""[i]$BLUE Running nmap against $(wc -l "$WORKING_DIR"/live-ips.txt | cut -d ' ' -f 1) unique IP addresses.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: nmap -n -v -sV -iL $WORKING_DIR/all_ip.txt -oA $WORKING_DIR/nmap-output.""$NC";
				sleep 1;

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
				cut -d ' ' -f 4 "$WORKING_DIR"/masscan-output.txt >> "$WORKING_DIR"/live-ips.txt;
				
				echo -e "$GREEN""[i]$BLUE Running nmap against $(wc -l "$WORKING_DIR"/live-ips.txt | cut -d ' ' -f 1) unique IP addresses and $(wc -l "$WORKING_DIR"/ports | cut -d ' ' -f 1) ports identified by masscan.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: nmap -n -v -sV -iL $WORKING_DIR/all_ip.txt -p $(tr '\n' , < "$WORKING_DIR"/ports) -oA $WORKING_DIR/nmap-output.""$NC";
				sleep 1;

				START=$(date +%s);
				nmap -n -v -sV -iL "$WORKING_DIR"/live-ips.txt -p "$(tr '\n' , < "$WORKING_DIR"/ports)" -oA "$WORKING_DIR"/nmap-output;
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE Nmap took $DIFF seconds to run.""$NC";
		fi
		echo -e "$GREEN""[i]$BLUE Nmap took $DIFF seconds to run.""$NC";
}

function run_content_discovery() {
# Ask user to do directory bruteforcing on discover domains
while true; do
  echo -e "$ORANGE";
  read -rp "[!] Do you want to begin content bruteforcing on all/interesting/no discovered domains? [A/I/N] " ANSWER

  case $ANSWER in
   [aA]* ) 
		   echo -e "[i] Beginning directory bruteforcing on all discovered domains.";
		   while true; do
				   echo -e "$GREEN""[i] Which wordlist do you want to use?""$NC";
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
								   break;
								   ;;
							[mM]* )
								   run_ffuf "$DOMAIN" "$MEDIUM" "$WORKING_DIR"/"$ALL_DOMAIN";
								   # run_gobuster "$DOMAIN" "$MEDIUM" "$WORKING_DIR"/"$ALL_DOMAIN";
								   run_bfac "$WORKING_DIR"/"$ALL_DOMAIN";
								   run_nikto "$WORKING_DIR"/"$ALL_DOMAIN";
								   break;
								   ;;
							[lL]* )
								   run_ffuf "$DOMAIN" "$LARGE" "$WORKING_DIR"/"$ALL_DOMAIN";
								   # run_gobuster "$DOMAIN" "$LARGE" "$WORKING_DIR"/"$ALL_DOMAIN";
								   run_bfac "$WORKING_DIR"/"$ALL_DOMAIN";
								   run_nikto "$WORKING_DIR"/"$ALL_DOMAIN";
								   break;
								   ;;
							[xX]* )
								   run_ffuf "$DOMAIN" "$XL" "$WORKING_DIR"/"$ALL_DOMAIN";
								   # run_gobuster "$DOMAIN" "$XL" "$WORKING_DIR"/"$ALL_DOMAIN";
								   run_bfac "$WORKING_DIR"/"$ALL_DOMAIN";
								   run_nikto "$WORKING_DIR"/"$ALL_DOMAIN";
								   break;
								   ;;
							[2]* )
								   run_ffuf "$DOMAIN" "$XXL" "$WORKING_DIR"/"$ALL_DOMAIN";
								   # run_gobuster "$DOMAIN" "$XXL" "$WORKING_DIR"/"$ALL_DOMAIN";
								   run_bfac "$WORKING_DIR"/"$ALL_DOMAIN";
								   run_nikto "$WORKING_DIR"/"$ALL_DOMAIN";
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
		   echo -e "[i] Beginning directory bruteforcing on interesting discovered domains.";
		   while true; do
				   echo -e "$GREEN""[i] Which wordlist do you want to use?""$NC";
				   echo -e "$BLUE""   Small: ~20k words""$NC";
				   echo -e "$BLUE""   Medium: ~167k words""$NC";
				   echo -e "$BLUE""   Large: ~215k words""$NC";
				   echo -e "$BLUE""   XL: ~373k words""$NC";
				   echo -e "$BLUE""   2XL: ~486k words""$GREEN";
				   read -rp "[i] Enter S/M/L/X/2 " CHOICE;
				   case $CHOICE in
						   [sS]* )
								   run_ffuf "$DOMAIN" "$SMALL" "$WORKING_DIR"/interesting-domains.txt;
								   # run_gobuster "$DOMAIN" "$SMALL" "$WORKING_DIR"/interesting-domains.txt;
								   run_bfac "$WORKING_DIR"/interesting-domains.txt;
								   run_nikto "$WORKING_DIR"/interesting-domains.txt;
								   break;
								   ;;
							[mM]* )
								   run_ffuf "$DOMAIN" "$MEDIUM" "$WORKING_DIR"/interesting-domains.txt;
								   # run_gobuster "$DOMAIN" "$MEDIUM" "$WORKING_DIR"/interesting-domains.txt;
								   run_bfac "$WORKING_DIR"/interesting-domains.txt;
								   run_nikto "$WORKING_DIR"/interesting-domains.txt;
								   break;
								   ;;
							[lL]* )
								   run_ffuf "$DOMAIN" "$LARGE" "$WORKING_DIR"/interesting-domains.txt;
								   # run_gobuster "$DOMAIN" "$LARGE" "$WORKING_DIR"/interesting-domains.txt;
								   run_bfac "$WORKING_DIR"/interesting-domains.txt;
								   run_nikto "$WORKING_DIR"/interesting-domains.txt;
								   break;
								   ;;
							[xX]* )
								   run_ffuf "$DOMAIN" "$XL" "$WORKING_DIR"/interesting-domains.txt;
								   # run_gobuster "$DOMAIN" "$XL" "$WORKING_DIR"/interesting-domains.txt;
								   run_bfac "$WORKING_DIR"/interesting-domains.txt;
								   run_nikto "$WORKING_DIR"/interesting-domains.txt;
								   break;
								   ;;
							[2]* )
								   run_ffuf "$DOMAIN" "$XXL" "$WORKING_DIR"/interesting-domains.txt;
								   # run_gobuster "$DOMAIN" "$XXL" "$WORKING_DIR"/interesting-domains.txt;
								   run_bfac "$WORKING_DIR"/interesting-domains.txt;
								   run_nikto "$WORKING_DIR"/interesting-domains.txt;
								   break;
								   ;;
				   esac
		   done
		   break;
		   ;;
   * )     
		   echo -e "$RED""Please enter Y/y, N/n, or A/a.""$NC";
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
						gobuster -u https://"$ADOMAIN" -s '200,201,202,204,307,308,401,403,405,500,501,503' -to 3s -e -k -t 20 -w "$2" -o "$WORKING_DIR"/gobuster/"$ADOMAIN".txt;
						COUNT=$((COUNT - 1));
						echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
				done < "$3"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE Gobuster took $DIFF seconds to run.""$NC";
		else
				echo -e "$GREEN""[i]$BLUE Running gobuster against $(wc -l "$3" | cut -d ' ' -f 1) discovered interesting domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: gobuster -u https://$DOMAIN -s '200,201,202,204,307,308,401,403,405,500,501,503' -to 3s -e -k -t 20 -w $2 -o $WORKING_DIR/gobuster""$NC";
				# Run gobuster
				mkdir "$WORKING_DIR"/gobuster;
				COUNT=$(wc -l "$3" | cut -d ' ' -f 1)
				START=$(date +%s);
				while read -r ADOMAIN; do
						gobuster -u https://"$ADOMAIN" -s '200,201,202,204,307,308,401,403,405,500,501,503' -to 3s -e -k -t 20 -w "$2" -o "$WORKING_DIR"/gobuster/"$ADOMAIN".txt;
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
		trap "Cancelling process." SIGINT;
		# Call with domain as $1, wordlist size as $2, and domain list as $3
		if [[ $3 == $WORKING_DIR/$ALL_DOMAIN ]]; then
				echo -e "$GREEN""[i]$BLUE Running ffuf against all $(wc -l "$3" | cut -d ' ' -f 1) unique discovered domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: ffuf -u https://$DOMAIN/FUZZ -w $2 -fc 301,302 -k | tee $WORKING_DIR/ffuf.""$NC";
				# Run ffuf
				mkdir "$WORKING_DIR"/ffuf;
				COUNT=$(wc -l "$3" | cut -d ' ' -f 1)
				START=$(date +%s);
				while read -r ADOMAIN; do
						ffuf -u https://"$ADOMAIN"/FUZZ -w "$2" -fc 301,302 -k -mc 200,201,202,204,401,403,500,502,503 | tee "$WORKING_DIR"/ffuf/"$ADOMAIN";
						COUNT=$((COUNT - 1));
						echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
				done < "$3"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE ffuf took $DIFF seconds to run.""$NC";
		else
				echo -e "$GREEN""[i]$BLUE Running ffuf against $(wc -l "$3" | cut -d ' ' -f 1) discovered interesting domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: ffuf -u https://$DOMAIN/FUZZ -w $2 -fc 301,302 -k | tee $WORKING_DIR/ffuf.""$NC";
				# Run ffuf
				mkdir "$WORKING_DIR"/ffuf;
				COUNT=$(wc -l "$3" | cut -d ' ' -f 1)
				START=$(date +%s);
				while read -r ADOMAIN; do
						ffuf -u https://"$ADOMAIN"/FUZZ -w "$2" -fc 301,302 -k -mc 200,201,202,204,401,403,500,502,503 | tee "$WORKING_DIR"/ffuf/"$ADOMAIN";
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
				echo -e "$GREEN""[i]$BLUE Running bfac against all $(wc -l "$2" | cut -d ' ' -f 1) unique discovered domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: bfac -u $DOMAIN -xsc 404,301,302,400 -o $WORKING_DIR/bfac.""$NC";
				# Run ffuf
				mkdir "$WORKING_DIR"/bfac;
				START=$(date +%s);
				while read -r ADOMAIN; do
						$BFAC -u "$ADOMAIN" -xsc 404,301,302,400 -o "$WORKING_DIR"/bfac/"$ADOMAIN";
				done < "$1"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE ffuf took $DIFF seconds to run.""$NC";
		else
				echo -e "$GREEN""[i]$BLUE Running bfac against $(wc -l "$2" | cut -d ' ' -f 1) discovered interesting domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: bfac -u $DOMAIN -xsc 404,301,302,400 -o $WORKING_DIR/bfac.""$NC";
				# Run ffuf
				mkdir "$WORKING_DIR"/bfac;
				START=$(date +%s);
				while read -r ADOMAIN; do
						$BFAC -u "$ADOMAIN" -xsc 404,301,302,400 -o "$WORKING_DIR"/bfac/"$ADOMAIN";
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
				echo -e "$GREEN""[i]$BLUE Running nikto against $(wc -l "$1" | cut -d ' ' -f 1) discovered interesting domains.""$NC";
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

run_subdomain_brute;
sleep 1;
run_aquatone;
sleep 1;
get_interesting;
sleep 5;
run_portscan;
sleep 1;
run_content_discovery;
sleep 1;
get_interesting;
sleep 3;
list_found;
