#
# This script is to be run using wafflescript, using sudo
#
#   See install.sh
#
####

# NOTE: the current directory is set to repo root by install.sh
DOTFILES="$(pwd)"


directive='if [[ "$SUDO_USER" = "'"$SUDO_USER"'" ]]; then . "'"$DOTFILES/bashrc"'"; fi'
file.line \
  --file "/root/.bashrc" \
  --line "$directive"

