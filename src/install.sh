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
    echo -e "\nCreating, enabling and starting the service file tor transparent proxy..."
    cp "$executablerules" "/usr/bin/"
    chmod +x "/usr/bin/tor-router"
    cp "$servicefile" "/etc/systemd/system/"
    systemctl enable tor-router.service && systemctl start tor-router.service
    echo -e "\nEnabling and restarting the TOR daemon using systemctl..."
    systemctl enable tor && systemctl restart tor
    if [ "$?" == 0 ] ; then
      echo -e "Checking if all are working..."
      if command -v curl >/dev/null ; then
        curl https://check.torproject.org/ | grep "Congratulations."
        if [ "$?" == 0 ] ; then
          echo "Now plug in your phone. Press any key to continue."
          read press_enter
          chmod +x files/gnirehtet
          sudo ./files/gnirehtet run
          exit
        fi
      else
        echo -e "\nYou haven't curl installed, try opening https://check.torproject.org/ in your browser and look for 'Congratulations.'"
      fi
    else
      echo -e "\nAn error as ocurrer, please open a issue in https://github.com/mcrrobinson/reverse-teher-tor-transparent-proxy/issues including log info and your Linux distribution."
    fi
  fi
else
  echo -e "Systemd or TOR are not installed, the script dont work."
  exit
fi
