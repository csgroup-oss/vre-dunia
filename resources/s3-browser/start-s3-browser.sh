#!/bin/bash -e
# Copyright 2024 CS GROUP - France, http://www.c-s.fr
# All rights reserved
# Inspired by https://github.com/jupyter/docker-stacks/blob/master/base-notebook


# s3-browser server
forever start -c "node" /opt/s3-browser/back/dist/main.js
# nginx (for s-browser front)
/opt/s3-browser/startup.sh
