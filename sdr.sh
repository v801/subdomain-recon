#! /usr/bin/env bash

# exit immediately on non-zero exit status
set -e

## display error and exit when dependency is not detected, used by checkDependency
depError() {
  printf "[!] Error: Unabled to find $1. Check the README for more info.\n"
  exit 1
}

## check dependencies - go, assetfinder, httprobe
checkDependency() {
  if ! [ -x "$(command -v go)" ]; then
    depError Go
  fi
  if ! [ -x "$(command -v assetfinder)" ]; then
    depError Assetfinder
  fi
  if ! [ -x "$(command -v httprobe)" ]; then
    depError Httprobe
  fi
}


## read domain name
getDomainName() {
  printf "Domain to scan: "
  read domain
  if [ "$domain" = "" ]; then
    printf "Domain cannot be empty.\n"
    exit 1
  fi
}

## setup paths with domain
setPaths() {
  # directory path
  reconDir=recon
  # file paths
  assetsPath=${reconDir}/${domain}/${domain}.assets
  probedPath=${reconDir}/${domain}/${domain}.probed
}

## write domains/sub-domains possibly related to target domain to file
getAssets() {
  # check if domain directory exists to avoid overwriting 
  if [ -e ${reconDir}/${domain} ]; then
    printf "[!] Recon directory @ ${reconDir}/${domain} already exists ...\n"
    exit 1
  else
    mkdir --parents ${reconDir}/${domain}
    printf "[+] Finding subdomains ...\n"
    # run assetfinder, grep for same domains only, remove duplicates, write output
    assetfinder ${domain}|grep ${domain}|sort -u|sed '/www./d' > ${assetsPath}
    # get count and print
    domainCount=$(< ${assetsPath} wc -l)
    printf "[+] Found ${domainCount} unique subdomains for ${domain} ...\n"
  fi
}

## probe list of possible sub-domains for a response and write to file
probeAssets() {
  printf "[+] Probing subdomains for response ...\n"
  # run httprobe against assetfinder list, remove https prefixes, write output
  cat ${assetsPath}|httprobe --prefer-https|sed 's/https\?:\/\///' > ${probedPath}
  # get count and print
  probeCount=$(< ${probedPath} wc -l)
  printf "[+] Found ${probeCount} subdomains with a response ...\n"
}


## print a message when all previous functions have run
displayDoneMessage() {
  printf "[+] Done!\n"
}

# main function
main() {
  checkDependency
  getDomainName
  setPaths
  getAssets
  probeAssets
  displayDoneMessage
}

main
