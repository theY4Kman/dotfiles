#!/bin/bash

INSTALL_DIR="$(cd $(dirname "$0"); pwd)"
WAFFLESCRIPT_PATH="$INSTALL_DIR/wafflescript"

WAFFLESCRIPT_VERSION='v0.2-0.30.4'
WAFFLESCRIPT_ASSET_URL="https://github.com/wffls/wafflescript/releases/download/${WAFFLESCRIPT_VERSION}/wafflescript_${WAFFLESCRIPT_VERSION}_linux_x86_64.tgz"

if [ ! -f "$WAFFLESCRIPT_PATH" ]; then
  echo "Downloading wafflescript from ${WAFFLESCRIPT_ASSET_URL}"
  curl --location "$WAFFLESCRIPT_ASSET_URL" | tar -xvzf - -C "$INSTALL_DIR"
fi
