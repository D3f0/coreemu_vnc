#!/bin/bash
export GEOMETRY=${SCREEN_WIDTH}x${SCREEN_HEIGHT}x${SCREEN_DEPTH}
echo "Generating SSH keys"
cat /dev/zero | ssh-keygen -q -N ""
exec /usr/bin/supervisord -n
