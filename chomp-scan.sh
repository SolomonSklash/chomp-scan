#!/usr/bin/env bash

# Colors
NC='\033[0m';
RED='\033[0;31m';
GREEN='\033[0;32m';
BLUE='\033[0;34m';
ORANGE='\033[0;33m';

# Wordlists
SHORT=wordlists/subdomains-top1mil-20000.txt;
LONG=wordlists/sortedcombined-knock-dnsrecon-fierce-reconng.txt;
HUGE=wordlists/huge-200k.txt;
SMALL=wordlists/big.txt;
MEDIUM=wordlists/raft-large-combined.txt;
LARGE=wordlists/seclists-combined.txt;
XL=wordlists/haddix_content_discovery_all.txt;
XXL=wordlists/haddix-seclists-combined.txt;

# User-defined CLI argument variables
DOMAIN="";
SUBDOMAIN_WORDLIST="";
SUBDOMAIN_BRUTE=1; # Constant
CONTENT_WORDLIST="";
CONTENT_DISCOVERY=0;
SCREENSHOTS=0;
INFO_GATHERING=0;
PORTSCANNING=0;
HTTP="https"
CUSTOM_WORKING_DIR="";
WORKING_DIR="";
BLACKLIST=blacklist.txt;
INTERACTIVE=0;
USE_ALL=0;
USE_DISCOVERED=0;
DEFAULT_MODE=0;
INTERESTING=interesting.txt;
SKIP_MASSCAN=0;
NOTICA="";
CONFIG_FILE="";
TOOL_PATH="$HOME/bounty/tools";
TOOL_PATH_SET=0;

# Config file variables
ENABLE_DNSCAN=0;
ENABLE_SUBFINDER=0;
ENABLE_SUBLIST3R=0;
ENABLE_AMASS=0;
ENABLE_GOALTDNS=0;
ENABLE_MASSDNS=1; # Constant
ENABLE_INCEPTION=0;
ENABLE_WAYBACKURLS=0;
ENABLE_FFUF=0;
ENABLE_GOBUSTER=0;
ENABLE_DIRSEARCH=0;
ENABLE_SUBJACK=0;
ENABLE_CORSTEST=0;
ENABLE_S3SCANNER=0;
ENABLE_BFAC=0;
ENABLE_WHATWEB=0;
ENABLE_WAFW00F=0;
ENABLE_NIKTO=0;
ENABLE_MASSCAN=0;
ENABLE_NMAP=0;
ENABLE_SCREENSHOTS=0;
ENABLE_RESCOPE=0;
ENABLE_KNOCK=0;

# Other variables
ALL_IP=all_discovered_ips.txt;
ALL_DOMAIN=all_discovered_domains.txt;
ALL_RESOLVED=all_resolved_domains.txt;

function set_tool_paths() {
		# If tool paths have not been set, set them
		if [[ "$TOOL_PATH_SET" -eq 0 ]]; then
				TOOL_PATH_SET=1;
				SUBFINDER=$(command -v subfinder);
				SUBJACK=$(command -v subjack);
				FFUF=$(command -v ffuf);
				WHATWEB=$(command -v whatweb);
				WAFW00F=$(command -v wafw00f);
				GOBUSTER=$(command -v gobuster);
				CHROMIUM=$(command -v chromium);
				NMAP=$(command -v nmap);
				MASSCAN=$(command -v masscan);
				NIKTO=$(command -v nikto);
				INCEPTION=$(command -v inception);
				WAYBACKURLS=$(command -v waybackurls);
				GOALTDNS=$(command -v goaltdns);
				RESCOPE=$(command -v rescope);
				KNOCK=$(command -v knockpy);
				SUBLIST3R=$TOOL_PATH/Sublist3r/sublist3r.py;
				DNSCAN=$TOOL_PATH/dnscan/dnscan.py;
				MASSDNS_BIN=$TOOL_PATH/massdns/bin/massdns;
				MASSDNS_RESOLVERS=resolvers.txt;
				AQUATONE=$TOOL_PATH/aquatone/aquatone;
				BFAC=$TOOL_PATH/bfac/bfac;
				DIRSEARCH=$TOOL_PATH/dirsearch/dirsearch.py;
				SNALLY=$TOOL_PATH/snallygaster/snallygaster;
				CORSTEST=$TOOL_PATH/CORStest/corstest.py;
				S3SCANNER=$TOOL_PATH/S3Scanner/s3scanner.py;
				AMASS=$TOOL_PATH/amass/amass;
		else
				return;
		fi
}

function banner() {
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
By SolomonSklash - github.com/SolomonSklash/chomp-scan - solomonsklash@0xfeed.io
		';
		echo -e "$BLUE""$BANNER";
}

function usage() {
		banner;
		echo -e "$GREEN""chomp-scan.sh -u example.com -a d short -cC large -p -o path/to/directory\\n""$NC";
		echo -e "$GREEN""Usage of Chomp Scan:""$NC";
		echo -e "$BLUE""\\t-u domain \\n\\t\\t$ORANGE (required) Domain name to scan. This should not include a scheme, e.g. https:// or http://.""$NC";
		echo -e "$BLUE""\\t-L config-file \\n\\t\\t$ORANGE (optional) The path to a config file. This can be used to provide more granular control over what tools are run.""$NC";
		echo -e "$BLUE""\\t-d wordlist\\n\\t\\t$ORANGE (optional) The wordlist to use for subdomain enumeration. Three built-in lists, short, long, and huge can be used, as well as the path to a custom wordlist. The default is short.""$NC";
		echo -e "$BLUE""\\t-c \\n\\t\\t$ORANGE (optional) Enable content discovery phase. The wordlist for this option defaults to short if not provided.""$NC";
		echo -e "$BLUE""\\t-C wordlist \\n\\t\\t$ORANGE (optional) The wordlist to use for content discovery. Five built-in lists, small, medium, large, xl, and xxl can be used, as well as the path to a custom wordlist. The default is small.""$NC";
		echo -e "$BLUE""\\t-P file-path \\n\\t\\t$ORANGE (optional) Set a custom directory for the location of tools. The path must exist and the directory must contain all needed tools.""$NC";
		echo -e "$BLUE""\\t-s \\n\\t\\t$ORANGE (optional) Enable screenshots using Aquatone.""$NC";
		echo -e "$BLUE""\\t-i \\n\\t\\t$ORANGE (optional) Enable information gathering phase, using subjack, CORStest, S3Scanner, bfac, whatweb, wafw00f, and nikto.""$NC";
		echo -e "$BLUE""\\t-p \\n\\t\\t$ORANGE (optional) Enable portscanning phase, using masscan (run as root) and nmap.""$NC";
		echo -e "$BLUE""\\t-I \\n\\t\\t$ORANGE (optional) Enable interactive mode. This allows you to select certain tool options and inputs interactively. This cannot be run with -D.""$NC";
		echo -e "$BLUE""\\t-D \\n\\t\\t$ORANGE (optional) Enable default non-interactive mode. This mode uses pre-selected defaults and requires no user interaction or options. This cannot be run with -I.""$NC";
		echo -e "\\t\\t\\t$ORANGE    Options: Subdomain enumeration wordlist: short.""$NC";
		echo -e "\\t\\t\\t$ORANGE             Content discovery wordlist: small.""$NC";
		echo -e "\\t\\t\\t$ORANGE             Aquatone screenshots: yes.""$NC";
		echo -e "\\t\\t\\t$ORANGE             Portscanning: yes.""$NC";
		echo -e "\\t\\t\\t$ORANGE             Information gathering: yes.""$NC";
		echo -e "\\t\\t\\t$ORANGE             Domains to scan: all unique discovered.""$NC";
		echo -e "$BLUE""\\t-b wordlist \\n\\t\\t$ORANGE (optional) Set custom domain blacklist file.""$NC";
		echo -e "$BLUE""\\t-X wordlist \\n\\t\\t$ORANGE (optional) Set custom interesting word list.""$NC";
		echo -e "$BLUE""\\t-o directory \\n\\t\\t$ORANGE (optional) Set custom output directory. It must exist and be writable.""$NC";
		echo -e "$BLUE""\\t-n string \\n\\t\\t$ORANGE (optional) Notica URL parameter for notification when the script has completed. See notica.us for details.""$NC";
		echo -e "$BLUE""\\t-a \\n\\t\\t$ORANGE (optional) Use all unique discovered domains for scans, rather than interesting domains. This cannot be used with -A.""$NC";
		echo -e "$BLUE""\\t-A \\n\\t\\t$ORANGE (optional, default) Use only interesting discovered domains for scans, rather than all discovered domains. This cannot be used with -a.""$NC";
		echo -e "$BLUE""\\t-H \\n\\t\\t$ORANGE (optional) Use HTTP for connecting to sites instead of HTTPS.""$NC";
		echo -e "$BLUE""\\t-r \\n\\t\\t$ORANGE (optional) Enable creation of Burp scope JSON file with rescope.""$NC";
		echo -e "$BLUE""\\t-h \\n\\t\\t$ORANGE (optional) Display this help page.""$NC";
}

# Check that a file path exists and is not empty
function exists() {
		if [[ -e "$1" ]]; then
				if [[ -s "$1" ]]; then
						return 1;
				else
						return 0;
				fi
		else
				return 0;
		fi
}

# Check for root for runs using masscan
function check_root() {
		if [[ $EUID -ne 0 ]]; then
		   while true; do
				   echo -e "$ORANGE""[!] Please note: Script is not being run as root."
				   echo -e "$ORANGE""[!] Provided script options include masscan, which must run as root."
				   echo -e "$ORANGE""[!] The script will hang while waiting for the sudo password."
				   echo -e "$ORANGE""[!] If you are using Notica notifications, you will be notified when the sudo password is needed."
				   read -rp "Do you want to exit and [R]e-run as root, [S]kip masscan, or [E]nter sudo password? " CHOICE;
						   case $CHOICE in
								   [rR]* )
										   echo -e "$RED""[!] Exiting script.""$NC";
										   exit 1;
										   ;;
								   [sS]* )
										   echo -e "$ORANGE""Skipping masscan.""$NC";
										   SKIP_MASSCAN=1;
										   break;
										   ;;
								   [eE]* )
										   echo -e "$ORANGE""Script will wait for sudo password.""$NC";
										   break;
										   ;;
								   * )
										   echo -e "$ORANGE""Please enter [R]e-run, [S]kip masscan, or [E]nter sudo password.""$NC";
										   ;;
						   esac
		   done
		fi
}

# Parse configuration file
function parse_config() {
		# Parse [general]

		DOMAIN=$(grep '^DOMAIN' "$CONFIG_FILE" | cut -d '=' -f 2);
		if [[ "$DOMAIN" == "" ]]; then
				echo -e "$RED""[!] No domain was provided in the configuration file.""$NC";
				exit 1;
		else
				DOMAIN_COUNT=$(echo "$DOMAIN" | awk --field-separator="," "{ print NF }")
				if [[ "$DOMAIN_COUNT" -gt 1 ]]; then
						DOMAIN_ARRAY=();
						for (( i=1; i<=$DOMAIN_COUNT; i++ )); do
								DOMAIN_ARRAY+=($(echo $DOMAIN | cut -d ',' -f $i | tr -d " "));
						done
				fi
		fi

		if [[ $(grep '^ENABLE_HTTP' "$CONFIG_FILE" | cut -d '=' -f 2) == "YES" ]]; then
				HTTP="http";
		fi

		OUTPUT_DIR=$(grep '^OUTPUT_DIR' "$CONFIG_FILE" | cut -d '=' -f 2);
		if [[ "$OUTPUT_DIR" != "" ]]; then
				if [[ -w "$OUTPUT_DIR" ]]; then
						CUSTOM_WORKING_DIR="$OUTPUT_DIR";
				else
						echo -e "$RED""[!] Output directory $OUTPUT_DIR does not exist or is not writable. Please check the configuration file.""$NC";
						exit 1;
				fi
		fi

		if [[ $(grep '^USE_ALL' "$CONFIG_FILE" | cut -d '=' -f 2) == "YES" ]]; then	
				USE_ALL=1;
		fi

		if [[ $(grep '^NOTICA' "$CONFIG_FILE" | cut -d '=' -f 2) != "" ]]; then	
				NOTICA=$(grep '^NOTICA' "$CONFIG_FILE" | cut -d '=' -f 2)
		fi

		BLACKLIST_FILE=$(grep '^BLACKLIST' "$CONFIG_FILE" | cut -d '=' -f 2);
		if [[ "$BLACKLIST_FILE" != "" ]]; then
				if [[ -w "$BLACKLIST_FILE" ]]; then
						BLACKLIST="$BLACKLIST_FILE";
				else
						echo -e "$RED""[!] Blacklist file $BLACKLIST_FILE does not exist or is not writable. Please check the configuration file.""$NC";
						exit 1;
				fi
		fi

		INTERESTING_FILE=$(grep '^INTERESTING' "$CONFIG_FILE" | cut -d '=' -f 2);
		if [[ "$INTERESTING_FILE" != "" ]]; then
				if [[ -w "$INTERESTING_FILE" ]]; then
						INTERESTING="$INTERESTING_FILE";
				else
						echo -e "$RED""[!] Interesting file $INTERESTING_FILE does not exist or is not writable. Please check the configuration file.""$NC";
						exit 1;
				fi
		fi

		CONFIG_TOOL_PATH=$(grep '^TOOL_PATH' "$CONFIG_FILE" | cut -d '=' -f 2);
		if [[ "$CONFIG_TOOL_PATH" != "" ]]; then
				if [[ -w "$CONFIG_TOOL_PATH" ]]; then
						TOOL_PATH="$CONFIG_TOOL_PATH";
						set_tool_paths;
				else
						echo -e "$RED""[!] Custom tool path $CONFIG_TOOL_PATH does not exist or is not writable. Please check the configuration file.""$NC";
						exit 1;
				fi
		fi

		if [[ $(grep '^ENABLE_RESCOPE' "$CONFIG_FILE" | cut -d '=' -f 2) == "YES" ]]; then
				ENABLE_RESCOPE=1;
		fi

		# Parse [subdomain enumeration]

		if [[ $(grep '^ENABLE_DNSCAN' "$CONFIG_FILE" | cut -d '=' -f 2) == "YES" ]]; then
				ENABLE_DNSCAN=1;
		fi

		if [[ $(grep '^ENABLE_SUBFINDER' "$CONFIG_FILE" | cut -d '=' -f 2) == "YES" ]]; then
				ENABLE_SUBFINDER=1;
		fi

		if [[ $(grep '^ENABLE_SUBLIST3R' "$CONFIG_FILE" | cut -d '=' -f 2) == "YES" ]]; then
				ENABLE_SUBLIST3R=1;
		fi

		if [[ $(grep '^ENABLE_KNOCK' "$CONFIG_FILE" | cut -d '=' -f 2) == "YES" ]]; then
				ENABLE_KNOCK=1;
		fi

		if [[ $(grep '^ENABLE_GOALTDNS' "$CONFIG_FILE" | cut -d '=' -f 2) == "YES" ]]; then
				ENABLE_GOALTDNS=1;
		fi

		if [[ $(grep '^ENABLE_AMASS' "$CONFIG_FILE" | cut -d '=' -f 2) == "YES" ]]; then
				ENABLE_AMASS=1;
		fi

		SUB_WORDLIST=$(grep '^SUBDOMAIN_WORDLIST' "$CONFIG_FILE" | cut -d '=' -f 2);
		# Set to one of the defaults, else use provided wordlist
		case "$SUB_WORDLIST" in
				SHORT )
						SUBDOMAIN_WORDLIST="$SHORT";
						;;
				LONG )
						SUBDOMAIN_WORDLIST="$LONG";
						;;
				HUGE )
						SUBDOMAIN_WORDLIST="$HUGE";
						;;
		esac
		if [[ "$SUBDOMAIN_WORDLIST" == "" ]]; then
				if [[ "$SUB_WORDLIST" != "" ]]; then
						if [[ -w "$SUB_WORDLIST" ]]; then
								SUBDOMAIN_WORDLIST="$SUB_WORDLIST";
						else
								echo -e "$RED""[!] Subdomain enumeration wordlist $SUB_WORDLIST does not exist or is not writable. Please check the configuration file.""$NC";
								exit 1;
						fi
				fi
		fi

		# Check that at least one subdomain enumeration tool is enabled
		if [[ "$ENABLE_DNSCAN" -eq 0 ]] && [[ "$ENABLE_SUBFINDER" -eq 0 ]] && [[ "$ENABLE_SUBLIST3R" -eq 0 ]] && [[ "$ENABLE_KNOCK" -eq 0 ]] && [[ "ENABLE_AMASS" -eq 0 ]]; then
				echo -e "$RED""[!] At least one subdomain enumeration tool must be enabled. Please check the configuration file.""$NC";
				exit 1;
		fi

		# Parse [content discovery]

		if [[ $(grep '^ENABLE_INCEPTION' "$CONFIG_FILE" | cut -d '=' -f 2) == "YES" ]]; then
				ENABLE_INCEPTION=1;
		fi

		if [[ $(grep '^ENABLE_WAYBACKURLS' "$CONFIG_FILE" | cut -d '=' -f 2) == "YES" ]]; then
				ENABLE_WAYBACKURLS=1;
		fi

		if [[ $(grep '^ENABLE_FFUF' "$CONFIG_FILE" | cut -d '=' -f 2) == "YES" ]]; then
				ENABLE_FFUF=1;
		fi

		if [[ $(grep '^ENABLE_GOBUSTER' "$CONFIG_FILE" | cut -d '=' -f 2) == "YES" ]]; then
				ENABLE_GOBUSTER=1;
		fi

		if [[ $(grep '^ENABLE_DIRSEARCH' "$CONFIG_FILE" | cut -d '=' -f 2) == "YES" ]]; then
				ENABLE_DIRSEARCH=1;
		fi

		CON_WORDLIST=$(grep '^CONTENT_WORDLIST' "$CONFIG_FILE" | cut -d '=' -f 2);
		# Set to one of the defaults, else use provided wordlist
		case "$CON_WORDLIST" in
				SMALL )
						CONTENT_WORDLIST="$SMALL";
						;;
				MEDIUM )
						CONTENT_WORDLIST="$MEDIUM";
						;;
				LARGE )
						CONTENT_WORDLIST="$LARGE";
						;;
				XL )
						CONTENT_WORDLIST="$XL";
						;;
				XXL )
						CONTENT_WORDLIST="$XXL";
						;;
		esac
		if [[ "$CONTENT_WORDLIST" == "" ]]; then
				if [[ "$CON_WORDLIST" != "" ]]; then
						if [[ -w "$CON_WORDLIST" ]]; then
								CONTENT_WORDLIST="$CON_WORDLIST";
						else
								echo -e "$RED""[!] Content discovery wordlist $CON_WORDLIST does not exist or is not writable. Please check the configuration file.""$NC";
								exit 1;
						fi
				fi
		fi

		# Parse [information gathering]

		if [[ $(grep '^ENABLE_SUBJACK' "$CONFIG_FILE" | cut -d '=' -f 2) == "YES" ]]; then
				ENABLE_SUBJACK=1;
		fi

		if [[ $(grep '^ENABLE_CORSTEST' "$CONFIG_FILE" | cut -d '=' -f 2) == "YES" ]]; then
				ENABLE_CORSTEST=1;
		fi

		if [[ $(grep '^ENABLE_S3SCANNER' "$CONFIG_FILE" | cut -d '=' -f 2) == "YES" ]]; then
				ENABLE_S3SCANNER=1;
		fi

		if [[ $(grep '^ENABLE_BFAC' "$CONFIG_FILE" | cut -d '=' -f 2) == "YES" ]]; then
				ENABLE_BFAC=1;
		fi

		if [[ $(grep '^ENABLE_WHATWEB' "$CONFIG_FILE" | cut -d '=' -f 2) == "YES" ]]; then
				ENABLE_WHATWEB=1;
		fi

		if [[ $(grep '^ENABLE_WAFW00F' "$CONFIG_FILE" | cut -d '=' -f 2) == "YES" ]]; then
				ENABLE_WAFW00F=1;
		fi

		if [[ $(grep '^ENABLE_NIKTO' "$CONFIG_FILE" | cut -d '=' -f 2) == "YES" ]]; then
				ENABLE_NIKTO=1;
		fi

		# Parse [port scanning]

		if [[ $(grep '^ENABLE_MASSCAN' "$CONFIG_FILE" | cut -d '=' -f 2) == "YES" ]]; then
				check_root
				ENABLE_MASSCAN=1;
		fi

		if [[ $(grep '^ENABLE_NMAP' "$CONFIG_FILE" | cut -d '=' -f 2) == "YES" ]]; then
				ENABLE_NMAP=1;
		fi

		# Parse [screenshots]

		if [[ $(grep '^ENABLE_SCREENSHOTS' "$CONFIG_FILE" | cut -d '=' -f 2) == "YES" ]]; then
				ENABLE_SCREENSHOTS=1;
		fi
}

