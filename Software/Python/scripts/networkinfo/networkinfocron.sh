#!/bin/bash
#Keeps an eye on the syslog for eth0 up and down events and triggers networkinfo (i.e. LLDP) scripts

DIRECTORY="/home/wlanpi/NanoHatOLED/BakeBit/Software/Python/scripts/networkinfo"

tail -fn0 /var/log/messages |
while read -r line
do
  case "$line" in
  *"device (eth0): link connected"*)
    logger "networkinfo script: eth0 went up"
    sudo "$DIRECTORY"/lldpneigh.sh
  ;;
  *"eth0: Link is Down"*)
    logger "networkinfo script: eth0 went down"
    sudo "$DIRECTORY"/lldpcleanup.sh
  ;;
  *)
  esac
done
