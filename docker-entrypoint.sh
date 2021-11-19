#!/bin/bash

if [ -z "$PUID" ] || [ -z "$PGID" ]; then
  exec rawtoaces "$@"
else
  useradd -d /home/rawtoaces -m -s /bin/bash -u 1000 rawtoaces
  export CUSTOM_USER=rawtoaces
  groupmod -o -g "$PGID" "$CUSTOM_USER"
  usermod -o -u "$PUID" "$CUSTOM_USER"

  echo "------------------------------"
  echo "Running rawtoaces as:"
  echo "User uid: $(id -u "$CUSTOM_USER")"
  echo "User gid: $(id -g "$CUSTOM_USER")"
  echo "------------------------------"

  export HOME="$(getent passwd $CUSTOM_USER | cut -d: -f6)"
  setpriv --reuid="$CUSTOM_USER" --regid="$CUSTOM_USER" --init-groups -- \
    rawtoaces "$@"
fi
