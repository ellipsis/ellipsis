## …
     _    _    _
    /\_\ /\_\ /\_\
    \/_/ \/_/ \/_/

A framework for managing dotfiles.

### Install
Clone and symlink or use handy-dandy installer:

    curl https://raw.github.com/zeekay/ellipsis/master/scripts/install.sh | sh

You can specify which modules to install by setting `MODULES` variable, i.e.:

    curl https://raw.github.com/zeekay/ellipsis/master/scripts/install.sh | MODULES='vim zsh' sh

### Usage
The `ellipsis` executable provides a number of useful commands for interacting
with your dotfiles.

- `ellipsis status`
    - Get current commit of every dotfile module.
- `ellipsis update`
    - Update each dotfile module.
- `ellipsis push`
    - Push updates to all dotfile modules back to github.

### Configuration
You can fork this repository and customize or use modules to extend your
ellipsis installation. You can list additional modules, i.e.:
`github:user/repo github:user/repo2`, etc.

### Modules
A module is any github repo which has a `.ellipsis` dir in the root.
Hooks are just shell scripts which customize how the module behaves.

#### Available hooks
- `.ellipsis/install`
    - Controls how module is installed, what files are symlinked into `$HOME`.
- `.ellipsis/push`
    - Control how changes to the module are pushed back to github.
- `.ellipsis/pull`
    - Control how how changes are pulled in.
- `.ellipsis/status`
    - Output current status of module.
