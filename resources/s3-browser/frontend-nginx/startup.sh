#/bin/bash
# Copyright 2024 CS GROUP - France, http://www.c-s.fr
# All rights reserved

set -e

echo "[INFO] Starting nginx..."
USER=$(echo ${HOME##*/})
if [ ! $USER = "root" ]; then
  NGINX_DIR=$HOME/.config/nginx
  rm -rf $NGINX_DIR
  mkdir -p $NGINX_DIR
  rsync -a /etc/nginx $HOME/.config
else
  NGINX_DIR=/etc/nginx
fi
mkdir -p $NGINX_DIR/var/log
mkdir -p $NGINX_DIR/run
ESCAPED_NGINX_DIR=$(printf '%s\n' "$NGINX_DIR" | sed -e 's/[\/&]/\\&/g')
NGINX_PORT=4200
sed -i -E "s/<nginx>/$ESCAPED_NGINX_DIR/" $NGINX_DIR/nginx.conf
sed -i -E "s/<nginx_run>/$ESCAPED_NGINX_DIR\/run/" $NGINX_DIR/nginx.conf
sed -i -E "s/<nginx_var>/$ESCAPED_NGINX_DIR\/var/" $NGINX_DIR/nginx.conf
sed -i -E "s/<nginx_log>/$ESCAPED_NGINX_DIR\/var\/log/" $NGINX_DIR/nginx.conf
sed -i -E "s/80\s/$NGINX_PORT /" $NGINX_DIR/sites-available/default
sed -i "/\[::\]/d" $NGINX_DIR/sites-available/default

nginx -c $NGINX_DIR/nginx.conf