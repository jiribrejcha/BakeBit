#!/bin/bash
# Cleans networkinfo cache text files 

DIRECTORY="/home/wlanpi/NanoHatOLED/BakeBit/Software/Python/scripts/networkinfo"
CAPTUREFILE="/tmp/lldpneightcpdump.cap"
OUTPUTFILE="/tmp/lldpneigh.txt"

#Clean up LLDP cache files
logger "networkinfo script: cleaning LLDP neighbour cache files"
echo "No neighbour, takes up to 30 seconds" > "$OUTPUTFILE"
#Tell me if eth0 is down 
sudo /sbin/ethtool eth0 | grep -q "Link detected: no" && echo "Eth0 is down" > "$OUTPUTFILE"

#Remove capture file
sudo rm -f "$CAPTUREFILE"

exit 0
