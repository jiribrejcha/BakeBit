#!/bin/bash
# Shows public IP address and related details 

#Get all data in JSON format 
DATAINJSON=$(timeout 2 curl -s 'ifconfig.co/json')

if [ ! "$DATAINJSON" ]; then
    echo "No public IP address detected"
    #Conciously exiting with 0 to prevent error message in Python code that calls this script 
    exit 0
fi

#Parse them
PUBLICIP=$(echo "$DATAINJSON" | python3 -c "import sys, json; print(json.load(sys.stdin)['ip'])")
PUBLICIPCOUNTRY=$(echo "$DATAINJSON" | python3 -c "import sys, json; print(json.load(sys.stdin)['country'])")
PUBLICIPASNORG=$(echo "$DATAINJSON" | python3 -c "import sys, json; print(json.load(sys.stdin)['asn_org'])")
PUBLICIPHOSTNAME=$(echo "$DATAINJSON" | python3 -c "import sys, json; print(json.load(sys.stdin)['hostname'])")
PUBLICIPASN=$(echo "$DATAINJSON" | python3 -c "import sys, json; print(json.load(sys.stdin)['asn'])")

#Display data
if [ "$PUBLICIP" ]; then
    echo "$PUBLICIP"
    echo "$PUBLICIPCOUNTRY"
    echo "$PUBLICIPASNORG"
    echo "$PUBLICIPHOSTNAME"
    echo "$PUBLICIPASN"
else
    echo "No public IP address detected"
fi

exit 0

