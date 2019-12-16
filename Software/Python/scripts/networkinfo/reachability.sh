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
DNSSERVER2=$(sudo cat /etc/resolv.conf | grep "nameserver" | head -2 | tail -1 | cut -d ' ' -f2)

#Clean up the output file
echo "" > "$OUTPUT"

#Check if Google.com is pingeable
if [ "$DEFAULTGATEWAY" ]; then
    #Ping Google.com
    #Don't use pipes here or add other commands in between otherwise the if check fails
    PINGGOOGLERTT=$(ping -c1 -W2 -q google.com)
    if [ $? -eq 0 ]; then
        PINGGOOGLERTT=$(echo "$PINGGOOGLERTT" | grep "rtt" | cut -d "." -f2 | cut -d "/" -f2)"ms"
        PINGSTRING1="ping google:"
        PINGSPACES=$((20-${#PINGGOOGLERTT}-${#PINGSTRING1}))
        PINGSTRING2=$(echo "$PINGGOOGLERTT" | sed ':lbl; /^ \{'$PINGSPACES'\}/! {s/^/ /;b lbl}')
        echo "${PINGSTRING1}${PINGSTRING2}"
    else
        echo "ping google:    FAIL"
    fi

    #Check if we can load a web page from internet
    curl -m 2 -s -L google.com | grep "Google Search" &>/dev/null && echo "browse google:    OK" || echo "browse google:  FAIL"

    #Ping default gateway
    PINGDGRTT=$(ping -c1 -W2 -q "$DEFAULTGATEWAY" | grep "rtt" | cut -d "." -f2 | cut -d "/" -f2)"ms"
    if [ $? -eq 0 ]; then
        PINGDGSTRING1="ping gateway:"
        PINGDGSPACES=$((20-${#PINGDGRTT}-${#PINGDGSTRING1}))
        PINGDGSTRING2=$(echo "$PINGDGRTT" | sed ':lbl; /^ \{'$PINGDGSPACES'\}/! {s/^/ /;b lbl}')
        echo "${PINGDGSTRING1}${PINGDGSTRING2}"
    else
        echo "ping gateway:   FAIL"
    fi

    #Check if primary and secondary DNS servers can translate google.com
    if [ "$DNSSERVER1" ]; then
        dig +short +time=2 +tries=1 @"$DNSSERVER1" NS google.com &>/dev/null && echo "pri DNS resol:    OK" || echo "pri DNS resol:  FAIL"
    fi
    if [ "$DNSSERVER2" ]; then
        dig +short +time=2 +tries=1 @"$DNSSERVER2" NS google.com &>/dev/null && echo "sec DNS resol:    OK" || echo "sec DNS resol:  FAIL"
    fi

    #ARPing default gateway - useful if gateway is configured not to respond to pings
    ARPINGDGRTT=$(sudo arping -c1 -w2 -I "$DGINTERFACE" "$DEFAULTGATEWAY" | grep "ms" | cut -d " " -f7 | cut -d "." -f1)"ms"
    if [ $? -eq 0 ]; then
        ARPINGDGSTRING1="arping gateway:"
        ARPINGDGSPACES=$((20-${#ARPINGDGRTT}-${#ARPINGDGSTRING1}))
        ARPINGDGSTRING2=$(echo "$ARPINGDGRTT" | sed ':lbl; /^ \{'$ARPINGDGSPACES'\}/! {s/^/ /;b lbl}')
        echo "${ARPINGDGSTRING1}${ARPINGDGSTRING2}"
    else
        echo "arping gateway:   FAIL"
    fi

else
    echo "No default gateway"
fi

exit 0
