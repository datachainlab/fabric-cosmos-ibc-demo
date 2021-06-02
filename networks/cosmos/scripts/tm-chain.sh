#!/bin/bash

set -x

# This script is a modified copy from https://github.com/cosmos/relayer/blob/14195ec4c8c19f86a3b6bbe3750f392e436a5879/scripts/two-chainz

CURDIR=$(cd $(dirname "$0"); pwd)
TM_BINARY=/usr/bin/simd

# Ensure ${TM_BINARY} is installed
if ! [ -x ${TM_BINARY} ]; then
  echo "Error: ${TM_BINARY} is not installed." >&2
  exit 1
fi

# Display software version for testers
echo "GAIA VERSION INFO:"
${TM_BINARY} version --long

## Ensure jq is installed
#if [[ ! -x "$(which jq)" ]]; then
#  echo "jq (a tool for parsing json in the command line) is required..."
#  echo "https://stedolan.github.io/jq/download/"
#  exit 1
#fi

## Ensure user understands what will be deleted
#if [[ -d $CHAIN_DATA ]] && [[ ! "$1" == "skip" ]]; then
#  read -p "$(basename $0) will delete \"$CHAIN_DATA\" and \"$RELAYER_CONF\" folders. Do you wish to continue? (y/n): " -n 1 -r
#  echo
#  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
#      exit 1
#  fi
#fi

# Delete data from old runs
rm -rf $CHAIN_DATA &> /dev/null

## Stop existing ${TM_BINARY} processes
## killall ${TM_BINARY} &> /dev/null #=> got 'No matching processes belonging to you were found'
#killall simd &> /dev/null

set -e

echo "Generating gaia configurations..."
mkdir -p $CHAIN_DATA # && cd $CHAIN_DATA && cd ../
chmod +x ${CURDIR}/one-chain.sh
#${CURDIR}/one-chain.sh ${TM_BINARY} $CHAIN_ID ./data 26657 26656 6060 9090
${CURDIR}/one-chain.sh ${TM_BINARY} $CHAIN_ID $CHAIN_DATA 26657 26656 6060 9090

[ -f $CHAIN_DATA/$CHAIN_ID.log ] && echo "$CHAIN_ID initialized. Watch file $CHAIN_DATA/$CHAIN_ID.log to see its execution."
