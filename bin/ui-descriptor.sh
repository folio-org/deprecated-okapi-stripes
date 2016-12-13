#!/bin/sh

tenant="$1"
config=./etc/ui-module.json 
curl_debug=	#"-v"

if [ -z "$tenant" ]; then
    echo "Usage $0 tenant"
    exit 1
fi

if [ ! -e  $config ]; then
    echo "Missing config file: $config"
    exit 2
fi

curl $curl_debug -H "X-Okapi-Tenant-Id: $tenant" -X POST --data-binary @${config}  -H "Content-Type: application/json" 'http://localhost:3030/bundle'

