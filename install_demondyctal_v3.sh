#!/bin/bash
# 💠 Demondyctal Installer v3.1 (IPv4 + IPv6 Support)
# Author: Yuvraj (demondyctal)

set -e

echo "======================================="
echo "💠 Demondyctal Auto Installer v3.1"
echo "======================================="

echo
echo "1) Install Panel"
echo "2) Install Wings"
echo "3) Uninstall Components"
echo "4) Exit"
echo
read -p "Select an option [1-4]: " opt

case $opt in
1)
  echo "🧱 Installing Demondyctal Panel..."
  apt update -y
  apt install -y curl git nodejs npm postgresql postgresql-contrib redis-server nginx certbot python3-certbot-nginx unzip -y
  systemctl enable postgresql redis-server
  systemctl start postgresql redis-server
  mkdir -p /var/www/demondyctal/panel
  cd /var/www/demondyctal/panel
  git clone https://github.com/demondyctal/panel.git . || true
  npm install
  nohup npm run start &
  echo "✅ Panel backend started on port 8080"
  echo
  read -p "Enter your domain (e.g. dannymc.fun): " domain
  echo "🔧 Setting up Nginx for $domain"
  cat > /etc/nginx/sites-available/demondyctal.conf <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name $domain;

    root /var/www/demondyctal/web/dist;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:8080/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
    }
}
EOF
  ln -sf /etc/nginx/sites-available/demondyctal.conf /etc/nginx/sites-enabled/
  nginx -t && systemctl restart nginx
  echo "🔐 Getting SSL certificate..."
  certbot --nginx -d $domain --preferred-challenges http --register-unsafely-without-email --agree-tos
  echo "✅ Installation Complete!"
  echo "Visit: https://$domain"
  ;;
2)
  echo "🪽 Installing Wings..."
  mkdir -p /opt/demondyctal/wings
  cd /opt/demondyctal/wings
  git clone https://github.com/demondyctal/wings.git . || true
  npm install
  nohup npm start &
  echo "✅ Wings service started on port 8081"
  ;;
3)
  echo "🗑️ Uninstall Menu"
  echo "1) Remove Panel"
  echo "2) Remove Wings"
  echo "3) Full Cleanup"
  read -p "Select [1-3]: " del
  case $del in
    1)
      echo "Removing Panel..."
      rm -rf /var/www/demondyctal/panel
      systemctl stop nginx
      ;;
    2)
      echo "Removing Wings..."
      rm -rf /opt/demondyctal/wings
      ;;
    3)
      echo "Full cleanup..."
      rm -rf /var/www/demondyctal /opt/demondyctal
      ;;
  esac
  echo "✅ Done."
  ;;
4)
  echo "👋 Exit"
  exit 0
  ;;
*)
  echo "❌ Invalid choice"
  ;;
esac
