# Copyright 2024 CS GROUP - France, http://www.c-s.fr
# All rights reserved

# The ONBUILD instructions of cnes/base-image (Pangeo logic) are only triggered for images
# directly based on it: they are replayed here on top of metislab-esa.
# apt.txt, environment.yml and requirements.txt only list what is added on top of metislab-esa.
ARG OCI_REGISTRY_PREFIX=
ARG ESA_IMAGE_TAG=latest
FROM ${OCI_REGISTRY_PREFIX}metislab-esa:${ESA_IMAGE_TAG}

USER root
WORKDIR ${HOME}

# apt packages
RUN --mount=type=bind,source=apt.txt,target=apt.txt \
    apt-get update --fix-missing > /dev/null \
    && xargs -a apt.txt apt-get install -y \
    && layer-cleanup.sh

# conda environment
USER ${NB_USER}
RUN --mount=type=bind,source=environment.yml,target=environment.yml \
    mamba env update --name ${CONDA_ENV} -f environment.yml \
    && mamba clean -yaf \
    && find ${CONDA_DIR} -follow -type f -name '*.a' -delete \
    && find ${CONDA_DIR} -follow -type f -name '*.js.map' -delete

# pip packages
RUN --mount=type=bind,source=requirements.txt,target=requirements.txt \
    ${NB_PYTHON_PREFIX}/bin/pip install --no-cache -r requirements.txt

# features
USER root
RUN --mount=type=bind,source=resources,target=resources \
    for script in $(find resources -type f -name install.sh); do \
        echo "Executing $script"; \
        bash "$script" || exit 1; \
        layer-cleanup.sh; \
    done

# Setting creodias as default provider in generated code
ENV EODAG__CREODIAS_S3__PRIORITY=2

# Rename jupyterlab tab
ARG jupyterlab_tab_name
RUN sed -i -E "s/(<title>.*<\/title>)/<title>${jupyterlab_tab_name}<\/title>/" ${NB_PYTHON_PREFIX}/share/jupyter/lab/static/index.html

# Features run as root with HOME=${HOME}: give back to the user the files they created (e.g. ~/.snap, ~/.npm)
RUN chown -R ${NB_USER}:${NB_USER} ${HOME}

# Rename the standard user (jovyan -> eoafrica)
# The home directory is made traversable for the `runAsUser: 65534` default securityContext used in the PrePuller hook
# (see https://z2jh.jupyter.org/en/stable/resources/reference.html#prepuller-hook-containersecuritycontext),
# otherwise the chdir to the home directory fails.
RUN usermod -l eoafrica ${NB_USER} \
    && groupmod -n eoafrica ${NB_USER} \
    && usermod -d /home/eoafrica -m eoafrica \
    && chmod o+x /home/eoafrica
ENV NB_USER=eoafrica \
    HOME=/home/eoafrica

USER eoafrica
WORKDIR /home/eoafrica
