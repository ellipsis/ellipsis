## …
     _    _    _
    /\_\ /\_\ /\_\
    \/_/ \/_/ \/_/

A framework for managing dotfiles.

### Install
Clone and symlink or use handy-dandy installer:

    curl -sL ellipsis.sh | sh

You can also specify which modules to install by setting `MODULES` variable, i.e.:

    curl -sL ellipsis.sh | MODULES='vim zsh' sh

### Usage
The `ellipsis` executable provides a number of useful commands for interacting
with your dotfiles.

- `ellipsis install`
    - Install a new ellipsis module.
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
A module is any github repo with files you want to symlink into `$HOME`. You can
add an `ellipsis.sh` file which will be sourced and used to customize how
ellipsis installs/uses your module.

Behavior of a module can be customized using several hooks.

#### Hooks

##### mod.install
Customize how module is installed. By default all files are symlinked into `$HOME`.

##### mod.push
Customize how how changes are pushed `ellipsis push` is used.

##### mod.pull
Customize how how changes are pulled in when `ellipsis pull` is used.

##### mod.status
Customize output of `ellipsis status`.

#### API
Ellipsis exposes a number of variables to modules during install/execution as
well as a collection of useful utility functions.

##### ellipsis.platform
Platform detection, returns lowercase result of `uname`.

##### ellipsis.backup
Moves existing file `$1` to `$1.bak`, taking care not to overwrite any existing
backups.

##### ellipsis.run_installer
Download an installation script with `curl` and execute it.

##### ellipsis.link_files
Links files in `$1` into `$HOME`.

There are also several wrappers around common git operations which can be used
for consistency with the rest of ellipsis.
    - `git.clone`
    - `git.pull`
    - `git.push`
    - `git.status`

### Development
Pull requests welcome! To suggest a feature or report a bug:
http://github.com/zeekay/ellipsis/issues.

New code should follow [Google's style guide][style-guide].

[style-guide]: https://google-styleguide.googlecode.com/svn/trunk/shell.xml
