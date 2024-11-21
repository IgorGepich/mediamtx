#!/bin/bash

GREEN='\e[32m'
RED='\e[31m'
RESET='\e[0m'

source ./logging.sh

USERNAME=$(whoami)
SCRIPT_PATH="/home/$USERNAME/mediamtx/mediamtx"

log_info "Script started."

echo -e "\n${RED}Do you want to create a systemd service for the RTCP and WEBRTC stream script? (y/n): ${RESET}"

attempt=0
while [[ $attempt -lt 3 ]]; do
    read -n 1 choice
    echo

    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        log_info "User chose to create the systemd service."

        echo -e "${GREEN}Creating systemd service...${RESET}"

        SERVICE_FILE="/etc/systemd/system/mediamtx.service"

        if [[ ! -f "$SCRIPT_PATH" ]]; then
            log_error "Script '$SCRIPT_PATH' not found. Exiting."
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

        log_info "Systemd service file created at '$SERVICE_FILE'."

        echo -e "${GREEN}Reloading systemd and enabling the service...${RESET}"
        sudo systemctl daemon-reload
        sudo systemctl enable mediamtx.service
        sudo systemctl start mediamtx.service

        log_info "Service 'mediamtx' started successfully."

        echo -e "${GREEN}Service 'mediamtx' created and started successfully.${RESET}"
        break

    elif [[ "$choice" == "n" || "$choice" == "N" ]]; then
        log_info "User chose to skip service creation."
        echo -e "${RED}Skipping service creation.${RESET}"
        break
    else
        ((attempt++))
        if [[ $attempt -lt 3 ]]; then
            log_error "Invalid input. Attempt $attempt of 3."
            echo -e "${RED}Invalid input. Please enter 'y' or 'n' (${attempt}/3 attempts).${RESET}"
        else
            log_error "Maximum attempts reached. Exiting."
            echo -e "${RED}Maximum attempts reached. Exiting.${RESET}"
            exit 1
        fi
    fi
done

log_info "Script completed."

echo -e "\n${RED}Press any key to continue...${RESET}\n"
read -n 1 -s -r