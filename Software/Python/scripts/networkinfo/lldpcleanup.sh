#!/bin/bash
# Cleans all networkinfo cache text files 

DIRECTORY="/home/wlanpi/NanoHatOLED/BakeBit/Software/Python/scripts/networkinfo"
CAPTUREFILE="/tmp/lldpneightcpdump.cap"
OUTPUTFILE="/tmp/lldpneigh.txt"

logger "networkinfo script: eth0 went down, cleaning up"

#Clean up the output file
echo "No neighbour" > "$OUTPUTFILE"

#Remove capture file
sudo rm "$CAPTUREFILE"

exit 0
