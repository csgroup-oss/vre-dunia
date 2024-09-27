#!/bin/bash

plugins="org.esa.s2tbx.sen2cor255"

echo "Upgrading SNAP modules..."
snap --nosplash --nogui --modules --update-all 2>&1 | while read -r line; do
    echo "$line"
    [ "$line" = "updates=0" ] && sleep 2 && pkill -TERM -f "snap/jre/bin/java"
done

echo "Installing missing SNAP modules..."
for plugin in $plugins; do
    echo "Installing plugin $plugin..."
    snap --nosplash --nogui --modules --install $plugin 2>&1 | while read -r line; do
        echo $line
        if [[ "$line" == Cannot* ]] || [[ "$line" == Unpacking* ]]; then
            sleep 5
            pkill -9 -f "/usr/local/snap/jre/bin/java"
        fi
    done
done