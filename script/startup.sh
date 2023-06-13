#!/bin/bash

EMAIL="seifeldin.sabry@student.kdg.be"
DOMAINS="mocanupaulc.com,www.mocanupaulc.com"

apt update && sudo apt upgrade -y
sudo curl -sL https://deb.nodesource.com/setup_current.x | sudo -E bash -
sudo apt-get install -y nodejs
apt-get install -y vite postgresql postgresql-contrib git nginx certbot python3-certbot-nginx
service postgresql start
ufw allow 80
ufw allow 443
ufw allow 22
nginx -t
ufw enable
git clone https://github.com/Seifeldin-Sabry/chatapp-infra.git /chatapp-infra
git config --global --add safe.directory /chatapp-infra
gsutil cp -r gs://chatapp-infra/public /chatapp-infra/frontend/public
cp /chatapp-infra/script/systemd_backend.service /etc/systemd/system/chatapp-backend.service
cp /chatapp-infra/script/systemd_frontend.service /etc/systemd/system/chatapp-frontend.service
cp /chatapp-infra/script/nginx_config /etc/nginx/sites-available/default
systemctl daemon-reload
systemctl restart nginx
certbot --nginx --non-interactive -m $EMAIL --agree-tos --domains=$DOMAINS
systemctl start chatapp-backend.service
systemctl start chatapp-frontend.service
