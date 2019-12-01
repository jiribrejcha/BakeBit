#!/bin/bash

#Displays IP address, subnet mask, default gateway, DNS servers, speed, duplex, DHCP server IP address and name 
ACTIVEIP=$(ip a | grep "eth0" | grep "inet" | cut -d '/' -f1 | cut -d ' ' -f6)
SUBNET=$(ip a | grep "eth0" | grep "inet" | cut -d ' ' -f6 | tail -c 4)
LEASEDIP=$(grep "fixed-address" /var/lib/dhcp/dhclient.eth0.leases | tail -1 | cut -d ' ' -f4 | cut -d ';' -f1)
ETH0ISUP=$(/sbin/ifconfig eth0 | grep "RUNNING")
DHCPENABLED=$(grep -i "eth0" /etc/network/interfaces | grep "dhcp" | grep -v "#")
DHCPSRVNAME=$(grep "server-name" /var/lib/dhcp/dhclient.eth0.leases | tail -1 | cut -d '"' -f2)
DHCPSRVADDR=$(grep "dhcp-server-identifier" /var/lib/dhcp/dhclient.eth0.leases | tail -1 | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}")
DEFAULTGW=$(/sbin/route -n | grep G | grep eth0 | cut -d ' ' -f 10)
SPEED=$(sudo ethtool eth0 | grep -q "Link detected: yes" && sudo ethtool eth0 | grep "Speed" | sed 's/....$//' | cut -d ' ' -f2  || echo "Disconnected")
DUPLEX=$(sudo ethtool eth0 | grep -q "Link detected: yes" && sudo ethtool eth0 | grep "Duplex" | cut -d ' ' -f 2 || echo "Disconnected")
DNSSERVERS=$(sudo cat /etc/resolv.conf | grep nameserver | cut -d ' ' -f2)

if [ "$ETH0ISUP" ]; then
    #IP address
    echo "IP: $ACTIVEIP"

    #Subnet
    echo "Subnet: $SUBNET"

    #Default gateway
    echo "DG: $DEFAULTGW"

    #DNS servers
    for n in $DNSSERVERS; do
        echo "DNS: $n"
    done

    #DHCP server info
    if [[ "$ACTIVEIP" = "$LEASEDIP" ]] && [[ "$DHCPENABLED" ]]; then
        echo "DHCP srv: $DHCPSRVNAME"
        echo "DHCP srv: $DHCPSRVADDR"
    else
        echo "No DHCP server used"
    fi

    #Speed
    echo "Speed: $SPEED"

    #Duplex
    echo "Duplex: $DUPLEX"

else
    echo "Disconnected"
fi
