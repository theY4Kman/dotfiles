# dotfiles (they4kman)

Scripts, configurations, and other things to remember for future use.

## Quick Setup
Use the one-liner from [this gist](https://gist.github.com/theY4Kman/6197365) to automatically download and source the `.bashrc`. Replicated here:
```bash
wget https://gist.github.com/theY4Kman/6197365/raw/setup-yak.sh -O setup-yak.sh && source setup-yak.sh
```

## Full Setup
To permanently install these dotfiles (including vimrc, gitconfig, bashrc, and optionally a directive to source bashrc when sudoing to root), an idempotent installation script is provided, powered by [Wafflescript](https://github.com/wffls/wafflescript).

Simply clone the repo and run:
```bash
./install.sh
```
