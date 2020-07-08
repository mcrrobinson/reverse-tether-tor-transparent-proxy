echo -e "\n[DEBUG] Creating, enabling and starting the service file tor transparent proxy..."
if service --status-all | grep -Fq 'tor-router.service'; then    
    systemctl enable tor-router.service && systemctl start tor-router.service
else
    echo -e "[ERROR] Unable to start Tor-Router process, try uninstall and install again."
fi

echo -e "\n[DEBUG] Enabling and restarting the TOR daemon using systemctl..."
if service --status-all | grep -Fq 'tor'; then    
    systemctl enable tor && systemctl restart tor  
else
    echo -e "[ERROR] Unable to start the TOR service, try uninstall and install again."
fi

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