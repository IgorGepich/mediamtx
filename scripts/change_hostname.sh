#!/bin/bash

GREEN='\e[32m'
RED='\e[31m'
RESET='\e[0m'

# Log file setup
LOGFILE="hostname_change.log"
LOG_TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

log_info() {
    echo -e "${GREEN}[$LOG_TIMESTAMP] INFO: $1${RESET}"
    echo "[$LOG_TIMESTAMP] INFO: $1" >> "$LOGFILE"
}

log_error() {
    echo -e "${RED}[$LOG_TIMESTAMP] ERROR: $1${RESET}"
    echo "[$LOG_TIMESTAMP] ERROR: $1" >> "$LOGFILE"
}

log_info "Starting hostname setup..."

echo -e "\n${GREEN}New HOSTNAME${RESET}\n"
NEW_HOSTNAME="rtspserver.local"

log_info "Setting hostname to '$NEW_HOSTNAME'"

echo -e "${GREEN}Setting hostname${RESET}\n"
if sudo hostnamectl set-hostname "$NEW_HOSTNAME"; then
    log_info "Hostname set to '$NEW_HOSTNAME'."
else
    log_error "Failed to set hostname."
    exit 1
fi

log_info "Updating /etc/hostname file..."

echo -e "${GREEN}Update file /etc/hostname${RESET}\n"
if echo "$NEW_HOSTNAME" | sudo tee /etc/hostname > /dev/null; then
    log_info "/etc/hostname updated."
else
    log_error "Failed to update /etc/hostname."
    exit 1
fi

log_info "Updating /etc/hosts file..."

echo -e "${GREEN}Update file /etc/hosts${RESET}\n"
if sudo sed -i "s/127\.0\.1\.1\s.*/127.0.1.1 $NEW_HOSTNAME/" /etc/hosts; then
    log_info "/etc/hosts updated."
else
    log_error "Failed to update /etc/hosts."
    exit 1
fi

log_info "Hostname has been changed successfully. A reboot is required."

echo -e "${GREEN}Hostname has changed. Device must be reboot.${RESET}\n"

log_info "Displaying hostname: $NEW_HOSTNAME"

echo -e "\n${GREEN}#########################################################################${RESET}"
echo -e "${GREEN}                YOUR HOSTNAME IS '$NEW_HOSTNAME'                         ${RESET}"
echo -e "${GREEN}#########################################################################${RESET}\n"

sleep 5

log_info "Prompting user to continue with reboot."

echo -e "\n${RED}Press any key to continue...${RESET}\n"
read -n 1 -s -r

log_info "User pressed a key, continuing."