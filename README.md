# reverse-tether-tor-transparent-proxy
Reverse tether a internet connection running through TOR as a transparent proxy.

The benefit of this as there doesn't seem to be a transparent proxy varient on android for TOR (only a browser) so it will be a cheap and quick solution to transmitting all informaiton through TOR including ALL application data.

# Permanant Instllation

```
~$ git clone https://github.com/mcrrobinson/reverse-tether-tor-transparent-proxy.git && cd src && sudo bash install.sh
```

```
cd reverse-tether-tor-transparent-proxy
sudo docker build . -t "RTTRP"
sudo docker run RTTRP -it bash
```
The end goal is to get a commandline application in which the user is intially able to install in a docker container the TOR enviroment in which can then reverse tether an internet connection or run through a Wireless interface as a hotspot through the TOR proxy. Additionally the application should change the MAC address of the device being routed. There should be a second part of the application for tests to test DNS leakage.
