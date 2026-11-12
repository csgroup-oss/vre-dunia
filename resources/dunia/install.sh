#!/bin/bash
# Copyright 2024 CS GROUP - France, http://www.c-s.fr
# All rights reserved

set -e

# Customize Desktop
mkdir -p /opt/vre
cp resources/branding/desktop/wallpaper.png /opt/vre/wallpaper.png
cp -r resources/xfce-perchannel-xml/. /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/
chmod 664 /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/*

# JupyterLab shortcut resources
# The config.py file (GitLab shortcut) is intentionally not installed, in order to
# edit the application's homepage and remove the GitLab access icon.
mkdir -p /opt/vre-eoafrica/jupyterlab_shortcuts
cp resources/jupyterlab_shortcuts/gitlab.svg /opt/vre-eoafrica/jupyterlab_shortcuts/

# Examples notebooks
mkdir -p /opt/examples
cp -r resources/jupyter-scripts/examples/. /opt/examples/
chmod 444 /opt/examples/*.ipynb

# Startup scripts (sourced by /srv/start) and Bash banner
cp resources/jupyter-scripts/start-notebook-*.sh /usr/local/bin/
chmod 755 /usr/local/bin/start-notebook-*.sh
cp resources/bash.bashrc /etc/

# Tests resources
mkdir -p /opt/vre/tests
for test in resources/tests/*; do
    [ "$(basename "$test")" = "vre_tests_ext.sh" ] || cp "$test" /opt/vre/tests/
done

# Desktop shortcuts
mkdir -p /opt/vre/desktop
cp resources/branding/desktop/*.desktop /opt/vre/desktop/
chmod -R +rX /opt/vre/

# tao: our own package, from the local wheel
pip install --no-cache-dir resources/tao-0.1.0-py3-none-any.whl
