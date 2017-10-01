#!/bin/bash
set -euo pipefail
pwd
cd "${BASH_SOURCE%/*}" || exit 
pwd

# Install nginx.
apt-get update
apt-get install -y nginx sshguard nano curl # vim

# Ensure website directory exists
mkdir -p /var/www/mywebsite

# Copy nginx config files (main config and vhost config)
cp /tmp/config/nginx.conf /etc/nginx/nginx.conf
chown root:root /etc/nginx/nginx.conf
chmod 0644 /etc/nginx/nginx.conf

cp /tmp/config/mywebsite.conf /etc/nginx/conf.d/mywebsite.conf
chown root:root /etc/nginx/conf.d/mywebsite.conf
chmod 0644 /etc/nginx/conf.d/mywebsite.conf

# Copy our website files
cp /tmp/config/index.html /var/www/mywebsite/
chown root:root /var/www/mywebsite/index.html
chmod 0644 /var/www/mywebsite/index.html

# Remove default nginx vhost configuration
rm /etc/nginx/sites-enabled/default

# Start nginx at boot + make sure it's running right now.
systemctl restart nginx.service
systemctl enabled nginx.service

# On a machine with systemd, you'd use these instead
# systemctl enable nginx
# systemctl restart nginx

