# Chomp Scan
![GitHub release](https://img.shields.io/github/release/SolomonSklash/chomp-scan.svg?style=for-the-badge)
![GitHub](https://img.shields.io/github/license/SolomonSklash/chomp-scan.svg?style=for-the-badge)
![GitHub issues](https://img.shields.io/github/issues/SolomonSklash/chomp-scan.svg?style=for-the-badge)

A scripted pipeline of tools to simplify the bug bounty/penetration test reconnaissance phase, so you can focus on chomping bugs.

![](screenshots/screenshot01.png)

*If you've found any bugs using this tool, please let me know!*

### Scope
Chomp Scan is a Bash script that chains together the fastest and most effective tools (in my opinion/experience) for doing the long and sometimes tedious process of recon. No more looking for word lists and trying to remember when you started a scan and where the output is. Chomp Scan can focus on a list of potentially interesting subdomains, letting you save time and focus on high-value targets. It can even notify you via Notica when it's done running!

Chomp Scan now integrates [Notica](https://notica.us), which allows you to receive a notification when the script finishes. Simply visit Notica and get a unique URL parameter, e.g. notica.us/?xxxxxxxx. Pass the parameter to Chomp Scan via the `-n` flag, keep the Notica page open in a browser tab on your computer or phone, and you will receive a message when Chomp Scan has finished running. No more constantly checking/forgetting to check those long running scans.

A list of interesting words is included, such as *dev, test, uat, staging,* etc., and domains containing those terms are flagged. This way you can focus on the interesting domains first if you wish. This list can be customized to suit your own needs, or replaced with a different file via the `-X` flag.

Chomp Scan runs in multiple modes. A new [Configuration File](https://github.com/SolomonSklash/chomp-scan/wiki/Configuration-File) is the recommended way to run scans, as it allows the most granular control of tools and settings. A standard CLI mode is included, which functions the same as any other CLI tool. A guided interactive mode is available, as well as a non-interactive mode, useful if you do not want to lookup parameters or worry about setting multiple arguments.

**New** Chomp Scan now includes [rescope](https://github.com/root4loot/rescope). Rescope will parse all resolved domains discovered by Chomp Scan and generate a JSON scope file that can be imported into Burp Suite. This option can be enabled by setting the `ENABLE_RESCOPE` variable in the configuration file or by passing the `-r` flag via the command line.

Please see the [Wiki](https://github.com/SolomonSklash/chomp-scan/wiki) for detailed documentation.

**Note: Chomp Scan is in active development, and new/different tools will be added as I come across them. Pull requests and comments welcome!**

### Scanning Phases

#### Subdomain Discovery (3 different sized wordlists)
* [dnscan](https://github.com/rbsec/dnscan)
* [subfinder](https://github.com/subfinder/subfinder)
* [sublist3r](https://github.com/aboul3la/Sublist3r)
* [knockpy](https://github.com/SolomonSklash/knock) (forked from the original [here](https://github.com/guelfoweb/knock))
* [amass](https://github.com/OWASP/Amass)
* [massdns](https://github.com/blechschmidt/massdns) + [goaltdns](https://github.com/subfinder/goaltdns)

#### Screenshots (optional)
* [aquatone](https://github.com/michenriksen/aquatone)

#### Port Scanning (optional)
* [masscan](https://github.com/robertdavidgraham/masscan) and/or [nmap](https://www.nmap.org)
* nmap output styled with [nmap-bootstrap-xsl](https://github.com/honze-net/nmap-bootstrap-xsl/)

#### Information Gathering (optional) (4 different sized wordlists)
* [subjack](https://github.com/haccer/subjack)
* [CORStest](https://github.com/RUB-NDS/CORStest)
* [S3Scanner](https://github.com/sa7mon/S3Scanner)
* [bfac](https://github.com/mazen160/bfac)
* [whatweb](https://github.com/urbanadventurer/whatweb/)
* [wafw00f](https://github.com/EnableSecurity/wafw00f)
* [nikto](https://github.com/sullo/nikto)

#### Content Discovery (optional) (4 different sized wordlists)
* [inception](https://github.com/proabiral/inception)
* [waybackurls](https://github.com/tomnomnom/waybackurls)
* [ffuf](https://github.com/ffuf/ffuf)
* [gobuster](https://github.com/OJ/gobuster)
* [dirsearch](https://github.com/maurosoria/dirsearch)

### Configuration File
Chomp Scan now features a configuration file option that provides more granular control over which tools are run and is less cumbersome than passing a large number of CLI arguments. It is the recommended way to run Chomp Scan. It can be used by passing the `-L` flag. An [example config](https://github.com/SolomonSklash/chomp-scan/blob/master/config) file is included in this repo as a template, and complete config file details are available at the [Configuration File](https://github.com/SolomonSklash/chomp-scan/wiki/Configuration-File) wiki page.

### Wordlists

A variety of wordlists are used, both for subdomain bruteforcing and content discovery. Daniel Miessler's [Seclists](https://github.com/danielmiessler/SecLists) are used heavily, as well as Jason Haddix's [lists](https://gist.github.com/jhaddix). Different wordlists can be used by passing in a custom wordlist or using one of the built-in named argument lists. See the [Wordlist](https://github.com/SolomonSklash/chomp-scan/wiki/Wordlists) wiki page for more details.

### Installation
Clone this repo and run the included `installer.sh` script, optionally including a custom file path to install necessary tools to. Make sure to run `source ~/.profile` in your terminal after running the installer in order to add the Go binary path to your $PATH variable. Then run Chomp Scan. If you are using zsh, fish, or some other shell, make sure that `~/go/bin` is in your path. For more details, see the [Installation](https://github.com/SolomonSklash/chomp-scan/wiki/Installation) wiki page.

TLDR: `root@kali:~/chomp-scan# ./installer.sh [/some/optional/install/path]`

### Usage
For complete usage information, see the [Usage](https://github.com/SolomonSklash/chomp-scan/wiki/Usage) page of the wiki. *Please note that the configuration is the recommended and most powerful way to run Chomp Scan.*

Chomp Scan always runs subdomain enumeration, thus a domain is required via the `-u` flag. The domain should not contain a scheme, e.g. http:// or https://. By default, HTTPS is always used. This can be changed to HTTP by passing the `-H` flag. A wordlist is optional, and if one is not provided the built-in short list (20k words) is used.

Other scan phases are optional. Content discovery can take an optional wordlist, otherwise it defaults to the built-in short (22k words) list.

The final results of the scan are stored in three text files in the output directory. All unique domains that are found, whether they resolve or not, are stored in `all_discovered_domains.txt`, and all unique IPs that are discovered are stored in `all_discovered_ips.txt`. All domains that resolve to an IP are stored in `all_resolved_domains.txt`. As of v4.1 these domains are used to generate the interesting domain list and the all domains list, which can then be used for content discovery and information gathering.
```
chomp-scan.sh -u example.com -a d short -cC large -p -o path/to/directory

Usage of Chomp Scan:
        -u domain
                 (required) Domain name to scan. This should not include a scheme, e.g. https:// or http://.
	-L config-file
                 (optional) The path to a config file. This can be used to provide more granular control over what tools are run.
        -d wordlist
                 (optional) The wordlist to use for subdomain enumeration. Three built-in lists, short, long, and huge can be used, as well as the path to a custom wordlist. The default is short.
        -c
                 (optional) Enable content discovery phase. The wordlist for this option defaults to short if not provided.
        -C wordlist
                 (optional) The wordlist to use for content discovery. Five built-in lists, small, medium, large, xl, and xxl can be used, as well as the path to a custom wordlist. The default is small.
        -P file-path
                 (optional) Set a custom directory for the location of tools. The path must exist and the directory must contain all needed tools.
        -s
                 (optional) Enable screenshots using Aquatone.
        -i
                 (optional) Enable information gathering phase, using subjack, CORStest, S3Scanner, bfac, whatweb, wafw00f, and nikto.
        -p
                 (optional) Enable portscanning phase, using masscan (run as root) and nmap.
        -I
                 (optional) Enable interactive mode. This allows you to select certain tool options and inputs interactively. This cannot be run with -D.
        -D
                 (optional) Enable default non-interactive mode. This mode uses pre-selected defaults and requires no user interaction or options. This cannot be run with -I.
                            Options: Subdomain enumeration wordlist: short.
                                     Content discovery wordlist: small.
                                     Aquatone screenshots: yes.
                                     Portscanning: yes.
                                     Information gathering: yes.
                                     Domains to scan: all unique discovered.
        -b wordlist
                 (optional) Set custom domain blacklist file.
        -X wordlist
                 (optional) Set custom interesting word list.
        -o directory
                 (optional) Set custom output directory. It must exist and be writable.
        -a
                 (optional) Use all unique discovered domains for scans, rather than interesting domains. This cannot be used with -A.
        -A
                 (optional, default) Use only interesting discovered domains for scans, rather than all discovered domains. This cannot be used with -a.
	-H
                 (optional) Use HTTP for connecting to sites instead of HTTPS.
	-r
                 (optional) Enable creation of Burp scope JSON file with rescope.
        -h
                 (optional) Display this help page.
```

### In The Future

Chomp Scan is still in active development, as I use it myself for bug hunting, so I intend to continue adding new features and tools as I come across them. New tool suggestions, feedback, and pull requests are all welcomed. Possible additions:

* The generation of an HTML report, similar to what aquatone provides

### Screenshots
![](screenshots/screenshot02.png)
![](screenshots/screenshot03.png)
![](screenshots/screenshot04.png)
![](screenshots/screenshot05.png)
![](screenshots/screenshot06.png)
![](screenshots/screenshot07.png)

## Thanks
Thanks to all the authors of the included tools. They do all the heavy lifting.
