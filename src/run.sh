#!/bin/bash
export YELLOW='\033[1;93m'
export GREEN='\033[1;92m'
export RED='\033[1;91m'
export RESETCOLOR='\033[1;00m'


echo -e "\n$YELLOW----------- TOR Router ---------------\n" $RESETCOLOR
echo -e "\n$RED Do you want to \n1. Hotspot\n2. Reverse-Tether" $RESETCOLOR
read answer
if [ $answer == "1" ]
then
echo -e "\n$GREEN Hotspotting..." $RESETCOLOR
bash ./wireless-hotspot.sh
else [ $answer == "2"]
echo -e "\n$GREEN Reverse Tethering..." $RESETCOLOR
bash ./reverse-tether.sh
fi