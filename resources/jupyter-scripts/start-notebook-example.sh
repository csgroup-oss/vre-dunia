#!/bin/bash
# Copyright 2020 CS GROUP - France, http://www.c-s.fr
# All rights reserved
# Inspired by https://github.com/jupyter/docker-stacks/blob/master/base-notebook

# Examples update at container startup time
DEST_FOLDER=$HOME
mkdir -p $DEST_FOLDER
echo "INFO: Updating examples into $DEST_FOLDER"
rsync -rltOv /opt/examples/ $DEST_FOLDER

for file in /opt/examples/*.ipynb
do
    NAME=$(basename $file)
    chmod 0444 "$DEST_FOLDER/$NAME"
    jupyter trust "$DEST_FOLDER/$NAME"
done
