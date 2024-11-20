git clone https://github.com/IgorGepich/mediamtx.git -b mediamtx

cd mediamtx

wget https://raw.githubusercontent.com/IgorGepich/mediamtx/refs/heads/rpi_config/mediamtx.yml

sudo chmod +x mediamtx

# New HOSTNAME
NEW_HOSTNAME="compute"

# Setting hostname
sudo hostnamectl set-hostname "$NEW_HOSTNAME"

# Update file /etc/hostname
echo "$NEW_HOSTNAME" | sudo tee /etc/hostname > /dev/null

# Update file /etc/hosts
sudo sed -i "s/127\.0\.1\.1\s.*/127.0.1.1 $NEW_HOSTNAME/" /etc/hosts

echo "Hostname has changed '$NEW_HOSTNAME'. Device will be reboot in 10 seconds."

sleep 10

sudo reboot