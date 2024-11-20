#!/bin/bash

GREEN='\e[32m'
RESET='\e[0m'
RED='\e[31m'

echo -e "${GREEN}#########################################################################${RESET}"
echo -e "${GREEN}#               CREATING ACCESS POINT                                    ${RESET}"
echo -e "${GREEN}#########################################################################${RESET}\n"


echo -e "${GREEN}Enter SSID for the Wi-Fi hotspot:${RESET}"
read SSID
echo -e "${GREEN}Enter password for the Wi-Fi hotspot (at least 8 characters long):${RESET}"
read -sp "" PASSWORD
echo

if [ ${#PASSWORD} -lt 8 ]; then
    echo -e "${GREEN}Error: Password must be at least 8 characters long.${RESET}"
    exit 1
fi

echo -e "${GREEN}Update and upgrade packets...${RESET}"
sudo apt update && sudo apt upgrade -y
sudo apt install -y hostapd dnsmasq iptables-persistent

echo -e "${GREEN}Setup static IP address for wlan0 interface...${RESET}"
STATIC_IP_CONF="
interface wlan0
static ip_address=192.168.4.1/24
nohook wpa_supplicant
"
echo "$STATIC_IP_CONF" | sudo tee -a /etc/dhcpcd.conf > /dev/null
sudo systemctl restart dhcpcd

echo -e "${GREEN}Setup hostapd for creating access point...${RESET}"
HOSTAPD_CONF="
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
echo "$HOSTAPD_CONF" | sudo tee /etc/hostapd/hostapd.conf > /dev/null

echo -e "${GREEN}Install hostapd configuration...${RESET}"
sudo sed -i "s|#DAEMON_CONF=\"\"|DAEMON_CONF=\"/etc/hostapd/hostapd.conf\"|" /etc/default/hostapd

echo -e "${GREEN}Setup dnsmasq...${RESET}"
DNSMASQ_CONF="
interface=wlan0
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
"
echo "$DNSMASQ_CONF" | sudo tee /etc/dnsmasq.conf > /dev/null

echo -e "${GREEN}Setup DNS in /etc/resolv.conf...${RESET}"
RESOLV_CONF="
nameserver 8.8.8.8
nameserver 8.8.4.4
"
echo "$RESOLV_CONF" | sudo tee /etc/resolv.conf > /dev/null

echo -e "${GREEN}Restart dnsmasq...${RESET}"
sudo systemctl restart dnsmasq

echo -e "${GREEN}Setup IPv4...${RESET}"
sudo sed -i "s|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|" /etc/sysctl.conf
sudo sysctl -p

echo -e "${GREEN}Setup NAT (Network Address Translation)...${RESET}"
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"

echo -e "${GREEN}Creating a script to restore iptables on boot...${RESET}"
RESTORE_SCRIPT="/etc/network/if-up.d/iptables"
sudo bash -c "cat > $RESTORE_SCRIPT" << EOF
#!/bin/sh
iptables-restore < /etc/iptables.ipv4.nat
EOF
sudo chmod +x $RESTORE_SCRIPT

echo -e "${GREEN}Applying settings and enabling services...${RESET}"
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl start hostapd
sudo systemctl enable dnsmasq
sudo systemctl start dnsmasq

echo -e "${GREEN}Setup complete. Wi-Fi hotspot is set up with SSID '$SSID' and the provided password.${RESET}\n"

echo -e "${GREEN}#########################################################################${RESET}"
echo -e "${GREEN}#               SSID: '$SSID'                                            ${RESET}"
echo -e "${GREEN}#               pass: '$PASSWORD'                                        ${RESET}"
echo -e "${GREEN}#########################################################################${RESET}\n"

cd .. && rm -rf scripts/

sleep 5

echo -e "${RED}Press any key to continue...${RESET}\n"
read -n 1 -s -r
