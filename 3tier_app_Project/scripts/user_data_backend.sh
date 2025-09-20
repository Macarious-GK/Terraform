#!/bin/bash
apt update -y
apt install -y nginx
systemctl enable nginx
systemctl start nginx

# Replace the Nginx default index page with hostname info
echo "<h1>backend from $(hostname)</h1>" > /var/www/html/index.html