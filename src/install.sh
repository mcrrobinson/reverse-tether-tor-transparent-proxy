#!/bin/sh
#Install depdencies.
sudo apt-get install -y systemd tor curl

#Defining variables
torconfig="/etc/tor/torrc"
torconfigbackup="/etc/tor/torrc.backup"
executablerules="$PWD/files/tor-router"
servicefile="$PWD/files/tor-router.service"

#Check if the current user have root privileges
if [ "$UID" -ne "0" ] ; then
    echo -e "\nYou need root permisions to run it script."
    exit
fi

echo -e "Checking if TOR and Systemd are installed..."
if command -v tor >/dev/null && command -v systemctl > /dev/null ; then
  if grep -iq "# Seting up TOR transparent proxy for tor-router" "$torconfig" ; then
    echo -e "\ntor-router is already configured in $torconfig"
  else
    echo -e "\nAll fundamentals tools are installed, proceding..."
    echo -e "\nMaking a backup of your torrc file, if you have problems with the new configuration, delete $torconfig and move $torconfigbackup to $torconfig"
    cp "$torconfig" "$torconfigbackup"
    echo -e "\nConfiguring the torrc file to use TOR as a transparent proxy..."
    echo -e "\n# Seting up TOR transparent proxy for tor-router\nVirtualAddrNetwork 10.192.0.0/10\nAutomapHostsOnResolve 1\nTransPort 9040\nDNSPort 5353" >> "$torconfig"
    cp "$executablerules" "/usr/bin/"
    chmod +x "/usr/bin/tor-router"
    cp "$servicefile" "/etc/systemd/system/"
    echo -e "Installation complete, not necessarily successful!"
  fi
else
  echo -e "Systemd or TOR are not installed, the script dont work."
  exit
fi
