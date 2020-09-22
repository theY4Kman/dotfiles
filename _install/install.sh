#!/bin/bash

INSTALL_DIR="$(cd $(dirname "$0"); pwd)"
REPO_ROOT="$(cd "$INSTALL_DIR/.."; pwd)"
DOWNLOAD_WAFFLESCRIPT="$INSTALL_DIR/download-wafflescript.sh"
INSTALL_SCRIPT="$INSTALL_DIR/do-install.waffle.sh"

# Download wafflescript, if necessary
# shellcheck source=download-wafflescript.sh
. "$DOWNLOAD_WAFFLESCRIPT"

# Do the install!
cd "$REPO_ROOT"
exec "$WAFFLESCRIPT_PATH" "$INSTALL_SCRIPT"
