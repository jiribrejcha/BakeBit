# networkinfo
Adds 3 new menus to the existing menu structure:

### ipconfig

Shows ip configuration of the eth0 interface.

### DNS servers

Displays all configured DNS servers.

### Show LLDP neighbour
This only works on the in-built Ethernet adapter eth0.

Every time eth0 interface goes up, WLAN Pi starts watching for LLDP packets. Whenever it detects one, it parses and caches the neighbour information to a text file.

Use the "LLDP neighbour" menu to view all neighbour details. 

![WLAN Pi LLLDP neighbour menu](https://pbs.twimg.com/media/ECqXuG2WkAA1PYF?format=jpg&name=large)

After eth0 goes down, the cache file gets flushed.

# How to install

1. Install [vanilla v1.8.3 image from Github](https://github.com/WLAN-Pi/wlanpi/releases){:height="50%" width="50%"}
2. Clone the LLDP branch to a vanilla WLAN Pi

```
sudo apt-get update
sudo apt-get install gawk
cd ~/NanoHatOLED/
mv BakeBit BakeBit.orig
git clone -b lldp https://github.com/WLAN-Pi/BakeBit.git
```

3. Reboot

```
sudo reboot
```

4. Edit cron tasks
sudo crontab -e
5. And add 2 missing scripts which will be automatically started after reboot:

```
@reboot /home/wlanpi/NanoHatOLED/BakeBit/Software/Python/scripts/networkinfo/networkinfoeth0up.sh
@reboot /home/wlanpi/NanoHatOLED/BakeBit/Software/Python/scripts/networkinfo/networkinfoeth0down.sh
```

# Contact
[@jiribrejcha](http://twitter.com/jiribrejcha)
