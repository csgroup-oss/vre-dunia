#!/bin/bash
# Copyright 2020 CS GROUP - France, http://www.c-s.fr
# All rights reserved
# Inspired by https://github.com/jupyter/docker-stacks/blob/master/base-notebook

set -e

# Exec startup scripts files
echo "[INFO] Executing up startup scripts"
for file in /usr/local/bin/*
do
  if [[ $file == *"start-notebook-"* ]]
  then
    echo "[INFO] Executing $file"
    source "$file"
  fi
done
echo "[INFO] Executing up startup scripts - Finished"

# VSCode base extensions copy if not already set
VSCODE_EXTENSIONS_DIR=$HOME/.vscode/extensions
echo "INFO: VSCode extensions folder set up in $VSCODE_EXTENSIONS_DIR"
mkdir -p $VSCODE_EXTENSIONS_DIR
echo "INFO: copy of VSCode base extensions" 
rsync -a /opt/code-server/extensions/ $VSCODE_EXTENSIONS_DIR
echo "INFO: VSCode extensions successfully set up"

# Copy files generated with user creation if not present
SAVED_HOME=/opt/vre/home/ai4geo
if [ -d $SAVED_HOME ]; then
  shopt -s dotglob # Allow hiddenfiles to be listed
  for file in $SAVED_HOME/*; do
    if [ ! -f $HOME/$(basename $file) ]; then
      echo "INFO: Copy $file to $HOME"
      cp $file $HOME
    fi
  done
fi

# Update desktop with extra content
DESKTOP=$HOME/Desktop
mkdir -p $DESKTOP
cp -ur /opt/vre/desktop/* $DESKTOP/
chmod +x $DESKTOP/*.desktop

# Dask-jobqueue configuration for dask-labextension
# see https://jobqueue.dask.org/en/latest/interactive.html#configuration
echo "[INFO] setting dask-labextension..."
DASK_CFG_FILE=$HOME/.config/dask/jobqueue.yaml
mkdir -p $(dirname $DASK_CFG_FILE)
if [[ ! -f $DASK_CFG_FILE ]]; then
    echo "[INFO] $DASK_CFG_FILE not existing, creating"
    touch $DASK_CFG_FILE
fi
if [[ -z $(grep distributed.dashboard.link $DASK_CFG_FILE) ]]; then
    echo "" >> $DASK_CFG_FILE
    echo "distributed.dashboard.link: "/user/{JUPYTERHUB_USER}/proxy/{port}/status"" >> $DASK_CFG_FILE
    echo "" >> $DASK_CFG_FILE
else
    echo "[WARN] dask-labextension already configured"
    echo "[WARN] remove "distributed.dashboard.link" setting from $DASK_CFG_FILE if you want to reapply"
fi
echo "[INFO] dask-labextension successfully configured"

# Set JAVA env
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export JDK_HOME=/usr/lib/jvm/java-11-openjdk-amd64

if [ ! -f $LOCAL_SNAP_CONF ]; then
  ln -s $SNAPPY_CONF $LOCAL_SNAPPY_CONF
fi
if [ ! -f $LOCAL_SNAPPY_CONF ]; then
  ln -s $SNAPPY_CONF $LOCAL_SNAPPY_CONF
fi

if [[ ! -z "${JUPYTERHUB_API_TOKEN}" ]]; then
  # drop first arg from $@ which is jupyter-singleuser command set by JupyterHub
  shift
  # launched by JupyterHub, use single-user entrypoint
  exec start-singleuser.sh "$@"
elif [[ ! -z "${JUPYTER_ENABLE_LAB}" ]]; then
  jupyter lab "$@"
else
  jupyter notebook "$@"
fi
