#!/bin/bash

# Install adb in order to communicate with attached device.
apt -y install android-tools-adb systemd tor curl

#Defining variables
torconfig="/etc/tor/torrc"
torconfigbackup="/etc/tor/torrc.backup"
executablerules="$PWD/files/tor-router"
servicefile="$PWD/files/tor-router.service"

#Check if the current user have root privileges
if [ "$UID" -ne "0" ] ; then
    echo -e "\n[ERROR] You need root permisions to run it script."
    exit
fi

echo -e "[DEBUG] Checking if TOR and Systemd are installed..."
if command -v tor >/dev/null && command -v systemctl > /dev/null ; then
  if grep -iq "[DEBUG] Seting up TOR transparent proxy for tor-router" "$torconfig" ; then
    echo -e "\n[ERROR] Tor-router is already configured in $torconfig"
  else
    echo -e "\n[DEBUG] All fundamentals tools are installed, proceding..."
    echo -e "\n[DEBUG] Making a backup of your torrc file, if you have problems with the new configuration, delete $torconfig and move $torconfigbackup to $torconfig"
    cp "$torconfig" "$torconfigbackup"
    echo -e "\n[DEBUG] Configuring the torrc file to use TOR as a transparent proxy..."
    echo -e "\n[DEBUG] Seting up TOR transparent proxy for tor-router\nVirtualAddrNetwork 10.192.0.0/10\nAutomapHostsOnResolve 1\nTransPort 9040\nDNSPort 5353" >> "$torconfig"
    cp "$executablerules" "/usr/bin/"
    chmod +x "/usr/bin/tor-router"
    cp "$servicefile" "/etc/systemd/system/"

    echo -e "\n[DEBUG] Creating, enabling and starting the service file tor transparent proxy..."
    systemctl enable tor-router.service && systemctl start tor-router.service

    echo -e "\n[DEBUG] Enabling and restarting the TOR daemon using systemctl..."
    systemctl enable tor && systemctl start tor

    if [ "$?" == 0 ] ; then
        echo -e "[DEBUG] Checking TOR's connectivity."
        if command -v curl >/dev/null ; then
        curl https://check.torproject.org/ | grep "Congratulations."
        if [ "$?" == 0 ] ; then
            echo "[DEBUG] Now plug in your phone. Press any key to continue."
            read press_enter
            chmod +x files/gnirehtet
            sudo ./files/gnirehtet run
            exit
        fi
        else
        echo -e "\n[ERROR] You haven't curl installed, try opening https://check.torproject.org/ in your browser and look for 'Congratulations.'"
        fi
    else
        echo -e "\n[ERROR] An error as ocurrer, please open a issue in https://github.com/mcrrobinson/reverse-teher-tor-transparent-proxy/issues including log info and your Linux distribution."
    fi

  fi
else
  echo -e "[ERROR] Systemd or TOR are not installed, the script dont work."
  exit
fi