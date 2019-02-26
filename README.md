# Chomp Scan

A scripted pipeline of tools to simplify the bug bounty/penetration test reconnaissance phase, so you can focus on chomping bugs.

![](screenshots/screenshot01.png)

### Scope
Chomp Scan is a Bash script that chains together the (in my opinion/experience) fastest and most effective tools for doing the long and sometimes tedious process of recon. No more looking for word lists and trying to remember when you started a scan and where the output is. Chomp Scan creates a timestamped output directory based on the search domain, e.g. *example.com-21:38:15*, and puts all tool output there, split into individual sub-directories as appropriate.

Various prompts appear asking what wordlists to use, whether to use [aquatone](https://github.com/michenriksen/aquatone) to take screenshots of discovered domains, whether to perform port scanning, and whether to begin bruteforce content discovery.

A list of interesting words is included, such as *dev, test, uat, staging,* etc., and domains containing those terms are flagged. This way you can focus on the interesting domains first if you wish. This list can be customized to suit your own needs.

A blacklist file is included, to exclude certain domains from the results. However it does not prevent those domains from being resolved, only from being used for port scanning and content discovery.

Chomp Scan supports limited canceling/skipping of tools by pressing Ctrl-c. This can sometimes have unintended side effects, so use with care.

**Note: Chomp Scan is still in development, and new/different tools will be added as I find them. Pull requests and comments welcome!**

### Scanning Phases

#### Subdomain Discovery (3 different sized wordlists)
* dnscan
* subfinder
* sublist3r
* massdns + altdns
* subjack

#### Screenshots (optional)
* aquatone

#### Port Scanning (optional)
* masscan and/or nmap

#### Information Gathering (optional) (4 different sized wordlists)
* bfac
* nikto
* whatweb
* wafw00f

#### Content Discovery (optional) (4 different sized wordlists)
* ffuf
* gobuster

### Wordlists

A variety of wordlists are used, both for subdomain bruteforcing and content discovery. Daniel Miessler's [Seclists](https://github.com/danielmiessler/SecLists) are used heavily, as well as Jason Haddix's [lists](https://gist.github.com/jhaddix). Different wordlists can be used by changing relevant variables at the top of the script.

#### Subdomain Bruteforcing
* subdomains-top1mil-20000.txt - 22k words - From [Seclists](https://github.com/danielmiessler/SecLists)
* sortedcombined-knock-dnsrecon-fierce-reconng.txt - 102k words - From [Seclists](https://github.com/danielmiessler/SecLists) 
* huge-200k.txt - 199k words - A combination I made of various wordlists, including Seclists

#### Content Discovery
* big.txt - 20k words - From [Seclists](https://github.com/danielmiessler/SecLists)
* raft-large-combined.txt - 167k words - A combination of the raft wordlists in [Seclists](https://github.com/danielmiessler/SecLists)
* seclists-combined.txt - 215k words - A larger combination of all the Discovery/DNS lists in [Seclists](https://github.com/danielmiessler/SecLists)
* haddix_content_discovery_all.txt - 373k words - Jason Haddix's [all](https://gist.github.com/jhaddix/b80ea67d85c13206125806f0828f4d10/) content discovery list
* haddix-seclists-combined.txt - 486k words - A combination of the two previous lists

#### Misc.
* altdns-words.txt - 240 words - Used for creating domain permutations for [masscan](https://github.com/robertdavidgraham/masscan) to resolve. Borrowed from [altdns](https://github.com/infosec-au/altdns/blob/master/words.txt).
* interesting.txt - 42 words - A list I created of potentially interesting words appearing in domain names.

### Installation
Clone this repo and ensure that the below dependencies are met. Having a [working installation of Go](https://linuxize.com/post/how-to-install-go-on-debian-9/) will help with several of the tools.

```
git clone https://github.com/SolomonSklash/chomp-scan.git;
sudo apt install sublist3r masscan nmap nikto gobuster chromium whatweb wafw00f -y;
go get github.com/subfinder/subfinder;
go get github.com/haccer/subjack;
go get github.com/ffuf/ffuf;
mkdir -pv ~/bounty/tools/aquatone;
wget https://github.com/michenriksen/aquatone/releases/download/v1.4.3/aquatone_linux_amd64_1.4.3.zip -O ~/bounty/tools/aquatone/aquatone.zip;
uzip ~/bounty/tools/aquatone/aquatone.zip -d ~/bounty/tools/aquatone; # Unzip aquatone
git clone https://github.com/rbsec/dnscan.git ~/bounty/tools/dnscan;
git clone https://github.com/infosec-au/altdns.git ~/bounty/tools/altdns; 
git clone https://github.com/blechschmidt/massdns.git ~/bounty/tools/massdns; 
cd ~/bounty/tools/massdns; make; # Compiling massdns, see repo for details
git clone https://github.com/mazen160/bfac.git ~/bounty/tools/bfac;
```

Then make sure the path variables for each tool are set. Currently they default to ~/bounty/tools/[tool-repo]/[tool-file].
```
# Tool paths
SUBFINDER=$(command -v subfinder);
SUBLIST3R=$(command -v sublist3r);
SUBJACK=$(command -v subjack);
FFUF=$(command -v ffuf);
WHATWEB=$(command -v whatweb);
WAFW00F=$(command -v wafw00f);
GOBUSTER=$(command -v gobuster);
CHROMIUM=$(command -v chromium);
DNSCAN=~/bounty/tools/dnscan/dnscan.py;
ALTDNS=~/bounty/tools/altdns/altdns.py;
MASSDNS_BIN=~/bounty/tools/massdns/bin/massdns;
MASSDNS_RESOLVERS=~/bounty/tools/massdns/lists/resolvers.txt;
AQUATONE=~/bounty/tools/aquatone/aquatone;
BFAC=~/bounty/tools/bfac/bfac;
```

### Usage
`./chomp-scan.sh example.com`

### Dependencies

The following tools are required for Chomp Scan. Note that this tool was designed with Kali Linux in mind, so certain tools are expected to be available via package manager.

* [sublist3r](https://github.com/aboul3la/Sublist3r) - Kali package
* [masscan](https://github.com/robertdavidgraham/masscan) Kali package
* [nmap](https://www.nmap.org) Kali package
* [nikto](https://cirt.net/nikto2) Kali package
* [gobuster](https://github.com/OJ/gobuster) Kali package
* [whatweb](https://www.morningstarsecurity.com/research/whatweb) Kali package
* [wafw00f](https://github.com/EnableSecurity/wafw00f) Kali package
* [chromium](https://www.chromium.org/) Kali package (needed for aquatone)
* [dnscan](https://github.com/rbsec/dnscan)- Python
* [altdns](https://github.com/infosec-au/altdns) - Python
* [bfac](https://github.com/mazen160/bfac) Python3
* [massdns](https://github.com/blechschmidt/massdns) - Compiled with C
* [subfinder](https://github.com/subfinder/subfinder) - Go
* [subjack](https://github.com/haccer/subjack) Go
* [ffuf](https://github.com/ffuf/ffuf) Go
* [aquatone](https://github.com/michenriksen/aquatone) Precompiled Go binary

### In The Future

Chomp Scan is still in active development, as I use it myself for bug hunting, so I intend to continue adding new features and tools as I come across them. New tool suggestions, feedback, and pull requests are all welcomed. Here is a short list of potential additions I'm considering:

* A non-interactive mode, where certain defaults are selected so the scan can be run and forget
* Adding a config file, for more granular customization of tools and parameters
* A possible Python re-write, with a pure CLI mode (and maybe a Go re-write after that!)
* The generation of an HTML report, similar to what aquatone provides

### Examples
![](screenshots/screenshot02.png)
![](screenshots/screenshot03.png)
![](screenshots/screenshot04.png)
![](screenshots/screenshot05.png)
![](screenshots/screenshot06.png)
![](screenshots/screenshot07.png)

## Thanks
Thanks to all the authors of the included tools. They do all the heavy lifting.
