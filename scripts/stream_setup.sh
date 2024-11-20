#!/bin/bash

set -e

GREEN='\e[32m'
RESET='\e[0m'
RED='\e[31m'

echo -e "${GREEN}#########################################################################${RESET}"
echo -e "${GREEN}#      THIS SCRIPT WILL SETUP MEDIAMTX ON RASPBERRY WITH RPI CAM        #${RESET}"
echo -e "${GREEN}#########################################################################${RESET}\n"

sleep 5

echo -e "${RED}Press any key to continue...${RESET}"
read -n 1 -s -r

cd ..

cd mediamtx

wget https://raw.githubusercontent.com/IgorGepich/mediamtx/refs/heads/rpi_config/mediamtx.yml

sudo chmod +x mediamtx