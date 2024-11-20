#!/bin/bash

GREEN='\e[32m'
RED='\e[31m'
RESET='\e[0m'

set -e

echo "${GREEN}#########################################################################${RESET}"
echo "${GREEN}#      THIS SCRIPT WILL SETUP MEDIAMTX ON RASPBERRY WITH RPI CAM        #${RESET}"
echo "${GREEN}#               CHANGE HOSTNAME FOR rtspserver.local                    #${RESET}"
echo "${GREEN}#                      CREATE ACCESS POINT                              #${RESET}"
echo "${GREEN}#########################################################################${RESET}"


git clone --branch script https://github.com/IgorGepich/mediamtx.git

cd mediamtx

cd scripts

rm -rf clone.sh

cd ..

mv scripts ..

cd ..

rm -rf mediamtx/

git clone --branch mediamtx https://github.com/IgorGepich/mediamtx.git

cd scripts

./install_all.sh