# Handle CLI arguments
while getopts ":hu:d:L:C:sicb:IaADX:po:Hn:P:r" opt; do
		case ${opt} in
				h ) # -h help
						usage;
						exit;
						;;
				u ) # -u URL/domain
						DOMAIN=$OPTARG;
						;;
				L ) # -L configuration file
						exists "$OPTARG";
						RESULT=$?;
						if [[ "$RESULT" -eq 1 ]]; then
								CONFIG_FILE="$OPTARG";
								parse_config;
						else
								echo -e "$RED""[!] Provided configuration file $OPTARG is empty or doesn't exist.""$NC";
								usage;
								exit 1;
						fi
						# Exit early if config file is found
						break;
						;;
				d ) # -d subdomain enumeration wordlist
						# Set to one of the defaults, else use provided wordlist
						case "$OPTARG" in
								short )
										SUBDOMAIN_WORDLIST="$SHORT";
										;;
								long )
										SUBDOMAIN_WORDLIST="$LONG";
										;;
								huge )
										SUBDOMAIN_WORDLIST="$HUGE";
										;;
						esac

						if [[ "$SUBDOMAIN_WORDLIST" == "" ]]; then
								exists "$OPTARG";
								RESULT=$?;
								if [[ "$RESULT" -eq 1 ]]; then
										SUBDOMAIN_WORDLIST="$OPTARG";
								else
										echo -e "$RED""[!] Provided subdomain enumeration wordlist $OPTARG is empty or doesn't exist.""$NC";
										usage;
										exit 1;
								fi
						fi
						;;
				C ) # -C content discovery wordlist
						# Set to one of the defaults, else use provided wordlist
						case "$OPTARG" in
								small )
										CONTENT_WORDLIST="$SMALL";
										;;
								medium )
										CONTENT_WORDLIST="$MEDIUM";
										;;
								large )
										CONTENT_WORDLIST="$LARGE";
										;;
								xl )
										CONTENT_WORDLIST="$XL";
										;;
								xxl )
										CONTENT_WORDLIST="$XXL";
										;;
						esac

						if [[ "$CONTENT_WORDLIST" == "" ]]; then
								exists "$OPTARG";
								RESULT=$?;
								if [[ "$RESULT" -eq 1 ]]; then
										CONTENT_WORDLIST="$OPTARG";
								else
										echo -e "$RED""[!] Provided content discovery wordlist $OPTARG is empty or doesn't exist.""$NC";
										usage;
										exit 1;
								fi
						fi
						;;
				c ) # -c enable content discovery
						CONTENT_DISCOVERY=1;
						;;
				s ) # -s enable screenshots
						SCREENSHOTS=1;
						;;
				i ) # -i enable information gathering
						INFO_GATHERING=1;
						;;
				b ) # -b domain blacklist file
						exists "$OPTARG";
						RESULT=$?;
						if [[ "$RESULT" -eq 1 ]]; then
								BLACKLIST="$OPTARG";
						else
								echo -e "$RED""[!] Provided blacklist $OPTARG is empty or doesn't exist.""$NC";
								usage;
								exit 1;
						fi
						;;
				I ) # -I enable interactive mode
						INTERACTIVE=1;
						;;
				a ) # -a use all discovered domains
						echo "Use all discovered domains."
						# Check that USE_DISCOVERED is not set
						if [[ "$USE_DISCOVERED" != 1 ]]; then
								USE_ALL=1;
						else
								echo -e "$RED""[!] Using -A interesting domains is mutually exclusive to using -a all domains.""$NC";
								usage;
								exit 1;
						fi
						;;
				A ) # -A use only interesting discovered domains
						# Check that USE_DISCOVERED is not set
						if [[ "$USE_ALL" != 1 ]]; then
								USE_DISCOVERED=1;
						else
								echo -e "$RED""[!] Using -a all domains is mutually exclusive to using -A interesting domains.""$NC";
								usage;
								exit 1;
						fi
						echo "Use only interesting discovered domains."
						;;
				D ) # -D enable default non-interactive mode
						DEFAULT_MODE=1;
						;;
				X ) # -X interesting word list file
						exists "$OPTARG";
						RESULT=$?;
						if [[ "$RESULT" -eq 1 ]]; then
								INTERESTING="$OPTARG";
						else
								echo -e "$RED""[!] Provided interesting words file $OPTARG is empty or doesn't exist.""$NC";
								usage;
								exit 1;
						fi
						;;
				p ) # -p enable port scanning
						PORTSCANNING=1;
						;;
				P ) # -P custom tool path
						exists "$OPTARG";
						RESULT=$?;
						if [[ "$RESULT" -eq 1 ]]; then
								TOOL_PATH="$OPTARG";
								set_tool_paths;
						else
								echo -e "$RED""[!] Provided tool path $OPTARG is empty or doesn't exist.""$NC";
								usage;
								exit 1;
						fi
						;;
				o ) # -o output directory
						if [[ -w "$OPTARG" ]]; then
								WORKING_DIR="$OPTARG";
						else
								echo -e "$RED""[!] Provided output directory $OPTARG is not writable or doesn't exist.""$NC";
								usage;
								exit 1;
						fi
						;;
				H ) # -H enable HTTP for URLs
						HTTP="http";
						;;
				n ) # -n Notica URL parameter
						NOTICA="$OPTARG";
						;;
				r ) # -r run rescope
						ENABLE_RESCOPE=1;
						;;
				\? ) # Invalid option
						echo -e "$RED""[!] Invalid Option: -$OPTARG" 1>&2;
						usage;
						exit 1;
						;;
				: ) # Invalid option
						echo -e "$RED""[!] Invalid Option: -$OPTARG requires an argument" 1>&2;
						usage;
						exit 1;
						;;
				* ) # Invalid option
						echo -e "$RED""[!] Invalid Option: -$OPTARG" 1>&2;
						usage;
						exit 1;
						;;
		esac
done
shift $((OPTIND -1));

