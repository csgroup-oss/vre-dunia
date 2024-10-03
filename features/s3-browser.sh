#!/bin/sh -e

mkdir /opt/s3-browser
cp -pr resources/s3-browser/backend /opt/s3-browser/back
cd /opt/s3-browser/back
npm install --omit-dev
npm run build
cd -

mkdir /var/www/
cp -pr resources/s3-browser/frontend /opt/s3-browser/frontend
cd /opt/s3-browser/frontend
npm install
npm run build
mv dist/s3-browser-frontend /var/www/html
rm -rf /opt/s3-browser/frontend
cd -

cp resources/s3-browser/start-s3-browser.sh /usr/local/bin/start-notebook-s3-browser.sh

apt-get update --quiet
apt-get install --quiet --yes --no-install-recommends nginx

# RUN touch /var/run/nginx.pid
chmod 666 /etc/nginx/nginx.conf
chmod 755 /etc/init.d/nginx
chmod 755 /var/log/nginx

cp -p resources/s3-browser/frontend-nginx/nginx.conf /etc/nginx/nginx.conf
cp -p resources/s3-browser/frontend-nginx/startup.sh /opt/s3-browser/
npm i -g forever
