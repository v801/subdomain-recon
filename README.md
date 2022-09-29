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

[Subjack](https://github.com/haccer/subjack): Subdomain Takeover tool designed to scan a list of subdomains concurrently and identify ones that are able to be hijacked.

```
go install github.com/haccer/subjack@latest
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
[+] Checking subdomains for subdomain takeover ...
[+] Done! Recon files logged to: recon/totallyrealsite.com
[+] Completed in 7 seconds.
```

Output for the assetfinder, httprobe and subjack scans can be found in:
```
$ ls recon/totallyrealsite.com
recon/totallyrealsite.com/totallyrealsite.com.assets
recon/totallyrealsite.com/totallyrealsite.com.probed
recon/totallyrealsite.com/totallyrealsite.com.subjack
```

## TODO

- Chain this automated process further with tools like [gowitness](https://github.com/sensepost/gowitness) and nmap.
- Scrape and pull files from wayback machine.
