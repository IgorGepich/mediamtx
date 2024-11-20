#!/bin/bash

GREEN='\e[32m'
RED='\e[31m'
RESET='\e[0m'

echo -e "${GREEN}New HOSTNAME${RESET}\n"
NEW_HOSTNAME="rtspserver.local"

echo -e "${GREEN}Setting hostname${RESET}\n"
sudo hostnamectl set-hostname "$NEW_HOSTNAME"

echo -e "${GREEN}Update file /etc/hostname${RESET}\n"
echo "$NEW_HOSTNAME" | sudo tee /etc/hostname > /dev/null

echo -e "${GREEN}Update file /etc/hosts${RESET}\n"
sudo sed -i "s/127\.0\.1\.1\s.*/127.0.1.1 $NEW_HOSTNAME/" /etc/hosts

echo -e "${GREEN}Hostname has changed. Device must be reboot.${RESET}\n"

echo -e "${GREEN}#########################################################################${RESET}\n"
echo -e "${GREEN}#               YOUR HOSTNAME IS '$NEW_HOSTNAME'                        #${RESET}\n"
echo -e "${GREEN}#########################################################################${RESET}\n"

sleep 5

echo -e "${RED}Press any key to continue...${RESET}\n"
read -n 1 -s -r