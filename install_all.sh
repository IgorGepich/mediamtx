#!/bin/bash

# Цвета
GREEN='\e[32m'
RESET='\e[0m'

echo -e "${GREEN}Starting the first script...${RESET}"
# Запуск первого скрипта
./first_script.sh

echo -e "${GREEN}First script completed. Starting the second script...${RESET}"
# Запуск второго скрипта
./second_script.sh

echo -e "${GREEN}Second script completed. Starting the third script...${RESET}"
# Запуск третьего скрипта
./third_script.sh

echo -e "${GREEN}All scripts completed successfully!${RESET}"