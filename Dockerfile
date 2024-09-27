# Copyright 2024 CS GROUP - France, http://www.c-s.fr
# All rights reserved

ARG OCI_REGISTRY_PREFIX
FROM ${OCI_REGISTRY_PREFIX}metislab-esa

USER root

WORKDIR /

## Add pip packages
RUN --mount=type=bind,source=requirements.txt,target=/opt/requirements.txt \
    pip install --no-cache-dir -r /opt/requirements.txt && \
    # Manually remove Cython to install a newer version (0.29.21 required by pytesmo)
    # Done manually because upgrade with pip fails (because packaged with distutils)
    rm -rf /usr/lib/python3/dist-packages/Cython* && \
    pip install --upgrade Cython pytesmo && \
    layer-cleanup.sh

## Install our own package tao from local fle
RUN --mount=type=bind,source=resources,target=/opt/resources \
    pip install --no-cache-dir /opt/resources/tao* && \
    layer-cleanup.sh

## Setting creodias as default provider in generated code
ENV EODAG__CREODIAS_S3__PRIORITY=2

## Add script to upgrade SNAP and install plugins (plugins install might not be working)
RUN --mount=type=bind,source=resources,target=opt/resources \
    /opt/resources/snap/update_snap.sh

## Rename jupyterlab tab
ARG jupyterlab_tab_name
RUN sed -i -E "s/(<title>.*<\/title>)/<title>${jupyterlab_tab_name}<\/title>/" /usr/local/share/jupyter/lab/static/index.html

## Customize Desktop
COPY resources/branding/wallpaper.png /opt/vre/wallpaper.png
COPY resources/xfce-perchannel-xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml

## Add JupyterLab shortcut
COPY /resources/jupyterlab_shortcuts /opt/vre-eoafrica/jupyterlab_shortcuts
## The following line, which was copying the "config.py" file into the Docker image, has been temporarily commented out, 
## and the "config.py" file has been removed. This modification allows for editing the application's homepage and removing the GitLab access icon.
#RUN cat /opt/vre-eoafrica/jupyterlab_shortcuts/config.py >> /usr/local/etc/jupyter/jupyter_notebook_config.py
RUN rm /opt/vre-eoafrica/jupyterlab_shortcuts/config.py

# Add scripts notebooks resources
RUN mkdir -p /opt/examples
COPY resources/jupyter-scripts/examples/ /opt/examples/
RUN chmod 444 /opt/examples/*.ipynb

## Add Bash banner
## Put startup scripts
COPY resources/jupyter-scripts/start-notebook*.sh /usr/local/bin/
COPY resources/bash.bashrc /etc/
RUN chmod 755 /usr/local/bin/start-notebook.sh

## Put tests resources
COPY resources/tests/* /opt/vre/tests/
RUN rm /opt/vre/tests/vre_tests_ext.sh && \
    chmod -R +rX /opt/vre/

## Place Desktop shortcut
COPY resources/shortcuts/* /opt/vre/desktop/

# Add SNAP logo
RUN wget --quiet "https://eo4society.esa.int/wp-content/uploads/2018/11/SNAP_icon-400x400.jpg" -O "/usr/local/snap/snap.png"

RUN usermod -l eoafrica vreuser && \
    groupmod -n eoafrica vreuser && \
    usermod -d /home/eoafrica -m eoafrica && \
    # Add permission for `runAsUser: 65534` default securityContext used in the PrePuller hook and continous.
    # It also can be overrided with https://z2jh.jupyter.org/en/stable/resources/reference.html#prepuller-hook-containersecuritycontext
    # Otherwise, the chdir to the home directory will fail with an error like:
    # Error response from daemon: OCI runtime create failed: container_linux.go:367: starting container process caused: chdir to cwd ("/home/eoafrica") set in config.json failed
    chmod o+x /home/eoafrica

## Define standard user
USER eoafrica

WORKDIR /home/eoafrica

ENTRYPOINT ["start-notebook.sh"]
