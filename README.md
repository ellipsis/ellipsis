## …
     _    _    _
    /\_\ /\_\ /\_\
    \/_/ \/_/ \/_/

A framework for managing dotfiles.

### Install
Clone and symlink or use handy-dandy installer:

    curl -sL ellipsis.sh | sh

You can also specify which modules to install by setting the `MODULES` variable, i.e.:

    curl -sL ellipsis.sh | MODULES='vim zsh' sh

### Usage
```
Usage: ellipsis <command>

Commands
  install     install new ellipsis module
  list        list available modules for install
  new         create a new ellipsis module
  pull        pull updates from upstream repositories
  push        push updates to local modules back to upstream repositories
  status      show status of local modules
  uninstall   uninstall ellipsis module
  help        show ellipsis help
  version     show ellipsis version
```

### Configuration
Ellipsis is just a framework, it comes with no predefined dot files. You can
install modules during installation of ellipsis or at anytime afterwards using
`ellipsis install`.

### Modules
A module is any repo with files you want to symlink into `$HOME`. By default a
given repo's non-hidden files (read: not beginning with a `.`) will naively be
linked into `$HOME`. Of course this isn't sufficient for a lot of cases, so you
can customize how ellipsis treats your module by defining hooks in an
`ellipsis.sh` file at the root of your repository.

### Hooks
Behavior of a module can be customized using several hooks.

Following variables are available from your hook:

#### $mod_name
Name of your module.

#### $mod_path
Path to your module.

The follow hooks may be defined:

#### mod.install
Customize how module is installed. By default all files are symlinked into
`$HOME`.

#### mod.uninstall
Customize how module is uninstalled. By default all symlinks are removed from
`$HOME`.

#### mod.push
Customize how how changes are pushed `ellipsis push` is used.

#### mod.pull
Customize how how changes are pulled in when `ellipsis pull` is used.

#### mod.status
Customize output of `ellipsis status`.

### API
Ellipsis exposes a number of variables to modules during install/execution as
well as a collection of useful utility functions.

#### ellipsis.backup
Moves existing file `$1` to `$1.bak`, taking care not to overwrite any existing
backups.

#### ellipsis.link_file
Link a single file `$1` into `$HOME`, taking care to backup an existing file.

#### ellipsis.link_files
Links files in `$1` into `$HOME`, taking care to backup any existing files.

#### ellipsis.platform
Platform detection, returns lowercase result of `uname`.

#### ellipsis.run_installer
Download an installation script from url `$1` with `curl` and execute it.

#### git.[command]
There are also several wrappers around common git operations which can be used
for consistency with the rest of ellipsis: **git.clone**, **git.pull**,
**git.push**, and **git.status**.

### Development
Pull requests welcome! To suggest a feature or report a bug:
http://github.com/zeekay/ellipsis/issues.

New code should follow [Google's style guide][style-guide].

[style-guide]: https://google-styleguide.googlecode.com/svn/trunk/shell.xml
