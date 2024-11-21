#!/bin/bash

GREEN='\e[32m'
RED='\e[31m'
RESET='\e[0m'

# Log file setup
LOGFILE="access_point_setup.log"
LOG_TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

MAX_ATTEMPTS=3
attempts=0

log_info() {
    echo -e "${GREEN}[$LOG_TIMESTAMP] INFO: $1${RESET}"
    echo "[$LOG_TIMESTAMP] INFO: $1" >> "$LOGFILE"
}

log_error() {
    echo -e "${RED}[$LOG_TIMESTAMP] ERROR: $1${RESET}"
    echo "[$LOG_TIMESTAMP] ERROR: $1" >> "$LOGFILE"
}

log_info "Starting Wi-Fi hotspot setup..."

echo -e "${GREEN}Enter SSID for the Wi-Fi hotspot:${RESET}"
read SSID
log_info "User entered SSID: $SSID"

while [ $attempts -lt $MAX_ATTEMPTS ]; do
    echo -e "${GREEN}Enter password for the Wi-Fi hotspot (at least 8 characters long):${RESET}"
    read -sp "" PASSWORD
    echo

    if [ ${#PASSWORD} -ge 8 ]; then
        log_info "User entered a valid password."
        echo -e "${GREEN}Password accepted.${RESET}\n"
        break
    else
        log_error "Password must be at least 8 characters long."
        echo -e "${RED}Invalid password. Try again.${RESET}\n"
        ((attempts++))
    fi

    if [ $attempts -eq $MAX_ATTEMPTS ]; then
        log_error "User failed to enter a valid password in $MAX_ATTEMPTS attempts."
        echo -e "${RED}Maximum attempts reached. Exiting...${RESET}\n"
        exit 1
    fi
done

log_info "Updating and upgrading packets..."
if sudo apt update && sudo apt upgrade -y; then
    log_info "System updated and upgraded successfully."
else
    log_error "Failed to update and upgrade packets."
    exit 1
fi

log_info "Installing required packages..."
if sudo apt install -y hostapd dnsmasq iptables-persistent; then
    log_info "Required packages installed successfully."
else
    log_error "Failed to install required packages."
    exit 1
fi

log_info "Setting static IP address for wlan0 interface..."
STATIC_IP_CONF="
interface wlan0
static ip_address=192.168.4.1/24
nohook wpa_supplicant
"
if echo "$STATIC_IP_CONF" | sudo tee -a /etc/dhcpcd.conf > /dev/null && sudo systemctl restart dhcpcd; then
    log_info "Static IP address set successfully."
else
    log_error "Failed to set static IP address."
    exit 1
fi

log_info "Configuring hostapd..."
HOSTAPD_CONF="
country_code=US
interface=wlan0
ssid=$SSID
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=$PASSWORD
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
"
if echo "$HOSTAPD_CONF" | sudo tee /etc/hostapd/hostapd.conf > /dev/null; then
    log_info "Hostapd configured successfully."
else
    log_error "Failed to configure hostapd."
    exit 1
fi

log_info "Installing hostapd configuration..."
if sudo sed -i "s|#DAEMON_CONF=\"\"|DAEMON_CONF=\"/etc/hostapd/hostapd.conf\"|" /etc/default/hostapd; then
    log_info "Hostapd configuration installed."
else
    log_error "Failed to install hostapd configuration."
    exit 1
fi

log_info "Configuring dnsmasq..."
DNSMASQ_CONF="
interface=wlan0
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
"
if echo "$DNSMASQ_CONF" | sudo tee /etc/dnsmasq.conf > /dev/null; then
    log_info "Dnsmasq configured successfully."
else
    log_error "Failed to configure dnsmasq."
    exit 1
fi

log_info "Setting up DNS in /etc/resolv.conf..."
RESOLV_CONF="
nameserver 8.8.8.8
nameserver 8.8.4.4
"
if echo "$RESOLV_CONF" | sudo tee /etc/resolv.conf > /dev/null; then
    log_info "DNS configuration updated."
else
    log_error "Failed to update DNS configuration."
    exit 1
fi

log_info "Restarting dnsmasq..."
if sudo systemctl restart dnsmasq; then
    log_info "Dnsmasq restarted successfully."
else
    log_error "Failed to restart dnsmasq."
    exit 1
fi

log_info "Enabling IPv4 forwarding..."
if sudo sed -i "s|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|" /etc/sysctl.conf && sudo sysctl -p; then
    log_info "IPv4 forwarding enabled."
else
    log_error "Failed to enable IPv4 forwarding."
    exit 1
fi

log_info "Setting up NAT (Network Address Translation)..."
if sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE && sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"; then
    log_info "NAT setup completed successfully."
else
    log_error "Failed to set up NAT."
    exit 1
fi

log_info "Creating script to restore iptables on boot..."
RESTORE_SCRIPT="/etc/network/if-up.d/iptables"
if sudo bash -c "cat > $RESTORE_SCRIPT" << EOF
#!/bin/sh
iptables-restore < /etc/iptables.ipv4.nat
EOF
    sudo chmod +x $RESTORE_SCRIPT; then
    log_info "Restore script created successfully."
else
    log_error "Failed to create restore script."
    exit 1
fi

log_info "Applying settings and enabling services..."
if sudo systemctl unmask hostapd && sudo systemctl enable hostapd && sudo systemctl start hostapd && sudo systemctl enable dnsmasq && sudo systemctl start dnsmasq; then
    log_info "All settings applied and services enabled successfully."
else
    log_error "Failed to apply settings or enable services."
    exit 1
fi

log_info "Setup complete. Wi-Fi hotspot is set up with SSID '$SSID'."
log_info "SSID: $SSID, Password: $PASSWORD"

echo -e "\n${GREEN}#########################################################################${RESET}"
echo -e "${GREEN}                SSID: '$SSID'                                            ${RESET}"
echo -e "${GREEN}                pass: '$PASSWORD'                                        ${RESET}"
echo -e "${GREEN}#########################################################################${RESET}\n"

#cd .. && rm -rf scripts/

sleep 5

log_info "Setup complete. User prompted to continue."

echo -e "\n${RED}Press any key to continue...${RESET}\n"
read -n 1 -s -r
log_info "User pressed a key. Setup complete."