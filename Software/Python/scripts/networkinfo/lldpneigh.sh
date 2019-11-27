#!/bin/bash
# Detects LLDP neighbour on eth0 interface

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
CAPTUREFILE="/tmp/lldpneightcpdump.cap"
OUTPUTFILE="/tmp/lldpneigh.txt"

#Clean up the output files
sudo "$DIRECTORY"/lldpcleanup.sh

logger "networkinfo script: looking for an LLDP neighbour"

#Run packet capture for up to 31 seconds or stop after we have got the right packets
TIMETOSTOP=0
while [ "$TIMETOSTOP" == 0 ]; do
    timeout 31 sudo tcpdump -vv -s 1500 -c 1 'ether[12:2]=0x88cc' -Q in > "$CAPTUREFILE"
    TIMETOSTOP=$(cat "$CAPTUREFILE" | grep "LLDP")
done

#If we didn't capture any LLDP packets then return
if [ -z "$TIMETOSTOP" ]; then
    logger "networkinfo script: no LLDP neighbour detected"
    exit 0
else 
    logger "networkinfo script: found a new LLDP neighbour"
fi

#Be careful this first statement uses tee without -a and overwrites the content of the text file
DEVICEID=$(cat "$CAPTUREFILE" | grep "System Name" | cut -d ' ' -f7)
echo -e "Name: $DEVICEID" 2>&1 | tee "$OUTPUTFILE"

PLATFORM=$(cat "$CAPTUREFILE" | grep -A 1 "System Description" | cut -d$'\n' -f2 | sed -e 's/^[ \t]*//')
echo -e "Model: $PLATFORM" 2>&1 | tee -a "$OUTPUTFILE"

ADDRESS=$(sudo cat "$CAPTUREFILE" | grep "Management Address" | cut -d ' ' -f 10 | cut -d$'\n' -f2)
echo -e "IP: $ADDRESS" 2>&1 | tee -a "$OUTPUTFILE"

PORT=$(cat "$CAPTUREFILE" | grep "Port Description" | cut -d ':' -f2 | awk '{$1=$1};1')
echo -e "Port: $PORT" 2>&1 | tee -a "$OUTPUTFILE"

PORTVLAN=$(cat "$CAPTUREFILE" | grep -A1 "Port VLAN" | cut -d$'\n' -f2 | cut -d ' ' -f9 | cut -d$'\n' -f1)
echo -e "Native VLAN: $PORTVLAN" 2>&1 | tee -a "$OUTPUTFILE"

exit 0
