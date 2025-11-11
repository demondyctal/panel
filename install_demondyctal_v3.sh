#!/bin/bash
echo "🧱 Installing Demondyctal Panel..."
sleep 1
apt update -y
apt install -y nodejs npm nginx postgresql redis-server -y
systemctl enable postgresql redis-server
cd /var/www/demondyctal/panel || exit
npm install
npm run start &
echo "✅ Demondyctal Panel Installed Successfully"
echo "Visit: https://dannymc.fun"
