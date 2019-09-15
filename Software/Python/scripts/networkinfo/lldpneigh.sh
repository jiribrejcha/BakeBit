#!/bin/bash
# Detects LLDP neighbour on eth0 interface

DIRECTORY="/home/wlanpi/NanoHatOLED/BakeBit/Software/Python/scripts/networkinfo"
CAPTUREFILE="/tmp/lldpneightcpdump.cap"
OUTPUTFILE="/tmp/lldpneigh.txt"

logger "networkinfo script: eth0 went up, looking for neighbour"

#Clean up the output files
sudo "$DIRECTORY"/lldpcleanup.sh

#Run packet capture for up to 31 seconds or stop after we have got the right packets
TIMETOSTOP=0
while [ "$TIMETOSTOP" == 0 ]; do
    timeout 31 sudo tcpdump -vv -s 1500 -c 1 'ether[12:2]=0x88cc' -Q in > "$CAPTUREFILE"
    TIMETOSTOP=$(cat "$CAPTUREFILE" | grep "LLDP")
done

#If we didn't capture any LLDP packets then return
if [ -z "$TIMETOSTOP" ]
    then
    exit 0
fi

#Be careful this first statement uses tee without -a and overwrites the content of the text file
systdesc=$(cat "$CAPTUREFILE" | grep -A 1 "System Description" | cut -d$'\n' -f2 | sed -e 's/^[ \t]*//' 2>&1)
echo -e "$systdesc" 2>&1 | tee "$OUTPUTFILE"

systname=$(cat "$CAPTUREFILE" | grep "System Name" | cut -d ' ' -f7 2>&1)
echo -e "$systname" 2>&1 | tee -a "$OUTPUTFILE"

neighbouraddress=$(sudo cat "$CAPTUREFILE" | grep "Management Address" | cut -d ' ' -f 10 | cut -d$'\n' -f2)
echo -e "IP: $neighbouraddress" 2>&1 | tee -a "$OUTPUTFILE"

portdesc=$(cat "$CAPTUREFILE" | grep "Port Description" | cut -d ':' -f2 | awk '{$1=$1};1' 2>&1)
echo -e "P: $portdesc" 2>&1 | tee -a "$OUTPUTFILE"

portvlan=$(cat "$CAPTUREFILE" | grep -A1 "Port VLAN" | cut -d$'\n' -f2 | cut -d ' ' -f9 | cut -d$'\n' -f1 2>&1)
echo -e "Untagged VLAN: $portvlan" 2>&1 | tee -a "$OUTPUTFILE"

exit 0
