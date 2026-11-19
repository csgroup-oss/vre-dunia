#!/bin/bash
# Copyright 2024 CS GROUP - France, http://www.c-s.fr
# All rights reserved

set -e

mkdir /opt/s3-browser
cp -pr resources/s3-browser/backend /opt/s3-browser/back
cd /opt/s3-browser/back
npm install --omit-dev
npm run build
cd "$HOME"

cp -pr resources/s3-browser/frontend /opt/s3-browser/frontend
cd /opt/s3-browser/frontend
npm install
npm run build
mkdir -p /var/www/
# nginx (apt.txt) already created its default /var/www/html
rm -rf /var/www/html
mv dist/s3-browser-frontend /var/www/html
rm -rf /opt/s3-browser/frontend
cd "$HOME"

cp resources/s3-browser/start-s3-browser.sh /usr/local/bin/start-notebook-s3-browser.sh

# RUN touch /var/run/nginx.pid
chmod 666 /etc/nginx/nginx.conf
chmod 755 /etc/init.d/nginx
chmod 755 /var/log/nginx

cp -p resources/s3-browser/frontend-nginx/nginx.conf /etc/nginx/nginx.conf
cp -p resources/s3-browser/frontend-nginx/startup.sh /opt/s3-browser/
npm i -g forever
