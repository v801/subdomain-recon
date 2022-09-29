#! /usr/bin/env bash

# exit immediately on non-zero exit status
set -e

iconOk="\033[32m[+]\033[0m"
iconError="\033[31m[!]\033[0m"

## display error and exit when dependency is not detected, used by checkDependency
depError() {
  printf "${iconError} Error: Unable to find $1. Check the README for more info.\n"
  exit 1
}

## check dependencies - go, assetfinder, httprobe, subjack
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
  if ! [ -x "$(command -v subjack)" ]; then
    depError Subjack
  fi
}

## read domain name
getDomainName() {
  printf "Domain to scan: "
  read domain
  if [ "$domain" = "" ]; then
    printf "${iconError} Domain cannot be empty.\n"
    exit 1
  fi
}

## setup paths with domain
setPaths() {
  # directory path
  reconDir=recon
  # file output paths
  assetsPath=${reconDir}/${domain}/${domain}.assets
  probedPath=${reconDir}/${domain}/${domain}.probed
  subjackPath=${reconDir}/${domain}/${domain}.subjack
}

## write domains/sub-domains possibly related to target domain to file
getAssets() {
  # check if domain directory exists to avoid overwriting 
  if [ -e ${reconDir}/${domain} ]; then
    printf "${iconError} Recon directory @ ${reconDir}/${domain} already exists ...\n"
    exit 1
  else
    mkdir --parents ${reconDir}/${domain}
    printf "${iconOk} Finding subdomains ...\n"
    # run assetfinder, grep for same domains only, remove duplicates/www subdomains, write output
    assetfinder ${domain}|grep ${domain}|sort -u|sed '/www./d' > ${assetsPath}
    # get count
    domainCount=$(< ${assetsPath} wc -l)
    printf "${iconOk} Found ${domainCount} unique subdomains for ${domain} ...\n"
  fi
}

## probe list of possible sub-domains for a response and write to file
probeAssets() {
  printf "${iconOk} Probing subdomains for response ...\n"
  # run httprobe against assetfinder list, remove https prefixes, write output
  cat ${assetsPath}|httprobe --prefer-https|sed 's/https\?:\/\///' > ${probedPath}
  # get count
  probeCount=$(< ${probedPath} wc -l)
  printf "${iconOk} Found ${probeCount} subdomains with a response ...\n"
}

## check list of probed subdomains for subdomain takeover and write output
subjackAssets() {
  # use our own fingerprints.json as workaround for subjack bug
  scriptDir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
  fingerprints=${scriptDir}/"fingerprints.json"
  printf "${iconOk} Checking subdomains for subdomain takeover ...\n"
  # run subjack against probed subdomain list, writes output when vulnerable host is found
  subjack -w ${probedPath} -t 20 -timeout 30 -o ${subjackPath} -ssl -a -c ${fingerprints}
  # if subjack writes output, get count
  if [ -e ${subjackPath} ]; then
    subjackCount=$(< ${subjackPath} wc -l)
    printf "${iconOk} Found ${subjackCount} subdomains vulnerable to takeover ...\n"
  fi
}

## print done message
showDoneMessage() {
  printf "${iconOk} Done! Recon files logged to: ${reconDir}/${domain}\n"
  printf "${iconOk} Completed in ${SECONDS} seconds.\n"
}

## main function
main() {
  checkDependency
  getDomainName
  setPaths
  getAssets
  probeAssets
  subjackAssets
  showDoneMessage
}

main
