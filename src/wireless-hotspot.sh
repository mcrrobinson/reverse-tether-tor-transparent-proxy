export YELLOW='\033[1;93m'
export GREEN='\033[1;92m'
export RED='\033[1;91m'
export RESETCOLOR='\033[1;00m'

about(){
echo -e "\n$YELLOW----------- TOR Router ---------------\n" $RESETCOLOR
}

# update stystem
update(){
echo -e "\n$RED [Question] Is your system up to date? $YELLOW Y $RED or $YELLOW N : " $RESETCOLOR
read answer
if [ $answer == "N" ] || [ $answer == "n" ]
then
apt-get update && apt-get upgrade
else
echo -e "\n$GREEN System is up to date" $RESETCOLOR
fi
}

# install stystem requirements
requirements(){
echo -e "\n$RED [Question] Have you installed the required packages yet? $YELLOW Y $RED or $YELLOW N : " $RESETCOLOR
read answer
if [ $answer == "N" ] || [ $answer == "n" ]
then
apt-get -y install tor dnsmasq hostapd isc-dhcp-server privoxy net-tools macchanger libssl-dev
else
echo -e "\n$GREEN [Success] ALL requirements statisfied" $RESETCOLOR
fi
}

# Identify Interfaces
id_iface(){
echo -e "\n$YELLOW [Question] BELOW ARE YOUR INTERFACES..$RED ETHERNET LOOKS LIKE: $YELLOW eth0 or en55p $RED AND WIFI LOOKS LIKE $YELLOW wlan0 or wl56p $RED(similar to those)"$RESETCOLOR
ls /sys/class/net -I lo
}

# set ethernet interface variable
set_ether(){
echo -e "$YELLOW"
read -p " [Debug] Set your ethernet interface as listed above:" -e eth
}

# set wireless interface variable
set_wifi(){
read -p " [Debug] Set your wireless interface as listed above:" -e wlan
}


mac_eth0(){
echo -e "\n$GREEN [Debug] Spoofing Ethernet Mac Address...\n"
	rfkill unblock all
	sleep 3
	sudo service network-manager stop
	sleep 1
	echo -e "$GREEN [Debug] Ethernet MAC address:\n"$GREEN
	sleep 1
	sudo ifconfig $eth down
	sleep 1
	sudo macchanger -a $eth
	sleep 1
	sudo ifconfig $eth up
	sleep 1
	sudo service network-manager start
	echo -e "\n$GREEN [Debug] Mac Address Spoofing$GREEN [ON]"$RESETCOLOR
	sleep 5 
	rfkill unblock all
}

# change wlan0 mac
mac_wlan0(){
echo -e "\n$GREEN [Debug] Spoofing WiFi Mac Address...\n"
	rfkill unblock all
	sleep 3
	sudo service network-manager stop
	sleep 1
	echo -e "$GREEN [Debug] Wireless MAC address:\n"$GREEN
	sleep 1
	sudo ifconfig $wlan down
	sleep 1
	sudo macchanger -a $wlan
	sleep 1
	rfkill unblock all
	sleep 1
	sudo ifconfig $wlan up
	sleep 1
	sudo service network-manager start
	echo -e "\n$GREEN [Debug] Mac Address Spoofing$GREEN [ON]"$RESETCOLOR
	sleep 5
	rfkill unblock all
} 

#stop macchanger eth0
ethmac_stop(){
echo -e "\n$GREEN [Debug] Restoring Mac Address on Ethernet...\n"
	rfkill unblock all
	sleep 3
	sudo service network-manager stop
	sleep 1
	echo -e "$GREEN [Debug] Ethernet MAC address:\n"$GREEN	
	sleep 1
	sudo ifconfig $eth down
	sleep 1
	sudo macchanger -p $eth
	sleep 1
	sudo ifconfig $wlan up
	sleep 1
	sudo service network-manager start
	sleep 1
	echo -e "\n$GREEN [Debug] Mac Address Spoofing$RED [OFF]"$RESETCOLOR
	rfkill unblock all
	sleep 5
}

