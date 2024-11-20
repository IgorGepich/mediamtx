#!/bin/bash

# Цвета
GREEN='\e[32m'
RESET='\e[0m'

echo -e "${GREEN}Starting the stream setup...${RESET}\n"
./stream_setup.sh

echo -e "${GREEN}Stream setup completed. Starting the changing hostname...${RESET}\n"
./change_hostname.sh

echo -e "${GREEN}Hostname changing completed. Starting access point setup...${RESET}\n"
./rpi_access_point_setup.sh

echo -e "${GREEN}All scripts completed successfully!${RESET}\n"

echo -e "${RED}Press any key to reboot...${RESET}"
read -n 1 -s -r

sudo reboot