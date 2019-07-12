#!/bin/bash

USER_ID=$(/usr/bin/id -u)
USER_NAME=$(/usr/bin/who am i | awk '{ print $1 }')
SCRIPT_PATH=$(/usr/bin/realpath $0)
DIR_PATH=$(/usr/bin/dirname ${SCRIPT_PATH} | sed 's/\/Script$//')

if [ ${USER_ID} -ne 0 ]; then
    echo "Please run this as root."
    exit 1
fi

if [ -d RPi.GPIO-0.5.11 ]; then
    cd RPi.GPIO-0.5.11
    python setup.py install
    cd ..
fi

if [ -d psutil-0.5.0 ]; then
    cd psutil-0.5.0
    python setup.py install
    cd ..
fi

echo "Dependencies installed"

if [ -d WiringNP ]; then
    cd WiringNP
    git pull
else
    git clone https://github.com/friendlyarm/WiringNP.git
    cd WiringNP
fi

sudo ./build
RES=$?

if [ $RES -ne 0 ]; then
  echo "Something went wrong building/installing WiringNP, exiting."
  exit 1
fi

echo "WiringNP Installed"

sudo adduser ${USER_NAME} i2c

echo " "
echo "Install smbus for python"
sudo apt-get install python-smbus -y

echo " "
echo "Making libraries global . . ."
echo "============================="
if [ -d /usr/lib/python2.7/dist-packages ]; then
    sudo cp ${DIR_PATH}/Script/bakebit.pth /usr/lib/python2.7/dist-packages/bakebit.pth
else
    echo "/usr/lib/python2.7/dist-packages not found, exiting"
    exit 1
fi

echo " "
echo "Please restart to implement changes!"
echo "  _____  ______  _____ _______       _____ _______ "
echo " |  __ \|  ____|/ ____|__   __|/\   |  __ \__   __|"
echo " | |__) | |__  | (___    | |  /  \  | |__) | | |   "
echo " |  _  /|  __|  \___ \   | | / /\ \ |  _  /  | |   "
echo " | | \ \| |____ ____) |  | |/ ____ \| | \ \  | |   "
echo " |_|  \_\______|_____/   |_/_/    \_\_|  \_\ |_|   "
echo " "
echo "Please restart to implement changes!"
echo "To Restart type sudo reboot"

echo "To finish changes, we will reboot the Pi."
echo "Pi must reboot for changes and updates to take effect."
echo "If you need to abort the reboot, press Ctrl+C.  Otherwise, reboot!"
# echo "Rebooting in 5 seconds!"
# sleep 1
# echo "Rebooting in 4 seconds!"
# sleep 1
# echo "Rebooting in 3 seconds!"
# sleep 1
# echo "Rebooting in 2 seconds!"
# sleep 1
# echo "Rebooting in 1 seconds!"
# sleep 1
# echo "Rebooting now!  "
# sleep 1
# sudo reboot
