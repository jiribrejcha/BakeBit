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
DEFAULTGATEWAY=$(ip route | grep "default" | cut -d ' ' -f3)
DGINTERFACE=$(ip route | grep "default" | cut -d ' ' -f5)
DNSSERVER1=$(sudo cat /etc/resolv.conf | grep "nameserver" -m1 | cut -d ' ' -f2)
DNSSERVER2=$(sudo cat /etc/resolv.conf | grep "nameserver" | head -2 | tail -1 | cut -d ' ' -f2)

#Check if Google.com is pingeable
if [ "$DEFAULTGATEWAY" ]; then
    #Ping Google.com
    #Don't use pipes here or add other commands in between otherwise the if check fails
    PINGGOOGLERTT=$(timeout 1.5 ping -c1 -W1.5 -q google.com 2>/dev/null)
    if [ $? -eq 0 ]; then
        PINGGOOGLERTT=$(echo "$PINGGOOGLERTT" | grep "rtt" | cut -d "." -f2 | cut -d "/" -f2)
        if [ "$PINGGOOGLERTT" ]; then
            PINGGOOGLERTT="${PINGGOOGLERTT}ms"
            PINGSTRING1="Ping Google:"
            PINGSPACES=$((20-${#PINGGOOGLERTT}-${#PINGSTRING1}))
            PINGSTRING2=$(echo "$PINGGOOGLERTT" | sed ':lbl; /^ \{'$PINGSPACES'\}/! {s/^/ /;b lbl}')
            echo "${PINGSTRING1}${PINGSTRING2}"
        else
            echo "Ping Google:    FAIL"
        fi
    else
        echo "Ping Google:    FAIL"
    fi

    #Check if we can browse to google.com web page
    curl -m 2 -s -L www.google.com | grep "google.com" &>/dev/null && echo "Browse Google:    OK" || echo "Browse Google:  FAIL"

    #Ping default gateway
    PINGDGRTT=$(ping -c1 -W1.5 -q "$DEFAULTGATEWAY" 2>/dev/null)
    if [ $? -eq 0 ]; then
        PINGDGRTT=$(echo "$PINGDGRTT" | grep "rtt" | cut -d "." -f2 | cut -d "/" -f2)
        if [ "$PINGDGRTT" ]; then
            PINGDGRTT="${PINGDGRTT}ms"
            PINGDGSTRING1="Ping Gateway:"
            PINGDGSPACES=$((20-${#PINGDGRTT}-${#PINGDGSTRING1}))
            PINGDGSTRING2=$(echo "$PINGDGRTT" | sed ':lbl; /^ \{'$PINGDGSPACES'\}/! {s/^/ /;b lbl}')
            echo "${PINGDGSTRING1}${PINGDGSTRING2}"
        else
            echo "Ping Gateway:   FAIL"
        fi
    else
        echo "Ping Gateway:   FAIL"
    fi

    #Check if primary and secondary DNS servers can translate google.com
    if [ "$DNSSERVER1" ]; then
        dig +short +time=2 +tries=1 @"$DNSSERVER1" NS google.com &>/dev/null && echo "Pri DNS Resol:    OK" || echo "Pri DNS Resol:  FAIL" 2>/dev/null
    fi
    if [ "$DNSSERVER2" ]; then
        dig +short +time=2 +tries=1 @"$DNSSERVER2" NS google.com &>/dev/null && echo "Sec DNS Resol:    OK" || echo "Sec DNS Resol:  FAIL" 2>/dev/null
    fi

    #ARPing default gateway - useful if gateway is configured not to respond to pings
    ARPINGRTT=$(sudo arping -c1 -w1 -I "$DGINTERFACE" "$DEFAULTGATEWAY" 2>/dev/null)
    if [ $? -eq 0 ]; then
        ARPINGRTT=$(echo "$ARPINGRTT" | grep "ms" | cut -d " " -f7 | cut -d "." -f1)
        if [ "$ARPINGRTT" ]; then
            ARPINGRTT="${ARPINGRTT}ms"
            ARPINGSTRING1="Arping Gateway:"
            ARPINGSPACES=$((20-${#ARPINGRTT}-${#ARPINGSTRING1}))
            ARPINGSTRING2=$(echo "$ARPINGRTT" | sed ':lbl; /^ \{'$ARPINGSPACES'\}/! {s/^/ /;b lbl}')
            echo "${ARPINGSTRING1}${ARPINGSTRING2}"
        else
            echo "Arping Gateway: FAIL"
        fi
    else
        echo "Arping Gateway: FAIL"
    fi

else
    echo "No Default Gateway"
fi

exit 0