# wifi macchanger stop
wmac_stop(){
echo -e "\n$GREEN [Debug] Restoring Mac Address on WiFi...\n"
	rfkill unblock all
	sleep 3
	sudo service network-manager stop
	sleep 1
	echo -e "$GREEN [Debug] Wireless MAC address:\n"$GREEN	
	sleep 1
	sudo ifconfig $wlan down
	sleep 1
	sudo macchanger -p $wlan
	sleep 1
	sudo ifconfig $wlan up
	sleep 1
	sudo service network-manager start
	sleep 1
	echo -e "\n$GREEN [Debug] Mac Address Spoofing$RED [OFF]"$RESETCOLOR
	rfkill unblock all
	sleep 5 
}


# edit dhcpd.conf
edit_dhcpd(){
echo -e "\n$RED [Debug] Replacing dhcp.conf, original saved at /etc/dhcp/dhcpd.conf.bak" $RESETCOLOR
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak
cp dhcpd.conf /etc/dhcp/dhcpd.conf
}

# edit isc-dhcp-server
edit_isc_dhcp_server(){
cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.bak
cp isc-dhcp-server /etc/default/isc-dhcp-server
}

# bring down wifi
Wlan_down(){
ifconfig $wlan down
}


# edit interfaces
edit_interfaces(){
echo -e "\n$RED [Debug] Replacing interfaces, original saved at /etc/network/interfaces.bak" $RESETCOLOR
cp /etc/network/interfaces /etc/network/interfaces.bak
cat > /etc/network/interfaces << EOL
auto lo

iface lo inet loopback 
iface $eth inet dhcp

allow-hotplug $wlan

iface $wlan inet static
 address 192.168.42.1
 netmask 255.255.255.0
EOL
}

# wifi up set ip
wlan_up(){
ifconfig $wlan 192.168.42.1
sleep 2
}
# set ssid
set_ssid(){
echo -e "$YELLOW"
read -p " [Debug] Set your router name:" -e name
}

# set password
set_pass(){
read -p "[Debug] Set your password (minimum 8 characters!):" -e pass 
}

# show ssid and pass
cred_show(){
echo -e "\n$YELLOW################################################\n"
echo -e "$RED   You've specified following values:"
echo -e "\n$YELLOW*************************************************\n"
echo -e "$GREEN Router name:$YELLOW $name"
echo -e "$GREEN Password:$YELLOW $pass"
echo -e "\n################################################\n" $RESETCOLOR
sleep 5
}

# set hostapd values
set_hostapd_conf(){
echo -e "\n$RED [Debug] Setting hostapd values, original at /etc/hostapd/hostapd.conf.bak " $RESETCOLOR
cp /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.bak

cat > /etc/hostapd/hostapd.conf << EOL
interface=$wlan
driver=nl80211
ssid=$name
#ieee80211n=1
hw_mode=g
channel=6
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=$pass
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP
wpa_group_rekey=86400
wmm_enabled=1
EOL
}

# hostapd daemon config
set_daemon(){
echo -e "\n$GREEN [Debug] Setting hostapd Daemon." $RESETCOLOR
sed -i "s/#DAEMON_OPTS=\"\"/DAEMON_OPTS=\"\/etc\/hostapd\/hostapd.conf\"/g" /etc/default/hostapd
#sed -i "s/#DAEMON_CONF=\"\"/DAEMON_CONF=\"\/etc\/hostapd\/hostapd.conf\"/g" /etc/default/hostapd
}

# enable ipv4 forwarding
ipv4_forward(){
sed -i "s/#net.ipv4.ip_forward/net.ipv4.ip_forward/g" /etc/sysctl.conf
sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
}

# configure dnsmaq
dnsmasq_config(){
echo -e "\n$GREEN [Debug] Configuring dnsmasq." $RESETCOLOR
cp /etc/dnsmasq.conf /etc/dnsmasq.conf.bak
cat > /etc/dnsmasq.conf << EOL
interface=$wlan      						
listen-address=192.168.42.1					
bind-interfaces      				 
server=8.8.8.8       						
domain-needed        						
bogus-priv           						
dhcp-range=192.168.42.1,192.168.42.150,1200h 	
EOL
}
# replace torrc config
torrc_config(){
echo -e "\n$GREEN [Debug] Upgrading your torrc file." $RESETCOLOR
rm /etc/tor/torrc
cp torrc /etc/tor/torrc
}

# replace privoxy config
privoxy_conig(){
echo -e "\n$GREEN [Debug] Upgrading privoxy config." $RESETCOLOR
rm /etc/privoxy/config
cp config /etc/privoxy/config
}

