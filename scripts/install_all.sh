#!/bin/bash

GREEN='\e[32m'
RESET='\e[0m'

echo -e "\n${GREEN}Starting the stream setup...${RESET}\n"
./stream_setup.sh

echo -e "\n${GREEN}Stream setup completed. Starting the changing hostname...${RESET}\n"
./change_hostname.sh

echo -e \n"${GREEN}Hostname changing completed. Starting access point setup...${RESET}\n"
./rpi_access_point_setup.sh

echo -e "\n${GREEN}All scripts completed successfully!${RESET}\n"

rm -- "$0"

echo -e "\n${RED}Press any key to reboot...${RESET}"

read -n 1 -s -r

sudo reboot