#!/bin/bash
#Keeps an eye on the syslog for eth0 up and down events and triggers networkinfo (i.e. LLDP) scripts

DIRECTORY="/home/wlanpi/NanoHatOLED/BakeBit/Software/Python/scripts/networkinfo"

tail -fn0 /var/log/messages |
while read -r line
do
  case "$line" in
  *"device (eth0): link connected"*)
    logger "networkinfo script: eth0 went up"
    sudo /sbin/dhclient eth0 &
    sudo "$DIRECTORY"/lldpneigh.sh &
    sudo "$DIRECTORY"/cdpneigh.sh &
  ;;
  *"eth0: Link is Down"*)
    sudo /sbin/dhclient -r eth0 &
    logger "networkinfo script: eth0 went down"
    sudo "$DIRECTORY"/lldpcleanup.sh &
    sudo "$DIRECTORY"/cdpcleanup.sh &
  ;;
  *)
  esac
done
