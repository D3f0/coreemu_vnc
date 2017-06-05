#!/bin/bash
export GEOMETRY=${SCREEN_WIDTH}x${SCREEN_HEIGHT}x${SCREEN_DEPTH}
x11vnc -storepasswd ${PASSWORD} ~/.vnc/passwd

exec /usr/bin/supervisord -n
