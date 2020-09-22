#!/bin/bash

INSTALL_DIR="$(cd "$(dirname "$0")/_install"; pwd)"

exec "$INSTALL_DIR/install.sh"
