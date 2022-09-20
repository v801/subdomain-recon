# Subdomain Recon

Bash program that chains together multiple domain recon tools to enumerate subdomains on a  target domain.

## Setup

This program requires Go and a few Go packages.

[Assetfinder](https://github.com/tomnomnom/assetfinder): Find domains and subdomains potentially related to a given domain.

```
go install github.com/tomnomnom/assetfinder@latest
```

[Httprobe](https://github.com/tomnomnom/httprobe): Take a list of domains and probe for working http and https servers.

Install latest from master branch for `--prefer-https` support.  

```
go install github.com/tomnomnom/httprobe@master
```


## Usage

Clone this repo and run `./sdr.sh` to get started.

### Example

```
$ ./sdr.sh
Domain to scan: totallyrealsite.com
[+] Finding subdomains ...
[+] Found 10 unique subdomains for totallyrealsite.com ...
[+] Probing subdomains for response ...
[+] Found 8 subdomains with a response ...
[+] Done!
```

Output for both the assetfinder and httprobe scans can be found in:
```
$ ls recon/totallyrealsite.com
recon/totallyrealsite.com/totallyrealsite.com.assets
recon/totallyrealsite.com/totallyrealsite.com.probed
```

## TODO

- Chain this automated process further with tools like [subjack](https://github.com/haccer/subjack), [gowitness](https://github.com/sensepost/gowitness), and nmap.
- Scrape and pull files from wayback machine.
