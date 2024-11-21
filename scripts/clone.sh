#!/bin/bash

GREEN='\e[32m'
RED='\e[31m'
RESET='\e[0m'
SCRIPT_PATH=$(realpath "$0")

set -e

echo -e "\n${GREEN}#########################################################################${RESET}"
echo -e "${GREEN}#      THIS SCRIPT WILL SETUP RTSP AND WEBRTC STREAM ON UNIX SYSTEM     #${RESET}"
echo -e "${GREEN}#               CHANGE HOSTNAME FOR rtspserver.local                    #${RESET}"
echo -e "${GREEN}#                      CREATE ACCESS POINT                              #${RESET}"
echo -e "${GREEN}#########################################################################${RESET}\n"

git clone --branch script https://github.com/IgorGepich/mediamtx.git

cd mediamtx && mv scripts .. && cd .. && rm -rf mediamtx/

git clone --branch mediamtx https://github.com/IgorGepich/mediamtx.git

cd scripts && chmod +x *.sh

./install_all.sh

cd ..

#cd $(dirname "$SCRIPT_PATH") && rm -- "$SCRIPT_PATH"
#(
#    sleep 2
#    rm -- "$SCRIPT_PATH"
#) &

rm -- "$0"

echo -e "${RED}Press any key to reboot...${RESET}\n"
read -n 1 -s -r
sudo reboot
