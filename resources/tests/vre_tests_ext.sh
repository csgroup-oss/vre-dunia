#!/bin/bash
# Copyright 2020 CS GROUP - France, http://www.c-s.fr
# All rights reserved

set -e

export no_proxy=localhost,127.0.0.1
export http_proxy=""
ADDRESS="http://127.0.0.1"
PORT="8888"
URL_PREFIX="$ADDRESS:$PORT"
IMAGE="$1"
VERSION="$2"

while [ -z "${TOKEN_URL}" ]; do 
    TOKEN_URL=$(docker logs $IMAGE-$VERSION 2>&1 | grep "   or http://127\." | cut -d' ' -f 7 | tail -n 1); 
    TOKEN=${TOKEN_URL#*token=}
    sleep 1
done

if [ -z "${CI}" ]; then
    PORT=$(docker port $IMAGE-$VERSION | grep 0.0.0.0 | cut -d: -f2)
    URL_PREFIX="$ADDRESS:$PORT"
fi

component=( "codeserver" "desktop" "filebrowser" )
for c in "${component[@]}"
do
    URL="$URL_PREFIX/$c/?token=$TOKEN";
    CURL_CMD="curl -o /dev/null -sw '%{http_code}' $URL"

    if [ -z "${CI}" ]; then
        status=$(bash -c "$CURL_CMD")
    else
        status=$(bash -c "docker exec $IMAGE-$VERSION $CURL_CMD")
    fi

    if [ $status == 302 -o $status == 200 ]; then
        echo "Test $c passed"
    else
        echo $URL
        echo $status
        echo "ERROR with $c. Test failed."
        exit 1
    fi
done
