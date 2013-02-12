# …
My dotfiles, of course.

## Install
Clone and symlink or use handy-dandy installer:

    curl https://raw.github.com/zeekay/ellipsis/master/install.sh | sh

## Customization
Both Git and Mercurial repos can be used to customize an install, and cloned and symlinked automatically. Any `setup.sh` file found contained in the root of the repo will be executed automatically. I use a blend of the following dot-repos:

## Scripts
You can add `scripts` to your PATH and use the various scripts to manage your dotfiles:

- `df-up`       Update all dotfile repos
- `df-status`   Display status of all dotfile repos
- `df-push`     Push changes back from all dotfile repos
