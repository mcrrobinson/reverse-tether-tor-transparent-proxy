# reverse-tether-tor-transparent-proxy
Reverse tether a internet connection running through TOR as a transparent proxy.

The benefit of this as there doesn't seem to be a transparent proxy varient on android for TOR (only a browser) so it will be a cheap and quick solution to transmitting all informaiton through TOR including ALL application data.

# Permanant Instllation

```
~$ git clone https://github.com/mcrrobinson/reverse-tether-tor-transparent-proxy.git && cd src && sudo bash install.sh
```

```
sudo docker build . -t "RTTRP"
sudo docker run RTTRP -it bash
```
