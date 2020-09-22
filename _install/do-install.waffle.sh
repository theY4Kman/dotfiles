#
# This script is to be run using wafflescript
#
#   See install.sh
#
####

# NOTE: the current directory is set to repo root by install.sh
DOTFILES="$(pwd)"

WAFFLESCRIPT="$SELF_EXECUTABLE"


function confirm() {
    while true; do
        read -p "$1 (y/n)? " choice
        case "$choice" in
          y|Y ) return 0;;
          n|N ) return 1;;
          * ) echo "Invalid selection.";;
        esac
    done
}


# Add an include to .gitconfig
file.ini \
  --file "$HOME/.gitconfig" \
  --section include \
  --option path \
  --value "$DOTFILES/gitconfig"


# Add a source line to .vimrc
file.line \
  --file "$HOME/.vimrc" \
  --line "source $DOTFILES/vimrc"


# Add a source line to .bashrc
file.line \
  --file "$HOME/.bashrc" \
  --line '. "'"$DOTFILES/bashrc"'"'


if confirm "Install bashrc sourcing when sudoing (for current user only)"; then
  sudo "$WAFFLESCRIPT" "$DOTFILES/_install/do-install-root.waffle.sh"
fi
