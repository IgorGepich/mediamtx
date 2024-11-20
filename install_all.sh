#!/bin/bash

set -e

echo "#########################################################################"
echo "#      THIS SCRIPT WILL SETUP MEDIAMTX ON RASPBERRY WITH RPI CAM        #"
echo "#               CHANGE HOSTNAME FOR rtspserver.local                    #"
echo "#                      CREATE ACCESS POINT                              #"
echo "#########################################################################"

sleep 5

read -n 1 -s -r -p "Press any key to continue..."

git clone https://github.com/IgorGepich/mediamtx.git -b mediamtx

cd mediamtx

wget https://raw.githubusercontent.com/IgorGepich/mediamtx/refs/heads/rpi_config/mediamtx.yml

sudo chmod +x mediamtx

########################## Access point setup #######################

echo "Update and upgrade packets..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y hostapd dnsmasq iptables-persistent


echo "Setup static IP address for wlan0 interface..."
STATIC_IP_CONF="
interface wlan0
static ip_address=192.168.4.1/24
nohook wpa_supplicant
"
echo "$STATIC_IP_CONF" | sudo tee -a /etc/dhcpcd.conf > /dev/null
sudo systemctl restart dhcpcd

echo "Setup hostapd for creating access point..."
HOSTAPD_CONF="
interface=wlan0
ssid=rtsp
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=Rtsprtsp
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
"
echo "$HOSTAPD_CONF" | sudo tee /etc/hostapd/hostapd.conf > /dev/null

echo "Install hostapd configuration..."
sudo sed -i "s|#DAEMON_CONF=\"\"|DAEMON_CONF=\"/etc/hostapd/hostapd.conf\"|" /etc/default/hostapd

echo "Setup dnsmasq..."
DNSMASQ_CONF="
interface=wlan0
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
"
echo "$DNSMASQ_CONF" | sudo tee /etc/dnsmasq.conf > /dev/null

echo "Setup DNS in /etc/resolv.conf..."
RESOLV_CONF="
nameserver 8.8.8.8
nameserver 8.8.4.4
"
echo "$RESOLV_CONF" | sudo tee /etc/resolv.conf > /dev/null

echo "Restart dnsmasq..."
sudo systemctl restart dnsmasq

echo "Setup IPv4..."
sudo sed -i "s|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|" /etc/sysctl.conf
sudo sysctl -p

echo "Setup NAT (Network Address Translation)..."
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"

echo "Creating a script to restore iptables on boot..."
RESTORE_SCRIPT="/etc/network/if-up.d/iptables"
sudo bash -c "cat > $RESTORE_SCRIPT" << EOF
#!/bin/sh
iptables-restore < /etc/iptables.ipv4.nat
EOF
sudo chmod +x $RESTORE_SCRIPT

echo "Applying settings and enabling services..."
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl start hostapd
sudo systemctl enable dnsmasq
sudo systemctl start dnsmasq

echo "Setup complete. Wi-Fi hotspot is set up...."

echo "#########################################################################"
echo "#               SSID: rtsp                                              #"
echo "#               pass: Rtsprtsp                                          #"
echo "#########################################################################"

sleep 5

read -n 1 -s -r -p "Press any key to continue..."

####################################################################

echo "New HOSTNAME"
NEW_HOSTNAME="rtspserver.local"

echo "Setting hostname"
sudo hostnamectl set-hostname "$NEW_HOSTNAME"

echo "Update file /etc/hostname"
echo "$NEW_HOSTNAME" | sudo tee /etc/hostname > /dev/null

echo "Update file /etc/hosts"
sudo sed -i "s/127\.0\.1\.1\s.*/127.0.1.1 $NEW_HOSTNAME/" /etc/hosts

echo "Hostname has changed '$NEW_HOSTNAME'. Device will be reboot in 10 seconds."

echo "#########################################################################"
echo "#               YOUR HOSTNAME IS rtspserver.local                       #"
echo "#########################################################################"

sleep 5

read -n 1 -s -r -p "Press any key to reboot"

sudo reboot