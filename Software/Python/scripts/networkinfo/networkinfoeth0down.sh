#!/bin/bash
#Keeps an eye on the system log and starts script every time eth0 goes down

DIRECTORY="/home/wlanpi/NanoHatOLED/BakeBit/Software/Python/scripts/networkinfo"

while :
do
    sudo tail -fn0 /var/log/messages | grep -q "eth0: Link is Down" && sudo "$DIRECTORY"/lldpcleanup.sh
done
