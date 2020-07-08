# reverse-tether-tor-transparent-proxy
Reverse tether a internet connection running through TOR as a transparent proxy.

The benefit of this as there doesn't seem to be a transparent proxy varient on android for TOR (only a browser) so it will be a cheap and quick solution to transmitting all informaiton through TOR including ALL application data.

# Permanant Instllation

```
~$ git clone https://github.com/mcrrobinson/reverse-tether-tor-transparent-proxy.git && cd src && sudo bash install.sh
```

# Single use Installation.

In distros using systemd, you should consideer using the install.sh script, anyways the process to install/configure tor-router is described here.

**It script require root privileges**

1. Open a terminal and clone the script using the following command:
```
~$ git clone https://github.com/mcrrobinson/reverse-tether-tor-transparent-proxy.git && cd tor-router/files
```
2. Put the following lines at the end of /etc/tor/torrc
```
# Seting up TOR transparent proxy for tor-router
VirtualAddrNetwork 10.192.0.0/10
AutomapHostsOnResolve 1
TransPort 9040
DNSPort 5353
```
3. Restart the tor service
4. Execute the tor-router script as root
```
# sudo ./tor-router
```
5. Now all your traffic is under TOR, you can check that in the following pages: https://check.torproject.org and for DNS tests: https://dnsleaktest.com 
6. In order to automate the process of the script, you should add it to the SYSTEM autostart scripts according that the init that you are using, for systemd we have a .service file in the *files* folder.