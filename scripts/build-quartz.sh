#!/bin/bash

QUARTZ_DIR="/usr/src/app/quartz"
VAULT_DIR="/vault"
CONTENT_DIR="/vault/content"
CONFIG_DIR="/vault/config"

if [ "$VAULT_DO_GIT_PULL_ON_UPDATE" = true ]; then
  echo "Executing git pull in /vault directory"
  cd $VAULT_DIR
  git pull
fi

cd $QUARTZ_DIR

echo "Looking to update configuration files for Quartz"
[ -d $CONFIG_DIR ] && cp -rf $CONFIG_DIR/* $QUARTZ_DIR/

echo "Looking to install quartz theme"
/usr/src/app/scripts/action.sh tokyo-night

echo "Running Quartz build..."
if [ -n "$NOTIFY_TARGET" ]; then
  apprise -vv --title="Dockerized Quartz" --body="Quartz build has been started." "$NOTIFY_TARGET"
fi

npx quartz build --directory $CONTENT_DIR --output /usr/share/nginx/html
BUILD_EXIT_CODE=$?

if [ $BUILD_EXIT_CODE -eq 0 ]; then
  echo "Quartz build completed successfully."
  if [ -n "$NOTIFY_TARGET" ]; then
    apprise -vv --title="Dockerized Quartz" --body="Quartz build completed successfully." "$NOTIFY_TARGET"
  fi
else
  echo "Quartz build failed."
  if [ -n "$NOTIFY_TARGET" ]; then
    apprise -vv --title="Dockerized Quartz" --body="Quartz build failed!" "$NOTIFY_TARGET"
  fi
  exit 1
fi
