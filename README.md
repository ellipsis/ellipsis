# …
     _    _    _
    /\_\ /\_\ /\_\
    \/_/ \/_/ \/_/

A framework for managing dotfiles.

## Install
Clone and symlink or use handy-dandy installer:

    curl https://raw.github.com/zeekay/ellipsis/master/install.sh | sh

## Usage

- `ellipsis status` - get current commit of every dotfile module.
- `ellipsis update` - update each dotfile module.
- `ellipsis push`   - push updates to all dotfile modules back to github.

## Configuration
You can fork this repository and customize or use modules to extend your
ellipsis installation. You can list additional modules, i.e.:
`github:user/repo github:user/repo2`, etc.

## Modules
A module is any github repo which has a `.ellipsis-module` dir in the root.
Hooks are just shell scripts which customize how the module behaves.

### Available hooks
- `.ellipsis-module/install` - Controls how module is installed, what files are
  symlinked into `$HOME`.
- `.ellipsis-module/push` - Control how changes to the module are pushed back to
  github.
- `.ellipsis-module/pull` - Control how how changes are pulled in.
- `.ellipsis-module/status` - Output current status of module.