function check_paths() {
		# Check if paths haven't been set and set them
		set_tool_paths;

		# Check for Debian/Ubuntu and set proper paths
		grep 'Ubuntu' /etc/issue 1>/dev/null;
		UBUNTU="$?";
		if [[ "$UBUNTU" -eq 0 ]]; then 
				CHROMIUM=$(command -v chromium-browser);
		fi
		grep 'Debian' /etc/issue 1>/dev/null;
		DEBIAN="$?";
		if [[ "$DEBIAN" -eq 0 ]]; then 
				NIKTO="$HOME/$TOOL_PATH/nikto/program/nikto.pl";
		fi

		# Check that all paths are set
		if [[ "$SUBFINDER" == "" ]] || [[ ! -f "$SUBFINDER" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for subfinder does not exit.";
				exit 1;
		fi
		if [[ "$SUBJACK" == "" ]] || [[ ! -f "$SUBJACK" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for subjack does not exit.";
				exit 1;
		fi
		if [[ "$FFUF" == "" ]] || [[ ! -f "$FFUF" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for ffuf does not exit.";
				exit 1;
		fi
		if [[ "$WHATWEB" == "" ]] || [[ ! -f "$WHATWEB" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for whatweb does not exit.";
				exit 1;
		fi
		if [[ "$WAFW00F" == "" ]] || [[ ! -f "$WAFW00F" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for wafw00f does not exit.";
				exit 1;
		fi
		if [[ "$GOBUSTER" == "" ]] || [[ ! -f "$GOBUSTER" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for gobuster does not exit.";
				exit 1;
		fi
		if [[ "$CHROMIUM" == "" ]] || [[ ! -f "$CHROMIUM" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for chromium does not exit.";
				exit 1;
		fi
		if [[ "$NMAP" == "" ]] || [[ ! -f "$NMAP" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for nmap does not exit.";
				exit 1;
		fi
		if [[ "$MASSCAN" == "" ]] || [[ ! -f "$MASSCAN" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for masscan does not exit.";
				exit 1;
		fi
		if [[ "$INCEPTION" == "" ]] || [[ ! -f "$INCEPTION" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for inception does not exit.";
				exit 1;
		fi
		if [[ "$WAYBACKURLS" == "" ]] || [[ ! -f "$WAYBACKURLS" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for waybackurls does not exit.";
				exit 1;
		fi
		if [[ "$GOALTDNS" == "" ]] || [[ ! -f "$GOALTDNS" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for goaltdns does not exit.";
				exit 1;
		fi
		if [[ "$SUBLIST3R" == "" ]] || [[ ! -f "$SUBLIST3R" ]]; then
				grep 'Kali' /etc/issue 1>/dev/null; 
				KALI=$?;
				if [[ "$KALI" -eq 0 ]]; then
						SUBLIST3R=$(command -v sublist3r);
				else
						echo -e "$RED""[!] The path or the file specified by the path for sublist3r does not exit.";
						exit 1;
				fi
		fi
		if [[ "$DNSCAN" == "" ]] || [[ ! -f "$DNSCAN" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for dnscan does not exit.";
				exit 1;
		fi
		if [[ "$MASSDNS_BIN" == "" ]] || [[ ! -f "$MASSDNS_BIN" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for the massdns binary does not exit.";
				exit 1;
		fi
		if [[ "$MASSDNS_RESOLVERS" == "" ]] || [[ ! -f "$MASSDNS_RESOLVERS" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for massdns resolver file does not exit.";
				exit 1;
		fi
		if [[ "$AQUATONE" == "" ]] || [[ ! -f "$AQUATONE" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for aquatone does not exit.";
				exit 1;
		fi
		if [[ "$BFAC" == "" ]] || [[ ! -f "$BFAC" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for bfac does not exit.";
				exit 1;
		fi
		if [[ "$DIRSEARCH" == "" ]] || [[ ! -f "$DIRSEARCH" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for dirsearch does not exit.";
				exit 1;
		fi
		if [[ "$CORSTEST" == "" ]] || [[ ! -f "$CORSTEST" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for CORStest does not exit.";
				exit 1;
		fi
		if [[ "$S3SCANNER" == "" ]] || [[ ! -f "$S3SCANNER" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for S3Scanner does not exit.";
				exit 1;
		fi
		if [[ "$AMASS" == "" ]] || [[ ! -f "$AMASS" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for amass does not exit.";
				exit 1;
		fi
		if [[ "$RESCOPE" == "" ]] || [[ ! -f "$RESCOPE" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for rescope does not exit.";
				exit 1;
		fi
		if [[ "$KNOCK" == "" ]] || [[ ! -f "$KNOCK" ]]; then
				echo -e "$RED""[!] The path or the file specified by the path for knockpy does not exit.";
				exit 1;
		fi
}

function unique() {
		# Remove blacklisted domains from all discovered domains
		if [[ ! -z $BLACKLIST ]]; then 
				while read -r bad; do
						grep -v "$bad" "$WORKING_DIR"/$ALL_DOMAIN > "$WORKING_DIR"/temp;
						mv "$WORKING_DIR"/temp  "$WORKING_DIR"/$ALL_DOMAIN;
				done < "$BLACKLIST";
		fi

		# Remove blacklisted domains from all resolved domains
		if [[ ! -z $BLACKLIST ]]; then 
				while read -r bad; do
						grep -v "$bad" "$WORKING_DIR"/$ALL_RESOLVED > "$WORKING_DIR"/temp1;
						mv "$WORKING_DIR"/temp1  "$WORKING_DIR"/$ALL_RESOLVED;
				done < "$BLACKLIST";
		fi

		# Get unique list of IPs and domains, ignoring case
		sort "$WORKING_DIR"/$ALL_DOMAIN | uniq -i > "$WORKING_DIR"/temp2;
		mv "$WORKING_DIR"/temp2 "$WORKING_DIR"/$ALL_DOMAIN;

		sort -V "$WORKING_DIR"/$ALL_IP | uniq -i > "$WORKING_DIR"/temp2;
		mv "$WORKING_DIR"/temp2 "$WORKING_DIR"/$ALL_IP;

		sort "$WORKING_DIR"/$ALL_RESOLVED | uniq -i > "$WORKING_DIR"/temp3;
		mv "$WORKING_DIR"/temp3 "$WORKING_DIR"/$ALL_RESOLVED;
}

function list_found() {
		unique;
		echo -e "$GREEN""[+] Found $(wc -l "$WORKING_DIR"/$ALL_IP | awk '{print $1}') unique IPs so far.""$NC"
		echo -e "$GREEN""[+] Found $(wc -l "$WORKING_DIR"/$ALL_DOMAIN | awk '{print $1}') unique discovered domains so far.""$NC"
		echo -e "$GREEN""[+] Found $(wc -l "$WORKING_DIR"/$ALL_RESOLVED | awk '{print $1}') unique resolvable domains so far.""$NC"
}

function get_interesting() {
		# Takes optional silent argument as $1

		while read -r word; do
				grep "$word" "$WORKING_DIR"/$ALL_RESOLVED >> "$WORKING_DIR"/"$INTERESTING_DOMAINS";
		done < "$INTERESTING";

		# Make sure no there are duplicates
		sort -u "$WORKING_DIR"/"$INTERESTING_DOMAINS" > "$WORKING_DIR"/temp4;
		mv "$WORKING_DIR"/temp4 "$WORKING_DIR"/"$INTERESTING_DOMAINS";

		if [[ "$1" == "silent" ]]; then
				return;
		else
				# Make sure > 0 domains are found
				FOUND=$(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}');
				if [[ $FOUND -gt 0 ]]; then
						echo -e "$RED""[!] The following $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') potentially interesting subdomains have been found ($WORKING_DIR/$INTERESTING_DOMAINS):""$ORANGE";
						cat "$WORKING_DIR"/"$INTERESTING_DOMAINS";
						sleep 1;
				else
						echo -e "$RED""[!] No interesting domains have been found yet.""$NC";
						sleep 1;
				fi
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
		echo -e "$GREEN""[!]$ORANGE dnscan found $(wc -l "$WORKING_DIR"/dnscan-ips.txt | awk '{print $1}') IP/domain pairs.""$NC";
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
		echo -e "$GREEN""[!]$ORANGE Subfinder found $(wc -l "$WORKING_DIR"/subfinder-domains.txt | awk '{print $1}') domains.""$N";
		list_found;
		sleep 1;
}

function run_sublist3r() {
		# Call with domain as $1, doesn't support wordlists

		# Trap SIGINT so broken sublist3r runs can be cancelled
		trap cancel SIGINT;

		echo -e "$GREEN""[i]$BLUE Scanning $1 with sublist3r.""$NC";
		echo -e "$GREEN""[i]$ORANGE Command: $SUBLIST3R -d $1 -v -b -t 50 -o $WORKING_DIR/sublist3r-output.txt.""$NC";
		START=$(date +%s);
		"$SUBLIST3R" -d "$1" -v -b -t 50 -o "$WORKING_DIR"/sublist3r-output.txt
		END=$(date +%s);
		DIFF=$(( END - START ));

		# Check that output file exists
		if [[ -f "$WORKING_DIR"/sublist3r-output.txt ]]; then
				# Cat output into main lists
				cat "$WORKING_DIR"/sublist3r-output.txt >> "$WORKING_DIR"/$ALL_DOMAIN;
				echo -e "$GREEN""[i]$BLUE sublist3r took $DIFF seconds to run.""$NC";
				echo -e "$GREEN""[!]$ORANGE sublist3r found $(wc -l "$WORKING_DIR"/sublist3r-output.txt | awk '{print $1}') domains.""$NC";
		fi

		list_found;
		sleep 1;
}

function run_knock() {
		# Call with domain as $1 and wordlist as $2

		# Trap SIGINT so broken knock runs can be cancelled
		trap cancel SIGINT;

		echo -e "$GREEN""[i]$BLUE Scanning $1 with knock.""$NC";
		echo -e "$GREEN""[i]$ORANGE Command: knockpy $DOMAIN -w $2 -o $WORKING_DIR/knock-output.txt""$NC";

		START=$(date +%s);
		"$KNOCK" "$1" -w "$2" -o "$WORKING_DIR"/knock-output.txt;
		END=$(date +%s);
		DIFF=$(( END - START ));

		# Parse output and add to all domain and IP lists
		awk -F ',' '{print $2" "$3}' "$WORKING_DIR"/knock-output.txt | grep -e "$DOMAIN$" > "$WORKING_DIR"/knock-tmp.txt;
		cut -d ' ' -f 1 "$WORKING_DIR"/knock-tmp.txt >> "$WORKING_DIR"/"$ALL_IP";
		cut -d ' ' -f 2 "$WORKING_DIR"/knock-tmp.txt >> "$WORKING_DIR"/"$ALL_DOMAIN";

		echo -e "$GREEN""[i]$BLUE knock took $DIFF seconds to run.""$NC";
		echo -e "$GREEN""[!]$ORANGE knock found $(wc -l "$WORKING_DIR"/knock-tmp.txt | awk '{print $1}') domains.""$NC";

		list_found;
		sleep 1;
		rm "$WORKING_DIR"/knock-tmp.txt;
}

function run_amass() {
		# Call with domain as $1 and wordlist as $2

		echo -e "$GREEN""[i]$BLUE Scanning $1 with amass.""$NC";
		echo -e "$GREEN""[i]$ORANGE Command: amass -d $1 -w $2 -ip -rf resolvers.txt -active -o $WORKING_DIR/amass-output.txt -min-for-recursive 3 -bl $BLACKLIST""$NC";
		START=$(date +%s);
		"$AMASS" -d "$1" -brute -w "$2" -ip -rf resolvers.txt -active -o "$WORKING_DIR"/amass-output.txt -min-for-recursive 3 -bl "$BLACKLIST";
		END=$(date +%s);
		DIFF=$(( END - START ));

		# Check that output file exists amd parse output
		if [[ -f "$WORKING_DIR"/amass-output.txt ]]; then
				# Cat output into main lists
				cut -d ' ' -f 1 "$WORKING_DIR"/amass-output.txt >> "$WORKING_DIR"/"$ALL_DOMAIN";
				cut -d ' ' -f 2 "$WORKING_DIR"/amass-output.txt >> "$WORKING_DIR"/"$ALL_IP";
				echo -e "$GREEN""[i]$BLUE amass took $DIFF seconds to run.""$NC";
				echo -e "$GREEN""[!]$ORANGE amass found $(wc -l "$WORKING_DIR"/amass-output.txt | awk '{print $1}') domains.""$NC";
		fi

		list_found;
		sleep 1;
}

function run_goaltdns() {
		# Run goaltdns with found subdomains combined with altdns-wordlist.txt

		echo -e "$GREEN""[i]$BLUE Running goaltdns against all $(wc -l "$WORKING_DIR"/$ALL_DOMAIN | awk '{print $1}') unique discovered subdomains to generate domains for masscan to resolve.""$NC";
		echo -e "$GREEN""[i]$ORANGE Command: goaltdns -l $WORKING_DIR/$ALL_DOMAIN -w wordlists/altdns-words.txt -o $WORKING_DIR/goaltdns-output.txt.""$NC";
		START=$(date +%s);
		"$GOALTDNS" -l "$WORKING_DIR"/$ALL_DOMAIN -w wordlists/altdns-words.txt -o "$WORKING_DIR"/goaltdns-output.txt;
		END=$(date +%s);
		DIFF=$(( END - START ));

		echo -e "$GREEN""[i]$BLUE Goaltdns took $DIFF seconds to run.""$NC";
		echo -e "$GREEN""[i]$BLUE Goaltdns generated $(wc -l "$WORKING_DIR"/goaltdns-output.txt | awk '{print $1}') subdomains.""$NC";
		sleep 1;
}

function run_massdns() {
		# Call with domain as $1, wordlist as $2, and alone as $3

		# Check if being called without goaltdns
		if [[ "$3" == "alone" ]]; then
				# Create wordlist with appended domain for massdns
				sed "/.*/ s/$/\.$1/" $2 > "$WORKING_DIR"/massdns-appended.txt;

				echo -e "$GREEN""[i]$BLUE Scanning $(cat "$WORKING_DIR"/$ALL_DOMAIN "$WORKING_DIR"/$ALL_IP "$WORKING_DIR"/massdns-appended.txt | sort | uniq | wc -l) current unique $1 domains with massdns (in quiet mode).""$NC";
				echo -e "$GREEN""[i]$ORANGE Command: cat (all found domains and IPs) | $MASSDNS_BIN -r $MASSDNS_RESOLVERS -q -t A -o S -w $WORKING_DIR/massdns-result.txt.""$NC";
				START=$(date +%s);
				cat "$WORKING_DIR"/$ALL_DOMAIN "$WORKING_DIR"/$ALL_IP "$WORKING_DIR"/massdns-appended.txt | sort | uniq | $MASSDNS_BIN -r $MASSDNS_RESOLVERS -q -t A -o S -w "$WORKING_DIR"/massdns-result.txt;
				END=$(date +%s);
				DIFF=$(( END - START ));
		else
				# Run goaltdns to get altered domains to resolve along with other discovered domains
				run_goaltdns;

				# Create wordlist with appended domain for massdns
				sed "/.*/ s/$/\.$1/" $2 > "$WORKING_DIR"/massdns-appended.txt;

				echo -e "$GREEN""[i]$BLUE Scanning $(cat "$WORKING_DIR"/$ALL_DOMAIN "$WORKING_DIR"/$ALL_IP "$WORKING_DIR"/goaltdns-output.txt "$WORKING_DIR"/massdns-appended.txt | sort | uniq | wc -l) current unique $1 domains and IPs, goaltdns generated domains, and domain-appended wordlist with massdns (in quiet mode).""$NC";
				echo -e "$GREEN""[i]$ORANGE Command: cat (all found domains and IPs) | $MASSDNS_BIN -r $MASSDNS_RESOLVERS -q -t A -o S -w $WORKING_DIR/massdns-result.txt.""$NC";
				START=$(date +%s);
				cat "$WORKING_DIR"/$ALL_DOMAIN "$WORKING_DIR"/$ALL_IP "$WORKING_DIR"/goaltdns-output.txt "$WORKING_DIR"/massdns-appended.txt | sort | uniq | $MASSDNS_BIN -r $MASSDNS_RESOLVERS -q -t A -o S -w "$WORKING_DIR"/massdns-result.txt;
				END=$(date +%s);
				DIFF=$(( END - START ));
		fi

		# Parse results
		grep CNAME "$WORKING_DIR"/massdns-result.txt > "$WORKING_DIR"/massdns-CNAMEs.txt;
		grep -v CNAME "$WORKING_DIR"/massdns-result.txt | cut -d ' ' -f 3 >> "$WORKING_DIR"/$ALL_IP;

		# Add any new in-scope CNAMEs to main list
		cut -d ' ' -f 3 "$WORKING_DIR"/massdns-CNAMEs.txt | grep "$DOMAIN.$" >> "$WORKING_DIR"/$ALL_DOMAIN;

		# Add newly discovered domains to all domains list
		grep -v CNAME "$WORKING_DIR"/massdns-result.txt | cut -d ' ' -f 1 >> "$WORKING_DIR"/"$ALL_DOMAIN";
		# Remove trailing periods from results
		sed -i 's/\.$//' "$WORKING_DIR"/"$ALL_DOMAIN";

		# Add all resolved domains to resolved domain list
		grep -v CNAME "$WORKING_DIR"/massdns-result.txt | cut -d ' ' -f 1 >> "$WORKING_DIR"/"$ALL_RESOLVED";
		# Remove trailing periods from results
		sed -i 's/\.$//' "$WORKING_DIR"/"$ALL_RESOLVED";

		echo -e "$GREEN""[i]$BLUE Massdns took $DIFF seconds to run.""$NC";
		echo -e "$GREEN""[!]$ORANGE Check $WORKING_DIR/massdns-CNAMEs.txt for a list of CNAMEs found.""$NC";
		sleep 1;

		list_found;
		sleep 1;
}

function run_subdomain_brute() {
		# Ask user for wordlist size
		while true; do
		  echo -e "$ORANGE""[i] Beginning subdomain enumeration. This will use dnscan, subfinder, sublist3r, knockpy, amass, and massdns + goaltdns.";
		  echo -e "$GREEN""[?] What size wordlist would you like to use for subdomain bruteforcing?";
		  echo -e "$GREEN""[i] Sizes are [S]mall (22k domains), [L]arge (102k domains), and [H]uge (199k domains).";
		  echo -e "$ORANGE";
		  read -rp "[?] Please enter S/s, L/l, or H/h. " ANSWER

		  case $ANSWER in
		   [sS]* ) 
				   run_dnscan "$DOMAIN" "$SHORT";
				   run_subfinder "$DOMAIN" "$SHORT";
				   run_sublist3r "$DOMAIN";
				   run_knock "$DOMAIN" "$SHORT";
				   run_amass "$DOMAIN" "$SHORT";
				   run_massdns "$DOMAIN" "$SHORT";
				   break
				   ;;

		   [lL]* ) 
				   run_dnscan "$DOMAIN" "$LONG";
				   run_subfinder "$DOMAIN" "$LONG";
				   run_sublist3r "$DOMAIN";
				   run_knock "$DOMAIN" "$LONG";
				   run_amass "$DOMAIN" "$LONG";
				   run_massdns "$DOMAIN" "$LONG";
				   return;
				   ;;

		   [hH]* ) 
				   run_dnscan "$DOMAIN" "$SHORT";
				   run_subfinder "$DOMAIN" "$HUGE";
				   run_sublist3r "$DOMAIN";
				   run_knock "$DOMAIN" "$HUGE";
				   run_amass "$DOMAIN" "$HUGE";
				   run_massdns "$DOMAIN" "$HUGE";
				   break;
				   ;;
		   * )     
				   echo -e "$RED"""[!] Please enter S/s, L/l, or H/h. "$NC"
				   ;;
		  esac
		done
}

function run_aquatone () {
		# Call empty or with default as $1 for -D default non-interactive mode
		if [[ "$1" == "default" ]]; then
				if [[ "$USE_ALL" -eq 1 ]]; then
						mkdir "$WORKING_DIR"/aquatone;
						echo -e "$BLUE""[i] Running aquatone against all $(wc -l "$WORKING_DIR"/$ALL_RESOLVED | awk '{print $1}') unique discovered subdomains.""$NC";
						START=$(date +%s);
						$AQUATONE -threads 10 -chrome-path "$CHROMIUM" -ports medium -out "$WORKING_DIR"/aquatone < "$WORKING_DIR"/$ALL_RESOLVED;
						END=$(date +%s);
						DIFF=$(( END - START ));
						echo -e "$GREEN""[i]$BLUE Aquatone took $DIFF seconds to run.""$NC";
				elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') -gt 0 ]]; then
						mkdir "$WORKING_DIR"/aquatone;
						echo -e "$BLUE""[i] Running aquatone against all $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') interesting discovered subdomains.""$NC";
						START=$(date +%s);
						$AQUATONE -threads 10 -chrome-path "$CHROMIUM" -ports medium -out "$WORKING_DIR"/aquatone < "$WORKING_DIR"/"$INTERESTING_DOMAINS";
						END=$(date +%s);
						DIFF=$(( END - START ));
						echo -e "$GREEN""[i]$BLUE Aquatone took $DIFF seconds to run.""$NC";
				else
						mkdir "$WORKING_DIR"/aquatone;
						echo -e "$BLUE""[i] Running aquatone against all $(wc -l "$WORKING_DIR"/$ALL_RESOLVED | awk '{print $1}') unique discovered subdomains.""$NC";
						START=$(date +%s);
						$AQUATONE -threads 10 -chrome-path "$CHROMIUM" -ports medium -out "$WORKING_DIR"/aquatone < "$WORKING_DIR"/$ALL_RESOLVED;
						END=$(date +%s);
						DIFF=$(( END - START ));
						echo -e "$GREEN""[i]$BLUE Aquatone took $DIFF seconds to run.""$NC";
				fi
		else
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

				echo -e "$GREEN""[i]$BLUE Running aquatone against all $(wc -l "$WORKING_DIR"/$ALL_RESOLVED | awk '{print $1}') unique discovered subdomains.""$NC";
				START=$(date +%s);
				$AQUATONE -threads 10 -chrome-path "$CHROMIUM" -ports medium -out "$WORKING_DIR"/aquatone < "$WORKING_DIR"/$ALL_RESOLVED;
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE Aquatone took $DIFF seconds to run.""$NC";
		fi
}

function run_masscan() {
		# Check if not root and SKIP_MASSCAN is set
		if [[ "$SKIP_MASSCAN" -eq 1 ]]; then
				echo -e "$ORANGE""[!] Skipping masscan since script is not being run as root.""$NC";
				sleep 1;
		else
				# Run masscan against all IPs found on all ports
				echo -e "$GREEN""[i]$BLUE Running masscan against all $(wc -l "$WORKING_DIR"/$ALL_IP | awk '{print $1}') unique discovered IP addresses.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: masscan -p1-65535 -il $WORKING_DIR/$ALL_IP --rate=7000 -oL $WORKING_DIR/masscan-output.txt.""$NC";

				# Check that IP list is not empty
				IP_COUNT=$(wc -l "$WORKING_DIR"/$ALL_IP | awk '{print $1}');
				if [[ "$IP_COUNT" -lt 1 ]]; then
						echo -e "$RED""[i] No IP addresses have been found. Skipping masscan scan.""$NC";
						return;
				fi

				START=$(date +%s);
				if [[ "$NOTICA" != "" ]]; then
						run_notica_sudo;
				fi
				sudo "$MASSCAN" -p1-65535 -iL "$WORKING_DIR"/$ALL_IP --rate=7000 -oL "$WORKING_DIR"/root-masscan-output.txt;
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE Masscan took $DIFF seconds to run.""$NC";

				# Trim # from first and last lines of output
				grep -v '#' "$WORKING_DIR"/root-masscan-output.txt > "$WORKING_DIR"/masscan-output.txt;
			fi
}

function run_nmap() {
		# Check that IP list is not empty
		IP_COUNT=$(wc -l "$WORKING_DIR"/$ALL_IP | awk '{print $1}');
		if [[ "$IP_COUNT" -lt 1 ]]; then
				echo -e "$RED""[i] No IP addresses have been found. Skipping nmap scan.""$NC";
				return;
		fi

		# Run nmap against all-ip.txt against ports found by masscan, unless alone arg is passed as $1
		if [[ "$1" == "alone" ]]; then
				echo -e "$GREEN""[i]$BLUE Running nmap against all $(wc -l "$WORKING_DIR"/"$ALL_IP" | awk '{print $1}') unique discovered IP addresses.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: nmap -n -v -sV -iL $WORKING_DIR/all_ip.txt -oA $WORKING_DIR/nmap-output --stylesheet https://raw.githubusercontent.com/honze-net/nmap-bootstrap-xsl/master/nmap-bootstrap.xsl.""$NC";
				START=$(date +%s);
				"$NMAP" -n -v -sV -iL "$WORKING_DIR"/"$ALL_IP" -oA "$WORKING_DIR"/nmap-output --stylesheet https://raw.githubusercontent.com/honze-net/nmap-bootstrap-xsl/master/nmap-bootstrap.xsl;
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE Nmap took $DIFF seconds to run.""$NC";
		# Make sure masscan actually created output
		elif [[ ! -s "$WORKING_DIR"/masscan-output.txt ]]; then
				echo -e "$GREEN""[i]$BLUE Running nmap against all $(wc -l "$WORKING_DIR"/"$ALL_IP" | awk '{print $1}') unique discovered IP addresses.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: nmap -n -v -sV -iL $WORKING_DIR/all_discovered_ips.txt -oA $WORKING_DIR/nmap-output --stylesheet https://raw.githubusercontent.com/honze-net/nmap-bootstrap-xsl/master/nmap-bootstrap.xsl.""$NC";
				START=$(date +%s);
				"$NMAP" -n -v -sV -iL "$WORKING_DIR"/"$ALL_IP" -oA "$WORKING_DIR"/nmap-output --stylesheet https://raw.githubusercontent.com/honze-net/nmap-bootstrap-xsl/master/nmap-bootstrap.xsl;
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE Nmap took $DIFF seconds to run.""$NC";
		else
				# Process masscan output for ports found
				cut -d ' ' -f 3  "$WORKING_DIR"/masscan-output.txt >> "$WORKING_DIR"/temp;
				sort "$WORKING_DIR"/temp | uniq > "$WORKING_DIR"/ports;
				rm "$WORKING_DIR"/temp;

				# Count ports in case it's over nmap's ~22k parameter limit, then run multiple scans
				PORT_NUMBER=$(wc -l "$WORKING_DIR"/ports | awk '{print $1}');

				if [[ $PORT_NUMBER -gt 22000 ]]; then
						echo -e "$GREEN""[!]$RED WARNING: Masscan found more than 22k open ports. This is more than nmap's port argument length limit, and likely indicates lots of false positives. Consider running nmap with -p- to scan all ports.""$NC";
						sleep 2;
						return;
				fi

				# Get live IPs from masscan
				cut -d ' ' -f 4 "$WORKING_DIR"/masscan-output.txt >> "$WORKING_DIR"/"$ALL_IP";
				
				echo -e "$GREEN""[i]$BLUE Running nmap against $(wc -l "$WORKING_DIR"/"$ALL_IP" | awk '{print $1}') unique discovered IP addresses and $(wc -l "$WORKING_DIR"/ports | awk '{print $1}') ports identified by masscan.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: nmap -n -v -sV -iL $WORKING_DIR/all_discovered_ips.txt -p $(tr '\n' , < "$WORKING_DIR"/ports) -oA $WORKING_DIR/nmap-output.""$NC";
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

function parse_gobuster() {
		# Call with file name as $1
        FILE=$1;
   
        # Get total line count
        TOTAL=$(wc -l "$1" | awk '{print $1}');
		if [[ "$TOTAL" -eq 0 ]]; then
				return
		fi
   
        # Get counts of different return codes
	    COUNT_200=$(grep -c 'Status: 200' "$FILE");
        COUNT_201=$(grep -c 'Status: 201' "$FILE");
        COUNT_202=$(grep -c 'Status: 202' "$FILE");
        COUNT_204=$(grep -c 'Status: 204' "$FILE");
        COUNT_307=$(grep -c 'Status: 307' "$FILE");
        COUNT_308=$(grep -c 'Status: 308' "$FILE");
        COUNT_400=$(grep -c 'Status: 400' "$FILE");
        COUNT_401=$(grep -c 'Status: 401' "$FILE");
        COUNT_403=$(grep -c 'Status: 403' "$FILE");
        COUNT_405=$(grep -c 'Status: 405' "$FILE");
        COUNT_500=$(grep -c 'Status: 500' "$FILE");
        COUNT_501=$(grep -c 'Status: 501' "$FILE");
        COUNT_502=$(grep -c 'Status: 502' "$FILE");
        COUNT_503=$(grep -c 'Status: 503' "$FILE");
   
        # Write return code counts to top of file
	    echo -e "$GREEN""Number of 200 responses:\\t$BLUE $COUNT_200" >> "$FILE"-parsed;
        echo -e "$GREEN""Number of 201 responses:\\t$BLUE $COUNT_201" >> "$FILE"-parsed;
        echo -e "$GREEN""Number of 202 responses:\\t$BLUE $COUNT_202" >> "$FILE"-parsed;
        echo -e "$GREEN""Number of 204 responses:\\t$BLUE $COUNT_204" >> "$FILE"-parsed;
        echo -e "$GREEN""Number of 307 responses:\\t$BLUE $COUNT_307" >> "$FILE"-parsed;
        echo -e "$GREEN""Number of 308 responses:\\t$BLUE $COUNT_308" >> "$FILE"-parsed;
        echo -e "$GREEN""Number of 400 responses:\\t$BLUE $COUNT_400" >> "$FILE"-parsed;
        echo -e "$GREEN""Number of 401 responses:\\t$BLUE $COUNT_401" >> "$FILE"-parsed;
        echo -e "$GREEN""Number of 403 responses:\\t$BLUE $COUNT_403" >> "$FILE"-parsed;
        echo -e "$GREEN""Number of 405 responses:\\t$BLUE $COUNT_405" >> "$FILE"-parsed;
        echo -e "$GREEN""Number of 500 responses:\\t$BLUE $COUNT_500" >> "$FILE"-parsed;
        echo -e "$GREEN""Number of 501 responses:\\t$BLUE $COUNT_501" >> "$FILE"-parsed;
        echo -e "$GREEN""Number of 502 responses:\\t$BLUE $COUNT_502" >> "$FILE"-parsed;
        echo -e "$GREEN""Number of 503 responses:\\t$BLUE $COUNT_503" >> "$FILE"-parsed;
   
        if [[ "$TOTAL" -gt 1000 ]]; then
                echo -e "$GREEN""False positives:\\t\\t$RED Likely! Total count is $TOTAL.""$NC" >> "$FILE"-parsed;
        else
                echo -e $"$GREEN""False positives:\\t\\t$BLUE Unlikely. Total count is $TOTAL.""$NC" >> "$FILE"-parsed;
        fi  
        echo -e "\\n\\n\\n" >> "$FILE"-parsed;
   
        # Echo all parse d output to file
		cat "$FILE" >> "$FILE"-parsed;
}

function run_gobuster() {
		# Call with domain as $1, wordlist size as $2, and domain list as $3
		if [[ $3 == $WORKING_DIR/$ALL_RESOLVED ]]; then # Run against all resolvable domains
				echo -e "$GREEN""[i]$BLUE Running gobuster against all $(wc -l "$3" | awk '{print $1}') unique discovered domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: gobuster -u https://$DOMAIN -s '200,201,202,204,307,308,400,401,403,405,500,501,502,503' -to 3s -e -k -t 20 -w $2 -o gobuster.""$NC";
				# Run gobuster
				mkdir "$WORKING_DIR"/gobuster;
				COUNT=$(wc -l "$3" | awk '{print $1}')
				START=$(date +%s);
				while read -r ADOMAIN; do
						"$GOBUSTER" -u "$HTTP"://"$ADOMAIN" -s '200,201,202,204,307,308,400,401,403,405,500,501,502,503' -to 3s -e -k -t 20 -w "$2" -o "$WORKING_DIR"/gobuster/"$ADOMAIN".txt;
						COUNT=$((COUNT - 1));
						if [[ "$COUNT" != 0 ]]; then
								echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
						fi
				done < "$3"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE Gobuster took $DIFF seconds to run.""$NC";
		else # Run against all interesting domains
				echo -e "$GREEN""[i]$BLUE Running gobuster against all $(wc -l "$3" | awk '{print $1}') discovered interesting domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: gobuster -u $HTTP://$DOMAIN -s '200,201,202,204,307,308,400,401,403,405,500,501,502,503' -to 3s -e -k -t 20 -w $2 -o $WORKING_DIR/gobuster""$NC";
				# Run gobuster
				mkdir "$WORKING_DIR"/gobuster;
				COUNT=$(wc -l "$3" | awk '{print $1}')
				START=$(date +%s);
				while read -r ADOMAIN; do
						"$GOBUSTER" -u "$HTTP"://"$ADOMAIN" -s '200,201,202,204,307,308,400,401,403,405,500,501,502,503' -to 3s -e -k -t 20 -w "$2" -o "$WORKING_DIR"/gobuster/"$ADOMAIN".txt;
						COUNT=$((COUNT - 1));
						if [[ "$COUNT" != 0 ]]; then
								echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
						fi
				done < "$3"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE Gobuster took $DIFF seconds to run.""$NC";
		fi

		# Parse results for better readability of the output
		for file in "$WORKING_DIR"/gobuster/*; do
				COUNT=$(wc -l "$file" | awk '{print $1}');
				# No output files have 17 lines
				if [[ $COUNT -gt 17 ]]; then
						parse_gobuster "$file";
				fi
		done
}

function parse_ffuf() {
		# Call with file name as $1
        FILE=$1;
   
        # Get total line count
        TOTAL=$(wc -l "$1" | awk '{print $1}');
   
        # Get counts of different return codes
        COUNT_200=$(grep 'Status' "$1" | grep -c 200);
        COUNT_201=$(grep 'Status' "$1" | grep -c 201);
        COUNT_202=$(grep 'Status' "$1" | grep -c 202);
        COUNT_204=$(grep 'Status' "$1" | grep -c 204);
        COUNT_307=$(grep 'Status' "$1" | grep -c 307);
        COUNT_308=$(grep 'Status' "$1" | grep -c 308);
        COUNT_400=$(grep 'Status' "$1" | grep -c 400);
        COUNT_401=$(grep 'Status' "$1" | grep -c 401);
        COUNT_403=$(grep 'Status' "$1" | grep -c 403);
        COUNT_405=$(grep 'Status' "$1" | grep -c 405);
        COUNT_500=$(grep 'Status' "$1" | grep -c 500);
        COUNT_501=$(grep 'Status' "$1" | grep -c 501);
        COUNT_502=$(grep 'Status' "$1" | grep -c 502);
        COUNT_503=$(grep 'Status' "$1" | grep -c 503);
   
        # Write return code counts to top of file
        echo -e "$GREEN""Number of 200 responses:\\t$BLUE $COUNT_200" >> "$FILE"-parsed;
        echo -e "$GREEN""Number of 201 responses:\\t$BLUE $COUNT_201" >> "$FILE"-parsed;
        echo -e "$GREEN""Number of 202 responses:\\t$BLUE $COUNT_202" >> "$FILE"-parsed;
        echo -e "$GREEN""Number of 204 responses:\\t$BLUE $COUNT_204" >> "$FILE"-parsed;
        echo -e "$GREEN""Number of 307 responses:\\t$BLUE $COUNT_307" >> "$FILE"-parsed;
        echo -e "$GREEN""Number of 308 responses:\\t$BLUE $COUNT_308" >> "$FILE"-parsed;
        echo -e "$GREEN""Number of 400 responses:\\t$BLUE $COUNT_400" >> "$FILE"-parsed;
        echo -e "$GREEN""Number of 401 responses:\\t$BLUE $COUNT_401" >> "$FILE"-parsed;
        echo -e "$GREEN""Number of 403 responses:\\t$BLUE $COUNT_403" >> "$FILE"-parsed;
        echo -e "$GREEN""Number of 405 responses:\\t$BLUE $COUNT_405" >> "$FILE"-parsed;
        echo -e "$GREEN""Number of 500 responses:\\t$BLUE $COUNT_500" >> "$FILE"-parsed;
        echo -e "$GREEN""Number of 501 responses:\\t$BLUE $COUNT_501" >> "$FILE"-parsed;
        echo -e "$GREEN""Number of 502 responses:\\t$BLUE $COUNT_502" >> "$FILE"-parsed;
        echo -e "$GREEN""Number of 503 responses:\\t$BLUE $COUNT_503" >> "$FILE"-parsed;
   
        if [[ "$TOTAL" -gt 1000 ]]; then
                echo -e "$GREEN""False positives:\\t\\t$RED Likely! Total count is $TOTAL.""$NC" >> "$FILE"-parsed;
        else
                echo -e $"$GREEN""False positives:\\t\\t$BLUE Unlikely. Total count is $TOTAL.""$NC" >> "$FILE"-parsed;
        fi  
        echo -e "\\n\\n\\n" >> "$FILE"-parsed;
   
        # Echo all parsed output to file
        grep -v '::' "$1" | grep 'Status' >> "$FILE"-parsed;
}

function run_ffuf() {
		# Trap SIGINT so broken ffuf runs can be cancelled
		trap cancel SIGINT;

		# Call with domain as $1, wordlist size as $2, and domain list as $3
		if [[ $3 == $WORKING_DIR/$ALL_RESOLVED ]]; then
				echo -e "$GREEN""[i]$BLUE Running ffuf against all $(wc -l "$3" | awk '{print $1}') unique discovered domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: ffuf -u $HTTP://$DOMAIN/FUZZ -w $2 -sf -se -fc 301,302,404 -k | tee $WORKING_DIR/ffuf.""$NC";
				# Run ffuf
				mkdir "$WORKING_DIR"/ffuf;
				COUNT=$(wc -l "$3" | awk '{print $1}')
				START=$(date +%s);
				while read -r ADOMAIN; do
						"$FFUF" -u "$HTTP"://"$ADOMAIN"/FUZZ -w "$2" -timeout 3 -sf -se -fc 301,302,404 -k -mc all | tee "$WORKING_DIR"/ffuf/"$ADOMAIN";
						COUNT=$((COUNT - 1));
						if [[ "$COUNT" != 0 ]]; then
								echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
						fi
				done < "$3"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE ffuf took $DIFF seconds to run.""$NC";
		else
				echo -e "$GREEN""[i]$BLUE Running ffuf against all $(wc -l "$3" | awk '{print $1}') discovered interesting domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: ffuf -u $HTTP://$DOMAIN/FUZZ -w $2 -sf -se -fc 301,302,404 -k | tee $WORKING_DIR/ffuf.""$NC";
				# Run ffuf
				mkdir "$WORKING_DIR"/ffuf;
				COUNT=$(wc -l "$3" | awk '{print $1}')
				START=$(date +%s);
				while read -r ADOMAIN; do
						"$FFUF" -u "$HTTP"://"$ADOMAIN"/FUZZ -w "$2" -timeout 3 -sf -se -fc 301,302,404 -k -mc all | tee "$WORKING_DIR"/ffuf/"$ADOMAIN";
						COUNT=$((COUNT - 1));
						if [[ "$COUNT" != 0 ]]; then
								echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
						fi
				done < "$3"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE ffuf took $DIFF seconds to run.""$NC";
		fi

		# Parse results for better readability of the output
		for file in "$WORKING_DIR"/ffuf/*; do
				COUNT=$(wc -l "$file" | awk '{print $1}');
				# No output files have 17 lines
				if [[ $COUNT -gt 17 ]]; then
						parse_ffuf "$file";
				fi
		done
}

function run_dirsearch() {
		# Trap SIGINT so broken dirsearch runs can be cancelled
		trap cancel SIGINT;

		# Call with domain as $1, wordlist size as $2, and domain list as $3
		if [[ $3 == $WORKING_DIR/$ALL_RESOLVED ]]; then
				echo -e "$GREEN""[i]$BLUE Running dirsearch against all $(wc -l "$3" | awk '{print $1}') unique discovered domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: dirsearch -u $DOMAIN -e php,aspx,asp -t 20 -x 310,302,404 -F --plain-text-report=$WORKING_DIR/dirsearch/$DOMAIN.txt -w $2""$NC";
				# Run dirsearch
				mkdir "$WORKING_DIR"/dirsearch;
				COUNT=$(wc -l "$3" | awk '{print $1}')
				START=$(date +%s);
				while read -r ADOMAIN; do
						"$DIRSEARCH" -u "$HTTP"://"$ADOMAIN" -e php,aspx,asp -t 20 -x 301,302,404 -F --plain-text-report="$WORKING_DIR"/dirsearch/"$ADOMAIN".txt -w "$2";
						COUNT=$((COUNT - 1));
						if [[ "$COUNT" != 0 ]]; then
								echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
						fi
				done < "$3"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE Dirsearch took $DIFF seconds to run.""$NC";
		else
				echo -e "$GREEN""[i]$BLUE Running dirsearch against all $(wc -l "$3" | awk '{print $1}') discovered interesting domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: dirsearch -u $DOMAIN -e php,aspx,asp -t 20 -x 301,302,404 -F --plain-text-report=$WORKING_DIR/dirsearch/$DOMAIN.txt -w $2""$NC";
				# Run dirsearch
				mkdir "$WORKING_DIR"/dirsearch;
				COUNT=$(wc -l "$3" | awk '{print $1}')
				START=$(date +%s);
				while read -r ADOMAIN; do
						"$DIRSEARCH" -u "$HTTP"://"$ADOMAIN" -e php,aspx,asp -t 20 -x 301,302,404 -F --plain-text-report="$WORKING_DIR"/dirsearch/"$ADOMAIN".txt -w "$2";
						COUNT=$((COUNT - 1));
						if [[ "$COUNT" != 0 ]]; then
								echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
						fi
				done < "$3"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE Dirsearch took $DIFF seconds to run.""$NC";
		fi
}

function run_snallygaster() {
		# Call with domain as $1, wordlist size as $2, and domain list as $3
		if [[ $3 == $WORKING_DIR/$ALL_RESOLVED ]]; then
				echo -e "$GREEN""[i]$BLUE Running snallygaster against all $(wc -l "$3" | awk '{print $1}') unique discovered domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: snallygaster $DOMAIN -d --nowww | tee $WORKING_DIR/snallygaster/$ADOMAIN""$NC";
				# Run snallygaster
				mkdir "$WORKING_DIR"/snallygaster;
				COUNT=$(wc -l "$3" | awk '{print $1}')
				START=$(date +%s);
				while read -r ADOMAIN; do
						"$SNALLY" "$ADOMAIN" -d --nowww # | tee "$WORKING_DIR"/snallygaster/"$ADOMAIN";
						COUNT=$((COUNT - 1));
						if [[ "$COUNT" != 0 ]]; then
								echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
						fi
				done < "$3"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE Snallygaster took $DIFF seconds to run.""$NC";
		else
				echo -e "$GREEN""[i]$BLUE Running dirsearch against all $(wc -l "$3" | awk '{print $1}') discovered interesting domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: snallygaster $DOMAIN -d --nowww | tee $WORKING_DIR/snallygaster/$ADOMAIN""$NC";
				# Run snallygaster
				mkdir "$WORKING_DIR"/snallygaster;
				COUNT=$(wc -l "$3" | awk '{print $1}')
				START=$(date +%s);
				while read -r ADOMAIN; do
						"$SNALLY" "$ADOMAIN" -d --nowww  #| tee "$WORKING_DIR"/snallygaster/"$ADOMAIN";
						COUNT=$((COUNT - 1));
						if [[ "$COUNT" != 0 ]]; then
								echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
						fi
				done < "$3"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE Snallygaster took $DIFF seconds to run.""$NC";
		fi
}

function run_inception() {
		# Trap SIGINT so broken inception runs can be cancelled
		trap cancel SIGINT;

		# Call with domain as $1, wordlist size as $2, and domain list as $3
		if [[ $3 == $WORKING_DIR/$ALL_RESOLVED ]]; then
				echo -e "$GREEN""[i]$BLUE Running inception against all $(wc -l "$3" | awk '{print $1}') unique discovered domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: inception -d all_discovered_domains -v | tee $WORKING_DIR/inception""$NC";
				# Run inception
				mkdir "$WORKING_DIR"/inception;
				START=$(date +%s);
				"$INCEPTION" -d "$3" -v -provider wordlists/provider.json | tee "$WORKING_DIR"/inception/inception-output.txt;
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE Inception took $DIFF seconds to run.""$NC";
		else
				echo -e "$GREEN""[i]$BLUE Running inception against all $(wc -l "$3" | awk '{print $1}') discovered interesting domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: inception -d interesting_domains.txt -v | tee $WORKING_DIR/inception""$NC";
				# Run inception
				mkdir "$WORKING_DIR"/inception;
				START=$(date +%s);
				"$INCEPTION" -d "$3" -v -provider wordlists/provider.json | tee "$WORKING_DIR"/inception/inception-output.txt;

				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE Inception took $DIFF seconds to run.""$NC";
		fi
}

function run_waybackurls() {
		# Call with domain as $1
		echo -e "$GREEN""[i]$BLUE Running waybackurls against $DOMAIN.""$NC";
		echo -e "$GREEN""[i]$BLUE Command: waybackurls $DOMAIN | tee $WORKING_DIR/waybackurls-output.txt""$NC";
		# Run waybackurls
		START=$(date +%s);
		"$WAYBACKURLS" "$DOMAIN" | tee "$WORKING_DIR"/waybackurls-output.txt;
		END=$(date +%s);
		DIFF=$(( END - START ));
		echo -e "$GREEN""[i]$BLUE Waybackurls took $DIFF seconds to run.""$NC";
}

function run_content_discovery() {
# Ask user to do directory bruteforcing on discovered domains
while true; do
  echo -e "$GREEN""[?] Do you want to begin content bruteforcing on [A]ll/[I]nteresting/[N]o discovered domains?";
  echo -e "$ORANGE""[i] This will run inception, waybackurls, ffuf, gobuster, and dirsearch.";
  read -rp "[?] Please enter A/a, I/i, or N/n. " ANSWER

  case $ANSWER in
   [aA]* ) 
		   echo -e "[i] Beginning directory bruteforcing on all discovered resolvable domains.";
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
								   run_inception "$DOMAIN" "$SMALL" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_waybackurls "$DOMAIN";
								   run_ffuf "$DOMAIN" "$SMALL" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_gobuster "$DOMAIN" "$SMALL" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_dirsearch "$DOMAIN" "$SMALL" "$WORKING_DIR"/"$ALL_RESOLVED";
								   break;
								   ;;
							[mM]* )
								   run_inception "$DOMAIN" "$MEDIUM" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_waybackurls "$DOMAIN";
								   run_ffuf "$DOMAIN" "$MEDIUM" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_gobuster "$DOMAIN" "$MEDIUM" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_dirsearch "$DOMAIN" "$MEDIUM" "$WORKING_DIR"/"$ALL_RESOLVED";
								   break;
								   ;;
							[lL]* )
								   run_inception "$DOMAIN" "$LARGE" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_waybackurls "$DOMAIN";
								   run_ffuf "$DOMAIN" "$LARGE" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_gobuster "$DOMAIN" "$LARGE" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_dirsearch "$DOMAIN" "$LARGE" "$WORKING_DIR"/"$ALL_RESOLVED";
								   break;
								   ;;
							[xX]* )
								   run_inception "$DOMAIN" "$XL" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_waybackurls "$DOMAIN";
								   run_ffuf "$DOMAIN" "$XL" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_gobuster "$DOMAIN" "$XL" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_dirsearch "$DOMAIN" "$XL" "$WORKING_DIR"/"$ALL_RESOLVED";
								   break;
								   ;;
							[2]* )
								   run_inception "$DOMAIN" "$XXL" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_waybackurls "$DOMAIN";
								   run_ffuf "$DOMAIN" "$XXL" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_gobuster "$DOMAIN" "$XXL" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_dirsearch "$DOMAIN" "$XXL" "$WORKING_DIR"/"$ALL_RESOLVED";
								   break;
								   ;;
							* )
									echo -e "$RED""Please enter S/M/L/X/2 .""$NC";
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
		   COUNT=$(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}');
		   if [[ "$COUNT" -lt 1 ]]; then
				   echo -e "$RED""[!] No interesting domains have been discovered.""$NC";
				   return;
		   fi
				   
		   echo -e "[i] Beginning directory bruteforcing on all interesting discovered domains.";
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
								   run_inception "$DOMAIN" "$SMALL" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_waybackurls "$DOMAIN";
								   run_ffuf "$DOMAIN" "$SMALL" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_gobuster "$DOMAIN" "$SMALL" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_dirsearch "$DOMAIN" "$SMALL" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   break;
								   ;;
							[mM]* )
								   run_inception "$DOMAIN" "$MEDIUM" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_waybackurls "$DOMAIN";
								   run_ffuf "$DOMAIN" "$MEDIUM" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_gobuster "$DOMAIN" "$MEDIUM" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_dirsearch "$DOMAIN" "$MEDIUM" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   break;
								   ;;
							[lL]* )
								   run_inception "$DOMAIN" "$LARGE" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_waybackurls "$DOMAIN";
								   run_ffuf "$DOMAIN" "$LARGE" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_gobuster "$DOMAIN" "$LARGE" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_dirsearch "$DOMAIN" "$LARGE" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   break;
								   ;;
							[xX]* )
								   run_inception "$DOMAIN" "$XL" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_waybackurls "$DOMAIN";
								   run_ffuf "$DOMAIN" "$XL" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_gobuster "$DOMAIN" "$XL" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_dirsearch "$DOMAIN" "$XL" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   break;
								   ;;
							[2]* )
								   run_inception "$DOMAIN" "$XXL" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_waybackurls "$DOMAIN";
								   run_ffuf "$DOMAIN" "$XXL" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_gobuster "$DOMAIN" "$XXL" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_dirsearch "$DOMAIN" "$XXL" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   break;
								   ;;
							* )
									echo -e "$RED""Please enter S/M/L/X/2 .""$NC";
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

function run_bfac() {
		# Call with domain list as $1
		if [[ $1 == $WORKING_DIR/$ALL_RESOLVED ]]; then
				echo -e "$GREEN""[i]$BLUE Running bfac against all $(wc -l "$1" | awk '{print $1}') unique discovered domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: bfac -u $DOMAIN -xsc 301,302,404 -t 30 -o $WORKING_DIR/bfac.""$NC";
				# Run bfac
				mkdir "$WORKING_DIR"/bfac;
				COUNT=$(wc -l "$1" | awk '{print $1}')
				START=$(date +%s);
				while read -r ADOMAIN; do
						$BFAC -u "$ADOMAIN" -xsc 301,302,404 -t 30 -o "$WORKING_DIR"/bfac/"$ADOMAIN";
						COUNT=$((COUNT - 1));
						if [[ "$COUNT" != 0 ]]; then
								echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
						fi
				done < "$1"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE bfac took $DIFF seconds to run.""$NC";
		else
				echo -e "$GREEN""[i]$BLUE Running bfac against all $(wc -l "$1" | awk '{print $1}') discovered interesting domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: bfac -u $DOMAIN -xsc 301,302,404 -t 30 -o $WORKING_DIR/bfac.""$NC";
				# Run bfac
				mkdir "$WORKING_DIR"/bfac;
				COUNT=$(wc -l "$1" | awk '{print $1}')
				START=$(date +%s);
				while read -r ADOMAIN; do
						$BFAC -u "$ADOMAIN" -xsc 301,302,404 -t 30 -o "$WORKING_DIR"/bfac/"$ADOMAIN";
						COUNT=$((COUNT - 1));
						if [[ "$COUNT" != 0 ]]; then
								echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
						fi
				done < "$1"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE bfac took $DIFF seconds to run.""$NC";
		fi
}

function run_nikto() {
		# Call with domain list as $1
		if [[ $1 == $WORKING_DIR/$ALL_RESOLVED ]]; then
				echo -e "$GREEN""[i]$BLUE Running nikto against all $(wc -l "$1" | awk '{print $1}') unique discovered domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: nikto -h $HTTP://$DOMAIN -Format html -output $WORKING_DIR/nikto.""$NC";
				# Run nikto
				COUNT=$(wc -l "$1" | awk '{print $1}')
				mkdir "$WORKING_DIR"/nikto;
				START=$(date +%s);
				while read -r ADOMAIN; do
						"$NIKTO" -h "$HTTP"://"$ADOMAIN" -Format html -output "$WORKING_DIR"/nikto/"$ADOMAIN".html;
						COUNT=$((COUNT - 1));
						if [[ "$COUNT" != 0 ]]; then
								echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
						fi
				done < "$1"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE Nikto took $DIFF seconds to run.""$NC";
		else
				echo -e "$GREEN""[i]$BLUE Running nikto against all $(wc -l "$1" | awk '{print $1}') discovered interesting domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: nikto -h $HTTP://$DOMAIN -Format html -output $WORKING_DIR/nikto.""$NC";
				# Run nikto
				COUNT=$(wc -l "$1" | awk '{print $1}')
				mkdir "$WORKING_DIR"/nikto;
				START=$(date +%s);
				while read -r ADOMAIN; do
						"$NIKTO" -h "$HTTP"://"$ADOMAIN" -Format html -output "$WORKING_DIR"/nikto/"$ADOMAIN".html;
						COUNT=$((COUNT - 1));
						if [[ "$COUNT" != 0 ]]; then
								echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
						fi
				done < "$1"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE Nikto took $DIFF seconds to run.""$NC";
		fi
}

function run_whatweb() {
		# Call with domain as $1 and domain list as $2
		if [[ $2 == $WORKING_DIR/$ALL_RESOLVED ]]; then
				echo -e "$GREEN""[i]$BLUE Running whatweb against all $(wc -l "$2" | awk '{print $1}') unique discovered domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: whatweb -v -a 3 -h $HTTP://$DOMAIN | tee $WORKING_DIR/whatweb.""$NC";
				# Run whatweb
				COUNT=$(wc -l "$2" | awk '{print $1}')
				mkdir "$WORKING_DIR"/whatweb;
				START=$(date +%s);
				while read -r ADOMAIN; do
						"$WHATWEB" -v -a 3 "$HTTP"://"$ADOMAIN" | tee "$WORKING_DIR"/whatweb/"$ADOMAIN";
						COUNT=$((COUNT - 1));
						if [[ "$COUNT" != 0 ]]; then
								echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
						fi
				done < "$2"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE whatweb took $DIFF seconds to run.""$NC";
		else
				echo -e "$GREEN""[i]$BLUE Running whatweb against all $(wc -l "$2" | awk '{print $1}') discovered interesting domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: whatweb -v -a 3 -h $HTTP://$DOMAIN | tee $WORKING_DIR/whatweb.""$NC";
				# Run whatweb
				COUNT=$(wc -l "$2" | awk '{print $1}')
				mkdir "$WORKING_DIR"/whatweb;
				START=$(date +%s);
				while read -r ADOMAIN; do
						"$WHATWEB" -v -a 3 "$HTTP"://"$ADOMAIN" | tee "$WORKING_DIR"/whatweb/"$ADOMAIN";
						COUNT=$((COUNT - 1));
						if [[ "$COUNT" != 0 ]]; then
								echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
						fi
				done < "$2"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE whatweb took $DIFF seconds to run.""$NC";
		fi
}

function run_wafw00f() {
		# Call with domain as $1 and domain list as $2
		if [[ $2 == $WORKING_DIR/$ALL_RESOLVED ]]; then
				echo -e "$GREEN""[i]$BLUE Running wafw00f against all $(wc -l "$2" | awk '{print $1}') unique discovered domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: wafw00f $HTTP://$1 -a | tee $WORKING_DIR/wafw00f.""$NC";
				# Run wafw00f
				COUNT=$(wc -l "$2" | awk '{print $1}')
				mkdir "$WORKING_DIR"/wafw00f;
				START=$(date +%s);
				while read -r ADOMAIN; do
						"$WAFW00F" "$HTTP"://"$ADOMAIN" -a | tee "$WORKING_DIR"/wafw00f/"$ADOMAIN";
						COUNT=$((COUNT - 1));
						if [[ "$COUNT" != 0 ]]; then
								echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
						fi
				done < "$2"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE wafw00f took $DIFF seconds to run.""$NC";
		else
				echo -e "$GREEN""[i]$BLUE Running wafw00f against all $(wc -l "$2" | awk '{print $1}') discovered interesting domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: wafw00f $HTTP://$1 -a | tee $WORKING_DIR/wafw00f.""$NC";
				# Run wafw00f
				COUNT=$(wc -l "$2" | awk '{print $1}')
				mkdir "$WORKING_DIR"/wafw00f;
				START=$(date +%s);
				while read -r ADOMAIN; do
						"$WAFW00F" "$HTTP"://"$ADOMAIN" -a | tee "$WORKING_DIR"/wafw00f/"$ADOMAIN";
						COUNT=$((COUNT - 1));
						if [[ "$COUNT" != 0 ]]; then
								echo -e "$GREEN""[i]$BLUE $COUNT domain(s) remaining.""$NC";
						fi
				done < "$2"
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE wafw00f took $DIFF seconds to run.""$NC";
		fi
}

function run_subjack() {
		# Call with domain as $1 and domain list as $2
		if [[ $2 == $WORKING_DIR/$ALL_RESOLVED ]]; then
				echo -e "$GREEN""[i]$BLUE Running subjack against all $(wc -l "$WORKING_DIR"/$ALL_RESOLVED | awk '{print $1}') unique discovered subdomains to check for subdomain takeover.""$NC";
				echo -e "$GREEN""[i]$ORANGE It will run twice, once against HTTPS and once against HTTP.""$NC";
				echo -e "$GREEN""[i]$ORANGE Command: subjack -d $1 -w $2 -v -t 20 -ssl -m -o $WORKING_DIR/subjack-output.txt""$NC";
				START=$(date +%s);
				"$SUBJACK" -d "$1" -w "$2" -v -t 20 -ssl -m -o "$WORKING_DIR"/subjack-https-output.txt -c "$HOME"/go/src/github.com/haccer/subjack/fingerprints.json;
				"$SUBJACK" -d "$1" -w "$2" -v -t 20 -m -o "$WORKING_DIR"/subjack-http-output.txt -c "$HOME"/go/src/github.com/haccer/subjack/fingerprints.json;
				END=$(date +%s);
				DIFF=$(( END - START ));
		else
				echo -e "$GREEN""[i]$BLUE Running subjack against all $(wc -l "$WORKING_DIR"/$ALL_RESOLVED | awk '{print $1}') discovered interesting subdomains to check for subdomain takeover.""$NC";
				echo -e "$GREEN""[i]$ORANGE It will run twice, once against HTTPS and once against HTTP.""$NC";
				echo -e "$GREEN""[i]$ORANGE Command: subjack -d $1 -w $2 -v -t 20 -ssl -m -o $WORKING_DIR/subjack-output.txt""$NC";
				START=$(date +%s);
				"$SUBJACK" -d "$1" -w "$2" -v -t 20 -ssl -m -o "$WORKING_DIR"/subjack-https-output.txt -c "$HOME"/go/src/github.com/haccer/subjack/fingerprints.json;
				"$SUBJACK" -d "$1" -w "$2" -v -t 20 -m -o "$WORKING_DIR"/subjack-http-output.txt -c "$HOME"/go/src/github.com/haccer/subjack/fingerprints.json;
				END=$(date +%s);
				DIFF=$(( END - START ));
		fi

		echo -e "$GREEN""[i]$BLUE Subjack took $DIFF seconds to run.""$NC";
		echo -e "$GREEN""[i]$ORANGE Full Subjack results are at $WORKING_DIR/subjack-output.txt.""$NC";
		sleep 1;
}

function run_corstest() {
		# Call with domain as $1 and domain list as $2
		if [[ $2 == $WORKING_DIR/$ALL_RESOLVED ]]; then
				echo -e "$GREEN""[i]$BLUE Running CORStest against all $(wc -l "$2" | awk '{print $1}') unique discovered domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: corstest.py $2 -v -p 64 | tee $WORKING_DIR/CORStest-output.txt.""$NC";
				# Run CORStest
				START=$(date +%s);
				"$CORSTEST" "$2" -v -p 64 | tee "$WORKING_DIR"/CORStest-output.txt;
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE CORStest took $DIFF seconds to run.""$NC";
		else
				echo -e "$GREEN""[i]$BLUE Running CORStest against all $(wc -l "$2" | awk '{print $1}') discovered interesting domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: corstest.py $2 -v -p 64 | tee $WORKING_DIR/CORStest-output.txt.""$NC";
				# Run CORStest
				START=$(date +%s);
				"$CORSTEST" "$2" -v -p 64 | tee "$WORKING_DIR"/CORStest-output.txt;
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE CORStest took $DIFF seconds to run.""$NC";
		fi
}

function run_s3scanner() {
		# Call with domain as $1 and domain list as $2
		if [[ $2 == $WORKING_DIR/$ALL_RESOLVED ]]; then
				echo -e "$GREEN""[i]$BLUE Running S3Scanner against all $(wc -l "$2" | awk '{print $1}') unique discovered domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: s3scanner.py ""$NC";
				# Run S3Scanner
				START=$(date +%s);
				python "$S3SCANNER" "$2" -d -l -o "$WORKING_DIR"/s3scanner-output.txt;
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE S3Scanner took $DIFF seconds to run.""$NC";
		else
				echo -e "$GREEN""[i]$BLUE Running S3Scanner against all $(wc -l "$2" | awk '{print $1}') discovered interesting domains.""$NC";
				echo -e "$GREEN""[i]$BLUE Command: s3scanner.py ""$NC";
				# Run S3Scanner
				START=$(date +%s);
				python "$S3SCANNER" "$2" -d -l -o "$WORKING_DIR"/s3scanner-output.txt;
				END=$(date +%s);
				DIFF=$(( END - START ));
				echo -e "$GREEN""[i]$BLUE S3Scanner took $DIFF seconds to run.""$NC";
		fi
}

function run_information_gathering() {
# Ask user to do information gathering on discovered domains
while true; do
  echo -e "$GREEN""[?] Do you want to begin information gathering on [A]ll/[I]nteresting/[N]o discovered domains?";
  echo -e "$ORANGE""[i] This will run subjack, CORStest, S3Scanner, bfac, whatweb, wafw00f, and nikto.";
  read -rp "[?] Please enter A/a, I/i, or N/n. " ANSWER

  case $ANSWER in
   [aA]* ) 
		   echo -e "[i] Beginning information gathering on all discovered domains.";
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
								   run_subjack "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_corstest "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_s3scanner "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_bfac "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_whatweb "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_wafw00f "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_nikto "$WORKING_DIR"/"$ALL_RESOLVED";
								   break;
								   ;;
							[mM]* )
								   run_subjack "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_corstest "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_s3scanner "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_bfac "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_whatweb "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_wafw00f "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_nikto "$WORKING_DIR"/"$ALL_RESOLVED";
								   break;
								   ;;
							[lL]* )
								   run_subjack "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_corstest "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_s3scanner "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_bfac "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_whatweb "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_wafw00f "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_nikto "$WORKING_DIR"/"$ALL_RESOLVED";
								   break;
								   ;;
							[xX]* )
								   run_subjack "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_corstest "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_s3scanner "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_bfac "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_whatweb "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_wafw00f "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_nikto "$WORKING_DIR"/"$ALL_RESOLVED";
								   break;
								   ;;
							[2]* )
								   run_subjack "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_corstest "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_s3scanner "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_bfac "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_whatweb "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_wafw00f "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								   run_nikto "$WORKING_DIR"/"$ALL_RESOLVED";
								   break;
								   ;;
							* )
									echo -e "$RED""Please enter S/M/L/X/2. ""$NC";
									;;
				   esac
		   done
		   break;
		   ;;
   [nN]* ) 
		   echo -e "$RED""[!] Skipping information gathering on all domains.""$NC";
		   return;
		   ;;
   [iI]* ) 
		   # Check if any interesting domains have been found.'
		   COUNT=$(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}');
		   if [[ "$COUNT" -lt 1 ]]; then
				   echo -e "$RED""[!] No interesting domains have been discovered.""$NC";
				   return;
		   fi
				   
		   echo -e "[i] Beginning information gathering on all interesting discovered domains.";
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
								   run_subjack "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_corstest "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_s3scanner "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_bfac "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_whatweb "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_wafw00f "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_nikto "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   break;
								   ;;
							[mM]* )
								   run_subjack "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_corstest "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_s3scanner "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_bfac "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_whatweb "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_wafw00f "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_nikto "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   break;
								   ;;
							[lL]* )
								   run_subjack "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_corstest "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_s3scanner "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_bfac "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_whatweb "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_wafw00f "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_nikto "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   break;
								   ;;
							[xX]* )
								   run_subjack "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_corstest "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_s3scanner "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_bfac "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_whatweb "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_wafw00f "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_nikto "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   break;
								   ;;
							[2]* )
								   run_subjack "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_corstest "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_s3scanner "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_bfac "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_whatweb "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_wafw00f "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   run_nikto "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								   break;
								   ;;
							* )
									echo -e "$RED""Please enter S/M/L/X/2. ""$NC";
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

function run_notica() {
		# Call Notica to signal end of script, $1 is for the domain
		echo -e "$BLUE""Sending Notica notification.""$NC";
		curl --data "d:Chomp Scan has finished scanning $1." "https://notica.us/?$NOTICA";
}

function run_notica_sudo() {
		# Call Notica to alert that sudo is needed for masscan
		echo -e "$ORANGE""Sending Notica notification that sudo is needed.""$NC";
		curl --data "d:Chomp Scan Notification: Your sudo password is needed for masscan." "https://notica.us/?$NOTICA";
}

function run_rescope() {
		echo -e "$BLUE""[i] Creating a Burp scope file with rescope.""$NC";
		
		# Make sure resolved domains exists
		if [[ $(wc -l "$WORKING_DIR"/"$ALL_RESOLVED" | awk '{print $1}') -gt 0 ]]; then
				"$RESCOPE" --burp -i "$WORKING_DIR"/"$ALL_RESOLVED" -o "$WORKING_DIR"/burp-scope.json -s;
		fi
}

#### Begin main script functions

# Check tool paths are set
check_paths;

# Check for config file and run options if it exists
if [[ "$CONFIG_FILE" != "" ]]; then
		echo -e "$GREEN""Beginning scan with config file options.""$NC";
		sleep 0.5;
		if [[ "${#DOMAIN_ARRAY[@]}" -gt 1 ]]; then
				for ARRAY_DOMAIN in "${DOMAIN_ARRAY[@]}"; do
						# Create output dirs here
						if [[ "$CUSTOM_WORKING_DIR" == "" ]]; then
								WORKING_DIR="$ARRAY_DOMAIN"-$(date +%T);
								mkdir "$WORKING_DIR";
								touch "$WORKING_DIR"/interesting-domains.txt;
								INTERESTING_DOMAINS=interesting-domains.txt;
								touch "$WORKING_DIR"/"$ALL_DOMAIN";
								touch "$WORKING_DIR"/"$ALL_IP";
								touch "$WORKING_DIR"/"$ALL_RESOLVED";
						else
								WORKING_DIR="$CUSTOM_WORKING_DIR"/"$ARRAY_DOMAIN"-$(date +%T);
								mkdir -p "$WORKING_DIR";
								touch "$WORKING_DIR"/interesting-domains.txt;
								INTERESTING_DOMAINS=interesting-domains.txt;
								touch "$WORKING_DIR"/"$ALL_DOMAIN";
								touch "$WORKING_DIR"/"$ALL_IP";
								touch "$WORKING_DIR"/"$ALL_RESOLVED";
						fi
						SCAN_START=$(date +%s);
						echo "$ARRAY_DOMAIN";
						## Subdomain enumeration
						# Run dnscan
						if [[ "$ENABLE_DNSCAN" -eq 1 ]]; then
								# Check if $SUBDOMAIN_WORDLIST is set, else use short as default
								if [[ "$SUBDOMAIN_WORDLIST" != "" ]]; then
										run_dnscan "$ARRAY_DOMAIN" "$SUBDOMAIN_WORDLIST";
								else
										run_dnscan "$ARRAY_DOMAIN" "$SHORT";
								fi
						fi

						# Run subfinder
						if [[ "$ENABLE_SUBFINDER" -eq 1 ]]; then
								# Check if $SUBDOMAIN_WORDLIST is set, else use short as default
								if [[ "$SUBDOMAIN_WORDLIST" != "" ]]; then
										run_subfinder "$ARRAY_DOMAIN" "$SUBDOMAIN_WORDLIST";
								else
										run_subfinder "$ARRAY_DOMAIN" "$SHORT";
								fi
						fi

						# Run sublist3r
						if [[ "$ENABLE_SUBLIST3R" -eq 1 ]]; then
								run_sublist3r "$ARRAY_DOMAIN";
						fi

						# Run knock
						if [[ "$ENABLE_KNOCK" -eq 1 ]]; then
								# Check if $SUBDOMAIN_WORDLIST is set, else use short as default
								if [[ "$SUBDOMAIN_WORDLIST" != "" ]]; then
										run_knock "$ARRAY_DOMAIN" "$SUBDOMAIN_WORDLIST";
								else
										run_knock "$ARRAY_DOMAIN" "$SHORT";
								fi
						fi

						# Run amass
						if [[ "$ENABLE_AMASS" -eq 1 ]]; then
								# Check if $SUBDOMAIN_WORDLIST is set, else use short as default
								if [[ "$SUBDOMAIN_WORDLIST" != "" ]]; then
										run_amass "$ARRAY_DOMAIN" "$SUBDOMAIN_WORDLIST";
								else
										run_amass "$ARRAY_DOMAIN" "$SHORT";
								fi
						fi

						# Run masscan and/or goaltdns
						if [[ "$ENABLE_MASSDNS" -eq 1 ]]; then # Masscan will always run in order to get resolved domains
								if [[ "$ENABLE_GOALTDNS" -eq 1 ]]; then
										# Check if $SUBDOMAIN_WORDLIST is set, else use short as default
										if [[ "$SUBDOMAIN_WORDLIST" != "" ]]; then
												run_massdns "$ARRAY_DOMAIN" "$SUBDOMAIN_WORDLIST";
										else
												run_massdns "$ARRAY_DOMAIN" "$SHORT";
										fi
								else
										# Check if $SUBDOMAIN_WORDLIST is set, else use short as default
										if [[ "$SUBDOMAIN_WORDLIST" != "" ]]; then
												run_massdns "$ARRAY_DOMAIN" "$SUBDOMAIN_WORDLIST" "alone";
										else
												run_massdns "$ARRAY_DOMAIN" "$SHORT" "alone";
										fi
								fi
						fi

						get_interesting "silent";

						## Screenshots
						# Run aquatone
						if [[ "$ENABLE_SCREENSHOTS" -eq 1 ]]; then
								run_aquatone "default";
						fi

						## Information gathering
						# Run subjack
						if [[ "$ENABLE_SUBJACK" -eq 1 ]]; then
								if [[ "$USE_ALL" -eq 1 ]]; then
										run_subjack "$ARRAY_DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								# Make sure there are interesting domains
								elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') -gt 0 ]]; then
										run_subjack "$ARRAY_DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								else
										run_subjack "$ARRAY_DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								fi
						fi

						# Run CORStest
						if [[ "$ENABLE_CORSTEST" -eq 1 ]]; then
								if [[ "$USE_ALL" -eq 1 ]]; then
										run_corstest "$ARRAY_DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								# Make sure there are interesting domains
								elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') -gt 0 ]]; then
										run_corstest "$ARRAY_DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								else
										run_corstest "$ARRAY_DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								fi
						fi

						# Run S3Scanner
						if [[ "$ENABLE_S3SCANNER" -eq 1 ]]; then
								if [[ "$USE_ALL" -eq 1 ]]; then
										run_s3scanner "$ARRAY_DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								# Make sure there are interesting domains
								elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') -gt 0 ]]; then
										run_s3scanner "$ARRAY_DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								else
										run_s3scanner "$ARRAY_DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								fi
						fi

						# Run bfac
						if [[ "$ENABLE_BFAC" -eq 1 ]]; then
								if [[ "$USE_ALL" -eq 1 ]]; then
										run_bfac "$WORKING_DIR"/"$ALL_RESOLVED";
								# Make sure there are interesting domains
								elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') -gt 0 ]]; then
										run_bfac "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								else
										run_bfac "$WORKING_DIR"/"$ALL_RESOLVED";
								fi
						fi

						# Run whatweb
						if [[ "$ENABLE_WHATWEB" -eq 1 ]]; then
								if [[ "$USE_ALL" -eq 1 ]]; then
										run_whatweb "$ARRAY_DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								# Make sure there are interesting domains
								elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') -gt 0 ]]; then
										run_whatweb "$ARRAY_DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								else
										run_whatweb "$ARRAY_DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								fi
						fi

						# Run wafw00f
						if [[ "$ENABLE_WAFW00F" -eq 1 ]]; then
								if [[ "$USE_ALL" -eq 1 ]]; then
										run_wafw00f "$ARRAY_DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								# Make sure there are interesting domains
								elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') -gt 0 ]]; then
										run_wafw00f "$ARRAY_DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								else
										run_wafw00f "$ARRAY_DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
								fi
						fi

						# Run nikto
						if [[ "$ENABLE_NIKTO" -eq 1 ]]; then
								if [[ "$USE_ALL" -eq 1 ]]; then
										run_nikto "$WORKING_DIR"/"$ALL_RESOLVED";
								# Make sure there are interesting domains
								elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') -gt 0 ]]; then
										run_nikto "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								else
										run_nikto "$WORKING_DIR"/"$ALL_RESOLVED";
								fi
						fi

						## Content discovery
						# Run inception
						if [[ "$ENABLE_INCEPTION" -eq 1 ]]; then
								# Check if $SUBDOMAIN_WORDLIST is set, else use short as default
								if [[ "$CONTENT_WORDLIST" != "" ]]; then
										if [[ "$USE_ALL" -eq 1 ]]; then
												run_inception "$ARRAY_DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$ALL_RESOLVED";
										# Make sure there are interesting domains
										elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') -gt 0 ]]; then
												run_inception "$ARRAY_DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
										else
												run_inception "$ARRAY_DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$ALL_RESOLVED";
										fi
								else
										if [[ "$USE_ALL" -eq 1 ]]; then
												run_inception "$ARRAY_DOMAIN" "$SHORT" "$WORKING_DIR"/"$ALL_RESOLVED";
										# Make sure there are interesting domains
										elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') != 0 ]]; then
												run_inception "$ARRAY_DOMAIN" "$SHORT" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
										else
												run_inception "$ARRAY_DOMAIN" "$SHORT" "$WORKING_DIR"/"$ALL_RESOLVED";
										fi
								fi
						fi

						# Run waybackurls
						if [[ "$ENABLE_WAYBACKURLS" -eq 1 ]]; then
								run_waybackurls "$ARRAY_DOMAIN";
						fi

						# Run ffuf
						if [[ "$ENABLE_FFUF" -eq 1 ]]; then
								# Check if $SUBDOMAIN_WORDLIST is set, else use short as default
								if [[ "$CONTENT_WORDLIST" != "" ]]; then
										if [[ "$USE_ALL" -eq 1 ]]; then
												run_ffuf "$ARRAY_DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$ALL_RESOLVED";
										# Make sure there are interesting domains
										elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') -gt 0 ]]; then
												run_ffuf "$ARRAY_DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
										else
												run_ffuf "$ARRAY_DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$ALL_RESOLVED";
										fi
								else
										if [[ "$USE_ALL" -eq 1 ]]; then
												run_ffuf "$ARRAY_DOMAIN" "$SHORT" "$WORKING_DIR"/"$ALL_RESOLVED";
										# Make sure there are interesting domains
										elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') != 0 ]]; then
												run_ffuf "$ARRAY_DOMAIN" "$SHORT" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
										else
												run_ffuf "$ARRAY_DOMAIN" "$SHORT" "$WORKING_DIR"/"$ALL_RESOLVED";
										fi
								fi
						fi

						# Run gobuster
						if [[ "$ENABLE_GOBUSTER" -eq 1 ]]; then
								# Check if $SUBDOMAIN_WORDLIST is set, else use short as default
								if [[ "$CONTENT_WORDLIST" != "" ]]; then
										if [[ "$USE_ALL" -eq 1 ]]; then
												run_gobuster "$ARRAY_DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$ALL_RESOLVED";
										# Make sure there are interesting domains
										elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') -gt 0 ]]; then
												run_gobuster "$ARRAY_DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
										else
												run_gobuster "$ARRAY_DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$ALL_RESOLVED";
										fi
								else
										if [[ "$USE_ALL" -eq 1 ]]; then
												run_gobuster "$ARRAY_DOMAIN" "$SHORT" "$WORKING_DIR"/"$ALL_RESOLVED";
										# Make sure there are interesting domains
										elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') != 0 ]]; then
												run_gobuster "$ARRAY_DOMAIN" "$SHORT" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
										else
												run_gobuster "$ARRAY_DOMAIN" "$SHORT" "$WORKING_DIR"/"$ALL_RESOLVED";
										fi
								fi
						fi

						# Run dirsearch
						if [[ "$ENABLE_DIRSEARCH" -eq 1 ]]; then
								# Check if $SUBDOMAIN_WORDLIST is set, else use short as default
								if [[ "$CONTENT_WORDLIST" != "" ]]; then
										if [[ "$USE_ALL" -eq 1 ]]; then
												run_dirsearch "$ARRAY_DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$ALL_RESOLVED";
										# Make sure there are interesting domains
										elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') -gt 0 ]]; then
												run_dirsearch "$ARRAY_DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
										else
												run_dirsearch "$ARRAY_DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$ALL_RESOLVED";
										fi
								else
										if [[ "$USE_ALL" -eq 1 ]]; then
												run_dirsearch "$ARRAY_DOMAIN" "$SHORT" "$WORKING_DIR"/"$ALL_RESOLVED";
										# Make sure there are interesting domains
										elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') != 0 ]]; then
												run_dirsearch "$ARRAY_DOMAIN" "$SHORT" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
										else
												run_dirsearch "$ARRAY_DOMAIN" "$SHORT" "$WORKING_DIR"/"$ALL_RESOLVED";
										fi
								fi
						fi

						## Port scanning
						# Run masscan
						if [[ "$ENABLE_MASSCAN" -eq 1 ]]; then
								run_masscan;
						fi

						# Run nmap
						if [[ "$ENABLE_NMAP" -eq 1 ]]; then
								run_nmap;
						fi

						get_interesting;
						list_found;

						# Run rescope
						if [[ "$ENABLE_RESCOPE" -eq 1 ]]; then
								run_rescope;
						fi

						# Calculate scan runtime
						SCAN_END=$(date +%s);
						SCAN_DIFF=$(( SCAN_END - SCAN_START ));
						if [[ "$NOTICA" != "" ]]; then
								run_notica "$ARRAY_DOMAIN";
						fi
						echo -e "$BLUE""[i] Total script run time: $SCAN_DIFF seconds.""$NC";
						WORKING_DIR="";
				done
				exit 0;
		else
				# Create output dir normally here
				## Subdomain enumeration
				# Run dnscan
				if [[ "$ENABLE_DNSCAN" -eq 1 ]]; then
						# Check if $SUBDOMAIN_WORDLIST is set, else use short as default
						if [[ "$SUBDOMAIN_WORDLIST" != "" ]]; then
								run_dnscan "$DOMAIN" "$SUBDOMAIN_WORDLIST";
						else
								run_dnscan "$DOMAIN" "$SHORT";
						fi
				fi

				# Run subfinder
				if [[ "$ENABLE_SUBFINDER" -eq 1 ]]; then
						# Check if $SUBDOMAIN_WORDLIST is set, else use short as default
						if [[ "$SUBDOMAIN_WORDLIST" != "" ]]; then
								run_subfinder "$DOMAIN" "$SUBDOMAIN_WORDLIST";
						else
								run_subfinder "$DOMAIN" "$SHORT";
						fi
				fi

				# Run sublist3r
				if [[ "$ENABLE_SUBLIST3R" -eq 1 ]]; then
						run_sublist3r "$DOMAIN";
				fi

				# Run knock
				if [[ "$ENABLE_KNOCK" -eq 1 ]]; then
						# Check if $SUBDOMAIN_WORDLIST is set, else use short as default
						if [[ "$SUBDOMAIN_WORDLIST" != "" ]]; then
								run_knock "$DOMAIN" "$SUBDOMAIN_WORDLIST";
						else
								run_knock "$DOMAIN" "$SHORT";
						fi
				fi

				# Run amass
				if [[ "$ENABLE_AMASS" -eq 1 ]]; then
						# Check if $SUBDOMAIN_WORDLIST is set, else use short as default
						if [[ "$SUBDOMAIN_WORDLIST" != "" ]]; then
								run_amass "$DOMAIN" "$SUBDOMAIN_WORDLIST";
						else
								run_amass "$DOMAIN" "$SHORT";
						fi
				fi

				# Run masscan and/or goaltdns
				if [[ "$ENABLE_MASSDNS" -eq 1 ]]; then # Masscan will always run in order to get resolved domains
						if [[ "$ENABLE_GOALTDNS" -eq 1 ]]; then
								# Check if $SUBDOMAIN_WORDLIST is set, else use short as default
								if [[ "$SUBDOMAIN_WORDLIST" != "" ]]; then
										run_massdns "$DOMAIN" "$SUBDOMAIN_WORDLIST";
								else
										run_massdns "$DOMAIN" "$SHORT";
								fi
						else
								# Check if $SUBDOMAIN_WORDLIST is set, else use short as default
								if [[ "$SUBDOMAIN_WORDLIST" != "" ]]; then
										run_massdns "$DOMAIN" "$SUBDOMAIN_WORDLIST" "alone";
								else
										run_massdns "$DOMAIN" "$SHORT" "alone";
								fi
						fi
				fi

				get_interesting "silent";

				## Screenshots
				# Run aquatone
				if [[ "$ENABLE_SCREENSHOTS" -eq 1 ]]; then
						run_aquatone "default";
				fi

				## Information gathering
				# Run subjack
				if [[ "$ENABLE_SUBJACK" -eq 1 ]]; then
						if [[ "$USE_ALL" -eq 1 ]]; then
								run_subjack "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
						# Make sure there are interesting domains
						elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') -gt 0 ]]; then
								run_subjack "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
						else
								run_subjack "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
						fi
				fi

				# Run CORStest
				if [[ "$ENABLE_CORSTEST" -eq 1 ]]; then
						if [[ "$USE_ALL" -eq 1 ]]; then
								run_corstest "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
						# Make sure there are interesting domains
						elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') -gt 0 ]]; then
								run_corstest "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
						else
								run_corstest "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
						fi
				fi

				# Run S3Scanner
				if [[ "$ENABLE_S3SCANNER" -eq 1 ]]; then
						if [[ "$USE_ALL" -eq 1 ]]; then
								run_s3scanner "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
						# Make sure there are interesting domains
						elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') -gt 0 ]]; then
								run_s3scanner "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
						else
								run_s3scanner "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
						fi
				fi

				# Run bfac
				if [[ "$ENABLE_BFAC" -eq 1 ]]; then
						if [[ "$USE_ALL" -eq 1 ]]; then
								run_bfac "$WORKING_DIR"/"$ALL_RESOLVED";
						# Make sure there are interesting domains
						elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') -gt 0 ]]; then
								run_bfac "$WORKING_DIR"/"$INTERESTING_DOMAINS";
						else
								run_bfac "$WORKING_DIR"/"$ALL_RESOLVED";
						fi
				fi

				# Run whatweb
				if [[ "$ENABLE_WHATWEB" -eq 1 ]]; then
						if [[ "$USE_ALL" -eq 1 ]]; then
								run_whatweb "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
						# Make sure there are interesting domains
						elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') -gt 0 ]]; then
								run_whatweb "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
						else
								run_whatweb "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
						fi
				fi

				# Run wafw00f
				if [[ "$ENABLE_WAFW00F" -eq 1 ]]; then
						if [[ "$USE_ALL" -eq 1 ]]; then
								run_wafw00f "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
						# Make sure there are interesting domains
						elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') -gt 0 ]]; then
								run_wafw00f "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
						else
								run_wafw00f "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
						fi
				fi

				# Run nikto
				if [[ "$ENABLE_NIKTO" -eq 1 ]]; then
						if [[ "$USE_ALL" -eq 1 ]]; then
								run_nikto "$WORKING_DIR"/"$ALL_RESOLVED";
						# Make sure there are interesting domains
						elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') -gt 0 ]]; then
								run_nikto "$WORKING_DIR"/"$INTERESTING_DOMAINS";
						else
								run_nikto "$WORKING_DIR"/"$ALL_RESOLVED";
						fi
				fi

				## Content discovery
				# Run inception
				if [[ "$ENABLE_INCEPTION" -eq 1 ]]; then
						# Check if $SUBDOMAIN_WORDLIST is set, else use short as default
						if [[ "$CONTENT_WORDLIST" != "" ]]; then
								if [[ "$USE_ALL" -eq 1 ]]; then
										run_inception "$DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$ALL_RESOLVED";
								# Make sure there are interesting domains
								elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') -gt 0 ]]; then
										run_inception "$DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								else
										run_inception "$DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$ALL_RESOLVED";
								fi
						else
								if [[ "$USE_ALL" -eq 1 ]]; then
										run_inception "$DOMAIN" "$SHORT" "$WORKING_DIR"/"$ALL_RESOLVED";
								# Make sure there are interesting domains
								elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') != 0 ]]; then
										run_inception "$DOMAIN" "$SHORT" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								else
										run_inception "$DOMAIN" "$SHORT" "$WORKING_DIR"/"$ALL_RESOLVED";
								fi
						fi
				fi

				# Run waybackurls
				if [[ "$ENABLE_WAYBACKURLS" -eq 1 ]]; then
						run_waybackurls "$DOMAIN";
				fi

				# Run ffuf
				if [[ "$ENABLE_FFUF" -eq 1 ]]; then
						# Check if $SUBDOMAIN_WORDLIST is set, else use short as default
						if [[ "$CONTENT_WORDLIST" != "" ]]; then
								if [[ "$USE_ALL" -eq 1 ]]; then
										run_ffuf "$DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$ALL_RESOLVED";
								# Make sure there are interesting domains
								elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') -gt 0 ]]; then
										run_ffuf "$DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								else
										run_ffuf "$DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$ALL_RESOLVED";
								fi
						else
								if [[ "$USE_ALL" -eq 1 ]]; then
										run_ffuf "$DOMAIN" "$SHORT" "$WORKING_DIR"/"$ALL_RESOLVED";
								# Make sure there are interesting domains
								elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') != 0 ]]; then
										run_ffuf "$DOMAIN" "$SHORT" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								else
										run_ffuf "$DOMAIN" "$SHORT" "$WORKING_DIR"/"$ALL_RESOLVED";
								fi
						fi
				fi

				# Run gobuster
				if [[ "$ENABLE_GOBUSTER" -eq 1 ]]; then
						# Check if $SUBDOMAIN_WORDLIST is set, else use short as default
						if [[ "$CONTENT_WORDLIST" != "" ]]; then
								if [[ "$USE_ALL" -eq 1 ]]; then
										run_gobuster "$DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$ALL_RESOLVED";
								# Make sure there are interesting domains
								elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') -gt 0 ]]; then
										run_gobuster "$DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								else
										run_gobuster "$DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$ALL_RESOLVED";
								fi
						else
								if [[ "$USE_ALL" -eq 1 ]]; then
										run_gobuster "$DOMAIN" "$SHORT" "$WORKING_DIR"/"$ALL_RESOLVED";
								# Make sure there are interesting domains
								elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') != 0 ]]; then
										run_gobuster "$DOMAIN" "$SHORT" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								else
										run_gobuster "$DOMAIN" "$SHORT" "$WORKING_DIR"/"$ALL_RESOLVED";
								fi
						fi
				fi

				# Run dirsearch
				if [[ "$ENABLE_DIRSEARCH" -eq 1 ]]; then
						# Check if $SUBDOMAIN_WORDLIST is set, else use short as default
						if [[ "$CONTENT_WORDLIST" != "" ]]; then
								if [[ "$USE_ALL" -eq 1 ]]; then
										run_dirsearch "$DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$ALL_RESOLVED";
								# Make sure there are interesting domains
								elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') -gt 0 ]]; then
										run_dirsearch "$DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								else
										run_dirsearch "$DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$ALL_RESOLVED";
								fi
						else
								if [[ "$USE_ALL" -eq 1 ]]; then
										run_dirsearch "$DOMAIN" "$SHORT" "$WORKING_DIR"/"$ALL_RESOLVED";
								# Make sure there are interesting domains
								elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') != 0 ]]; then
										run_dirsearch "$DOMAIN" "$SHORT" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
								else
										run_dirsearch "$DOMAIN" "$SHORT" "$WORKING_DIR"/"$ALL_RESOLVED";
								fi
						fi
				fi

				## Port scanning
				# Run masscan
				if [[ "$ENABLE_MASSCAN" -eq 1 ]]; then
						run_masscan;
				fi

				# Run nmap
				if [[ "$ENABLE_NMAP" -eq 1 ]]; then
						run_nmap;
				fi

				get_interesting;
				list_found;

				# Run rescope
				if [[ "$ENABLE_RESCOPE" -eq 1 ]]; then
						run_rescope;
				fi

				# Calculate scan runtime
				SCAN_END=$(date +%s);
				SCAN_DIFF=$(( SCAN_END - SCAN_START ));
				if [[ "$NOTICA" != "" ]]; then
						run_notica "$DOMAIN";
				fi
				echo -e "$BLUE""[i] Total script run time: $SCAN_DIFF seconds.""$NC";
				exit 0;
		fi
fi

# Check if -u domain was passed
if [[ "$DOMAIN" == "" ]]; then
		echo -e "$RED""[!] A domain is required: -u example.com""$NC";
		usage;
		exit 1;
fi

# Check for mutually exclusive interactive and non-interactive modes
if [[ "$INTERACTIVE" -eq 1 ]] && [[ "$DEFAULT_MODE" -eq 1 ]]; then
		echo -e "$RED""[!] Both interactive mode (-I) and non-interactive mode (-D) cannot be run together. Exiting.""$NC";
		usage;
		exit 1;
fi

# Create working directory, start script timer, and create interesting domains text file
# Check if -o output directory is already set
if [[ "$CUSTOM_WORKING_DIR" == "" ]]; then
		WORKING_DIR="$DOMAIN"-$(date +%T);
		mkdir "$WORKING_DIR";
else
		WORKING_DIR=$CUSTOM_WORKING_DIR;
fi

SCAN_START=$(date +%s);
touch "$WORKING_DIR"/interesting-domains.txt;
INTERESTING_DOMAINS=interesting-domains.txt;
touch "$WORKING_DIR"/"$ALL_DOMAIN";
touch "$WORKING_DIR"/"$ALL_IP";
touch "$WORKING_DIR"/"$ALL_RESOLVED";

# Check for -D non-interactive default flag
# Defaults for non-interactive:
# Subdomain wordlist size: short
# Content discovery wordlist size: small
# Aquatone: yes
# Portscan: masscan and nmap
# Content discovery: ffuf, gobuster, and dirsearch
# Information gathering: all tools
# Domains to scan: all unique resolvable
if [[ "$DEFAULT_MODE" -eq 1 ]]; then
		# Check if we're root since we're running masscan
		check_root;

		# Run all phases with defaults
		echo -e "$GREEN""Beginning non-interactive mode scan.""$NC";
		sleep 0.5;

		run_dnscan "$DOMAIN" "$SHORT";
		run_subfinder "$DOMAIN" "$SHORT";
		run_sublist3r "$DOMAIN";
		run_knock "$DOMAIN" "$SHORT";
		run_amass "$DOMAIN" "$SHORT";
		run_massdns "$DOMAIN" "$SHORT";

		# Call unique to make sure list is up to date for content discovery
		unique;

		run_aquatone "default";
		run_masscan;
		run_nmap;
		run_subjack "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
		run_corstest "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
		run_s3scanner "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
		run_bfac "$WORKING_DIR"/"$ALL_RESOLVED";
		run_nikto "$WORKING_DIR"/"$ALL_RESOLVED";
		run_whatweb "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
		run_wafw00f "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
		run_inception "$DOMAIN" "$SMALL" "$WORKING_DIR"/"$ALL_RESOLVED";
		run_waybackurls "$DOMAIN";
		run_ffuf "$DOMAIN" "$SMALL" "$WORKING_DIR"/"$ALL_RESOLVED";
		run_gobuster "$DOMAIN" "$SMALL" "$WORKING_DIR"/"$ALL_RESOLVED";
		run_dirsearch "$DOMAIN" "$SMALL" "$WORKING_DIR"/"$ALL_RESOLVED";
		get_interesting;
		list_found;
		run_rescope;

		# Calculate scan runtime
		SCAN_END=$(date +%s);
		SCAN_DIFF=$(( SCAN_END - SCAN_START ));
		if [[ "$NOTICA" != "" ]]; then
				run_notica "$DOMAIN";
		fi
		echo -e "$BLUE""[i] Total script run time: $SCAN_DIFF seconds.""$NC";
		
		exit;
fi

# Run in interactive mode, ignoring other parameters
if [[ "$INTERACTIVE" -eq 1 ]]; then
		# Check if we're root since we're running masscan
		check_root;

		# Run phases interactively
		echo -e "$GREEN""Beginning interactive mode scan.""$NC";
		sleep 0.5;

		run_subdomain_brute;

		# Call unique to make sure list is up to date for content discovery
		unique;

		run_aquatone;
		get_interesting;
		run_portscan;
		run_information_gathering;
		run_content_discovery;
		get_interesting;
		list_found;
		run_rescope;

		# Calculate scan runtime
		SCAN_END=$(date +%s);
		SCAN_DIFF=$(( SCAN_END - SCAN_START ));
		if [[ "$NOTICA" != "" ]]; then
				run_notica "$DOMAIN";
		fi
		echo -e "$BLUE""[i] Total script run time: $SCAN_DIFF seconds.""$NC";
		
		exit;
fi

# Preemptively check for -p portscanning
if [[ "$PORTSCANNING" -eq 1 ]]; then
		# Check if we're root since we're running masscan
		check_root;
fi

# Always run subdomain bruteforce tools
if [[ "$SUBDOMAIN_BRUTE" -eq 1 ]]; then
		echo -e "$BLUE""[i] Beginning subdomain enumeration dnscan, subfinder, sublist3r, knockpy, amass, and massdns+goaltdns.""$NC";
		sleep 0.5;

		# Check if $SUBDOMAIN_WORDLIST is set, else use short as default
		if [[ "$SUBDOMAIN_WORDLIST" != "" ]]; then
				run_dnscan "$DOMAIN" "$SUBDOMAIN_WORDLIST";
				run_subfinder "$DOMAIN" "$SUBDOMAIN_WORDLIST";
				run_sublist3r "$DOMAIN";
				run_knock "$DOMAIN" "$SUBDOMAIN_WORDLIST";
				run_amass "$DOMAIN" "$SUBDOMAIN_WORDLIST";
				run_massdns "$DOMAIN" "$SUBDOMAIN_WORDLIST";
		else
				run_dnscan "$DOMAIN" "$SHORT";
				run_subfinder "$DOMAIN" "$SHORT";
				run_sublist3r "$DOMAIN";
				run_knock "$DOMAIN" "$SHORT";
				run_amass "$DOMAIN" "$SHORT";
				run_massdns "$DOMAIN" "$SHORT";
		fi
fi

get_interesting "silent";

# -s screenshot with aquatone
if [[ "$SCREENSHOTS" -eq 1 ]]; then
		echo -e "$BLUE""[i] Taking screenshots with aquatone.""$NC";
		sleep 0.5;

		# Call unique to make sure list is up to date for content discovery
		unique;

		run_aquatone "default";
fi

# -i information gathering
if [[ "$INFO_GATHERING" -eq 1 ]]; then
		echo -e "$BLUE""[i] Beginning information gathering with subjack, CORStest, S3Scanner, bfac, whatweb, wafw00f, and nikto.""$NC";
		sleep 0.5;

		# Call unique to make sure list is up to date for content discovery
		unique;

		if [[ "$USE_ALL" -eq 1 ]]; then
				run_subjack "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
				run_corstest "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
				run_s3scanner "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
				run_bfac "$WORKING_DIR"/"$ALL_RESOLVED";
				run_whatweb "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
				run_wafw00f "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
				run_nikto "$WORKING_DIR"/"$ALL_RESOLVED";
		# Make sure there are interesting domains
		elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') -gt 0 ]]; then
				run_subjack "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
				run_corstest "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
				run_s3scanner "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
				run_bfac "$WORKING_DIR"/"$INTERESTING_DOMAINS";
				run_whatweb "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
				run_wafw00f "$DOMAIN" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
				run_nikto "$WORKING_DIR"/"$INTERESTING_DOMAINS";
		else
				run_subjack "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
				run_corstest "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
				run_s3scanner "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
				run_bfac "$WORKING_DIR"/"$ALL_RESOLVED";
				run_whatweb "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
				run_wafw00f "$DOMAIN" "$WORKING_DIR"/"$ALL_RESOLVED";
				run_nikto "$WORKING_DIR"/"$ALL_RESOLVED";
		fi
fi

# -C run content discovery
if [[ "$CONTENT_DISCOVERY" -eq 1 ]]; then
		echo -e "$BLUE""[i] Beginning content discovery with inception, waybackurls, ffuf, gobuster, and dirsearch.""$NC";
		sleep 0.5;

		# Call unique to make sure list is up to date for content discovery
		unique;

		# Check if $SUBDOMAIN_WORDLIST is set, else use short as default
		if [[ "$CONTENT_WORDLIST" != "" ]]; then
				if [[ "$USE_ALL" -eq 1 ]]; then
						run_inception "$DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$ALL_RESOLVED";
						run_waybackurls "$DOMAIN";
						# run_snallygaster "$DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$ALL_RESOLVED";
						run_ffuf "$DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$ALL_RESOLVED";
						run_gobuster "$DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$ALL_RESOLVED";
						run_dirsearch "$DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$ALL_RESOLVED";
				# Make sure there are interesting domains
				elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') -gt 0 ]]; then
						run_inception "$DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
						run_waybackurls "$DOMAIN";
						# run_snallygaster "$DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
						run_ffuf "$DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
						run_gobuster "$DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
						run_dirsearch "$DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
				else
						run_inception "$DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$ALL_RESOLVED";
						run_waybackurls "$DOMAIN";
						# run_snallygaster "$DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$ALL_RESOLVED";
						run_ffuf "$DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$ALL_RESOLVED";
						run_gobuster "$DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$ALL_RESOLVED";
						run_dirsearch "$DOMAIN" "$CONTENT_WORDLIST" "$WORKING_DIR"/"$ALL_RESOLVED";
				fi
		else
				if [[ "$USE_ALL" -eq 1 ]]; then
						run_inception "$DOMAIN" "$SHORT" "$WORKING_DIR"/"$ALL_RESOLVED";
						run_waybackurls "$DOMAIN";
						# run_snallygaster "$DOMAIN" "$SHORT" "$WORKING_DIR"/"$ALL_RESOLVED";
						run_ffuf "$DOMAIN" "$SHORT" "$WORKING_DIR"/"$ALL_RESOLVED";
						run_gobuster "$DOMAIN" "$SHORT" "$WORKING_DIR"/"$ALL_RESOLVED";
						run_dirsearch "$DOMAIN" "$SHORT" "$WORKING_DIR"/"$ALL_RESOLVED";
				# Make sure there are interesting domains
				elif [[ $(wc -l "$WORKING_DIR"/"$INTERESTING_DOMAINS" | awk '{print $1}') != 0 ]]; then
						run_inception "$DOMAIN" "$SHORT" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
						run_waybackurls "$DOMAIN";
						# run_snallygaster "$DOMAIN" "$SHORT" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
						run_ffuf "$DOMAIN" "$SHORT" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
						run_gobuster "$DOMAIN" "$SHORT" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
						run_dirsearch "$DOMAIN" "$SHORT" "$WORKING_DIR"/"$INTERESTING_DOMAINS";
				else
						run_inception "$DOMAIN" "$SHORT" "$WORKING_DIR"/"$ALL_RESOLVED";
						run_waybackurls "$DOMAIN";
						# run_snallygaster "$DOMAIN" "$SHORT" "$WORKING_DIR"/"$ALL_RESOLVED";
						run_ffuf "$DOMAIN" "$SHORT" "$WORKING_DIR"/"$ALL_RESOLVED";
						run_gobuster "$DOMAIN" "$SHORT" "$WORKING_DIR"/"$ALL_RESOLVED";
						run_dirsearch "$DOMAIN" "$SHORT" "$WORKING_DIR"/"$ALL_RESOLVED";
				fi
		fi
fi

# -p portscanning
if [[ "$PORTSCANNING" -eq 1 ]]; then
		echo -e "$GREEN""Beginning portscanning with masscan (if root) and nmap.""$NC";
		sleep 0.5;

		run_masscan;
		run_nmap;
fi

get_interesting;
list_found;

# -r rescope
if [[ "$ENABLE_RESCOPE" -eq 1 ]]; then
		run_rescope;
fi

# Calculate scan runtime
SCAN_END=$(date +%s);
SCAN_DIFF=$(( SCAN_END - SCAN_START ));

if [[ "$NOTICA" != "" ]]; then
		run_notica "$DOMAIN";
fi
echo -e "$BLUE""[i] Total script run time: $SCAN_DIFF seconds.""$NC";
