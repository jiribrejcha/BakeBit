#!/bin/bash
#Keeps an eye on the system log and starts script every time eth0 goes up

DIRECTORY="/home/wlanpi/NanoHatOLED/BakeBit/Software/Python/scripts/networkinfo"

while :
do
    sudo tail -fn0 /var/log/messages | grep -q "device (eth0): link connected" && sudo "$DIRECTORY"/lldpneigh.sh
done
