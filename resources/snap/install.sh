#!/bin/bash
# Copyright 2024 CS GROUP - France, http://www.c-s.fr
# All rights reserved

# Upgrade SNAP modules and install plugins (plugins install might not be working)
set -e

bash resources/snap/update_snap.sh

# SNAP logo
wget --quiet "https://eo4society.esa.int/wp-content/uploads/2018/11/SNAP_icon-400x400.jpg" -O "/usr/local/snap/snap.png"
