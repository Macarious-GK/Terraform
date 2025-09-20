#!/bin/bash
set -xe

# Terraform will inject this
LB_URL="${lb_url}"

# Update system
apt-get update -y
apt-get upgrade -y

# Install Nginx
apt-get install -y nginx

# Backup default config
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak

# Write new Nginx config
cat > /etc/nginx/nginx.conf <<EOL
user www-data;
worker_processes auto;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    sendfile        on;
    keepalive_timeout  65;

    access_log  /var/log/nginx/access.log;
    error_log   /var/log/nginx/error.log;

    server {
        listen 80;

        location / {
            proxy_pass http://$LB_URL;
            proxy_http_version 1.1;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
}
EOL

# Enable and restart Nginx
systemctl enable nginx
systemctl restart nginx
