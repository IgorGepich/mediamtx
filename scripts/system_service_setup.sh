#!/bin/bash

GREEN='\e[32m'
RED='\e[31m'
RESET='\e[0m'

USERNAME=$(whoami)
SCRIPT_PATH="/home/$USERNAME/mediamtx/mediamtx"

echo -e "${GREEN}Do you want to create a systemd service for the 'mediamtx' script? (y/n): ${RESET}"

attempt=0
while [[ $attempt -lt 3 ]]; do
    read -n 1 choice
    echo

    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        echo -e "${GREEN}Creating systemd service...${RESET}"

        SERVICE_FILE="/etc/systemd/system/mediamtx.service"


        if [[ ! -f "$SCRIPT_PATH" ]]; then
            echo -e "${RED}Error: Script '$SCRIPT_PATH' not found. Exiting.${RESET}"
            exit 1
        fi

        sudo bash -c "cat > $SERVICE_FILE" << EOF
[Unit]
Description=MediaMTX Stream Service
After=network.target

[Service]
Type=simple
User=$USERNAME
WorkingDirectory=/home/$USERNAME/mediamtx
ExecStart=/usr/bin/env $SCRIPT_PATH
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

        echo -e "${GREEN}Reloading systemd and enabling the service...${RESET}"
        sudo systemctl daemon-reload
        sudo systemctl enable mediamtx.service
        sudo systemctl start mediamtx.service

        echo -e "${GREEN}Service 'mediamtx' created and started successfully.${RESET}"
        break

    elif [[ "$choice" == "n" || "$choice" == "N" ]]; then
        echo -e "${RED}Skipping service creation.${RESET}"
        break
    else
        ((attempt++))
        if [[ $attempt -lt 3 ]]; then
            echo -e "${RED}Invalid input. Please enter 'y' or 'n' (${attempt}/3 attempts).${RESET}"
        else
            echo -e "${RED}Maximum attempts reached. Exiting.${RESET}"
            exit 1
        fi
    fi
done

echo -e "\n${RED}Press any key to continue...${RESET}\n"
read -n 1 -s -r
