# ...
A framework for managing dotfiles. Meant to be used in conjunction with my other dot-* repos.

## Install
Clone and run `setup.sh`.

    git clone https://github.com/zeekay/ellipsis ~/.dotfiles && ~/.dotfiles/setup.sh

## Customization
Both Git and Mercurial repos can be used to customize an install, and cloned and symlinked automatically. Any `setup.sh` file found contained in the root of the repo will be executed automatically. I use a blend of the following dot-repos:

- [vim](https://github.com/zeekay/dot-vim)
- [zsh](https://github.com/zeekay/dot-zsh)
- [emacs](https://github.com/zeekay/dot-emacs)
- [xmonad](https://github.com/zeekay/dot-xmonad)

## Scripts
You can add `scripts` to your PATH and use the various scripts to manage your dotfiles:

- `df-up`       Update all dotfile repos
- `df-status`   Display status of all dotfile repos
- `df-push`     Push changes back from all dotfile repos
