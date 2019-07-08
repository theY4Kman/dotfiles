#!/bin/bash

DOTFILES="$(cd $(dirname "$0"); pwd)"


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


echo "NOTE: this script is currently not idempotent"
confirm "Do you wish to continue?" || exit 1


# Install gitconfig
cat <<-EOF >> $HOME/.gitconfig
	# Added automatically by they4kman/dotfiles::install.sh
	[include]
	    path = $DOTFILES/gitconfig
EOF
echo "Installed gitconfig"


# Install vimrc
cat <<-EOF >> $HOME/.vimrc
	" Added automatically by they4kman/dotfiles::install.sh
	source $DOTFILES/vimrc
EOF
echo "Installed vimrc."


# Install bashrc for user
cat <<-EOF >> $HOME/.bashrc
	# Added automatically by they4kman/dotfiles::install.sh
	. "$DOTFILES/bashrc"
EOF
echo "Installed user bashrc."


if confirm "Install bashrc sourcing when sudoing (for current user only)"; then
    cat <<-EOF | sudo tee /root/.bashrc > /dev/null
	# Added automatically by they4kman/dotfiles::install.sh
	#  This sources $USER's personal bashrc as root ONLY IF $USER runs sudo -i
	if [[ "\$SUDO_USER" = "$USER" ]]; then
	    . $HOME/.bashrc
	fi
EOF
    echo "Installed root bashrc."
fi