# setting iptables to use tor 
set_iptables(){
echo -e "\n$GREEN [Debug] Setting your iptables" $RESETCOLOR
eval "iptables -F"
eval "iptables -t nat -F"

eval "iptables -t nat -A POSTROUTING -o $eth -j MASQUERADE"
eval "iptables -A FORWARD -i $eth -o $wlan -m state --state RELATED,ESTABLISHED -j ACCEPT"
eval "iptables -A FORWARD -i $wlan -o $eth -j ACCEPT"
eval "iptables -t nat -A PREROUTING -i $wlan -p tcp --dport 22 -j REDIRECT --to-ports 22"
eval "iptables -t nat -A PREROUTING -i $wlan -p udp --dport 53 -j REDIRECT --to-ports 53"
eval "iptables -t nat -A PREROUTING -i $wlan -p tcp --syn -j REDIRECT --to-ports 9040"
eval "iptables -t nat -A PREROUTING -i $wlan -p tcp --syn -j REDIRECT --to-ports 9050"
sleep 1
}

# start tor
tor_start(){
echo -e "\n$RED [Debug] Starting TOR service." $RESETCOLOR
service tor stop
service tor start
echo -e "\n$GREEN [Success] TOR successfully configured and started." $RESETCOLOR
}

# privoxy start
privoxy_start(){
echo -e "\n$RED [Debug] Starting Privoxy" $RESETCOLOR
service privoxy stop
service privoxy start
echo -e "\n$GREEN [Debug] Privoxy successfully configured and started" $RESETCOLOR
}

restart_services(){
echo -e "\n$RED [Debug] Restarting dhcpd" $RESETCOLOR
service isc-dhcp-server restart
echo -e "\n$GREEN reloading $wlan configuration" $RESETCOLOR
ifconfig $wlan down; ifconfig $wlan up
echo -e "\n$RED Restarting dnsmasq" $RESETCOLOR
/etc/init.d/dnsmasq restart
}

start_hotspot(){
echo -e "\n$GREEN [DEBUG] Starting TOR Hotspot $RED [Ctrl+C to stop]." $RESETCOLOR
#service hostapd start
service dnsmasq start
nmcli radio wifi off
rfkill unblock all
sleep 2
ifconfig $wlan 192.168.42.1
sleep 5
hostapd  /etc/hostapd/hostapd.conf 
#echo -n "\n[ctrl + c] to move process to background"
#echo -e "\n$YELLOW THIS WILL CONTINUE RUNNING IN THE BACKGROUND.... ENJOY!" $RESETCOLOR
sleep 3
}

stop_hotspot(){
echo -e "\n$YELLOW [Debug] Stopping TOR Hotspot."
service tor stop
service hostapd stop
service dnsmasq stop
service privoxy stop
pkill hostapd
rm /etc/network/interfaces
cp /etc/network/interfaces.bak /etc/network/interfaces
rm /etc/default/isc-dhcp-server
cp /etc/default/isc-dhcp-server.bak /etc/default/isc-dhcp-server
rfkill unblock all
sleep 2
service networking restart
sleep 2
service network-manager restart
ifconfig $wlan up
}

# start
echo -e "\n$GREEN [Question] Start TOR Router or Restore?$YELLOW Y $RED or $YELLOW N $RED or $YELLOW RESTORE  : " $RESETCOLOR
read answer
if [ $answer == "Y" ] || [ $answer == "y" ]
then
about
echo -e "\n$YELLOW [Success] Starting TOR Router." $RESETCOLOR
update
requirements
id_iface
set_ether
set_wifi
mac_eth0
mac_wlan0
edit_dhcpd
edit_isc_dhcp_server
Wlan_down
edit_interfaces
wlan_up
set_ssid
set_pass
cred_show
set_hostapd_conf
set_daemon
ipv4_forward
dnsmasq_config
torrc_config
privoxy_conig
set_iptables
tor_start
privoxy_start
restart_services
start_hotspot
elif [ $answer == "RESTORE" ] || [ $answer == "restore" ];then
stop_hotspot
id_iface
set_ether
set_wifi
ethmac_stop
wmac_stop
echo -e "\n$YELLOW [Debug] Reset configuration succesfully." $RESETCOLOR
else
echo -e "\n$YELLOW [Debug] Unexpected response, goodbye." $RESETCOLOR
fi


