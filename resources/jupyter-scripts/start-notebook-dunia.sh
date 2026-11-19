#!/bin/bash
# Copyright 2020 CS GROUP - France, http://www.c-s.fr
# All rights reserved

# Update desktop with extra content
DESKTOP=$HOME/Desktop
mkdir -p $DESKTOP
cp -ur /opt/vre/desktop/* $DESKTOP/
chmod +x $DESKTOP/*.desktop
