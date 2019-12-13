#!/bin/bash
# Checks reachability of default gateway and internet including DNS 

#Check if the script is running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

#Prevent multiple instances of the script to run at the same time
for pid in $(pidof -x $0); do
    if [ $pid != $$ ]; then
        echo "Another instance of the script is already running. Wait for it to finish first."
        exit 1
    fi
done

DIRECTORY="/home/wlanpi/NanoHatOLED/BakeBit/Software/Python/scripts/networkinfo"
OUTPUT="/tmp/reachability.txt"
DEFAULTGATEWAY=$(ip route | grep "default" | cut -d ' ' -f3)
DGINTERFACE=$(ip route | grep "default" | cut -d ' ' -f5)
DNSSERVER1=$(sudo cat /etc/resolv.conf | grep "nameserver" -m1 | cut -d ' ' -f2)
DNSSERVER2=$(sudo cat /etc/resolv.conf | grep "nameserver"  | head -2 | tail -1 | cut -d ' ' -f2)

#Clean up the output file
echo "" > "$OUTPUT"

#Check if gateway is pingeable
if [ "$DEFAULTGATEWAY" ]; then
    ping -c1 -W2 -t2 -q "$DEFAULTGATEWAY" &>/dev/null && echo "ping gateway:    yes" || echo "ping gateway:     no"
    sudo arping -c1 -w2 -I "$DGINTERFACE" -q "$DEFAULTGATEWAY" &>/dev/null && echo "arping gateway:  yes" || echo "arping gateway:   no"
else
    echo "No default gateway"
fi

#Check if primary and secondary DNS servers can translate google.com
if [ "$DNSSERVER1" ]; then
    dig +short +time=2 +tries=1 @"$DNSSERVER1" NS google.com &>/dev/null && echo "pri DNS resol:   yes" || echo "pri DNS resol:    no"
elif [ "$DNSSERVER2" ]; then
    dig +short +time=2 +tries=1 @"$DNSSERVER2" NS google.com &>/dev/null && echo "sec DNS resol:   yes" || echo "sec DNS resol:    no"
fi

#Check if we can load a web page from internet
curl -m 2 -s -L google.com | grep "Google Search" &>/dev/null && echo "google.com page: yes" || echo "google.com page:  no"

exit 0
