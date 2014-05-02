## ellipsis [![Build Status](https://travis-ci.org/zeekay/ellipsis.svg?branch=master)](https://travis-ci.org/zeekay/ellipsis)

```
 _    _    _
/\_\ /\_\ /\_\
\/_/ \/_/ \/_/   …because $HOME is where the <3 is!
```

Ellipsis is a package manager for dotfiles.

### Features
- Creating new packages is trivial (any git repository is already a package).
- Modular configuration files are easier to maintain and share with others.
- Allows you to quickly see which dotfiles have been modified, and keep them
  updated and in-sync across systems.
- Adding new dotfiles to your collection can be automated with `ellipsis add`.
- Cross platform, known to work on Mac OS X, Linux, FreeBSD and even Cygwin.
- Large test suite to ensure your `$HOME` doesn't get ravaged.
- Completely customizable.

### Install
Clone and symlink or use handy-dandy installer:

```bash
$ curl ellipsis.sh | sh
```

<sup>...no you didn't read that wrong, [this website also doubles as the installer](https://github.com/zeekay/ellipsis/blob/gh-pages/index.html#L322)</sup>

You can also specify which packages to install by setting the `PACKAGES` variable, i.e.:

```bash
$ curl ellipsis.sh | PACKAGES='vim zsh' sh
```

Add `~/.ellipsis/bin` to your `$PATH` (or symlink somewhere convenient) and
start managing your dotfiles in style :)

### Usage
Ellipsis comes with no dotfiles out of the box. To install packages, use
`ellipsis install`. Packages can be specified by github-user/repo or full
ssh/git/http(s) urls:

```bash
$ ellipsis install ssh://github.com/zeekay/private.git
$ ellipsis install zeekay/vim
$ ellipsis install zsh
```

...all work. By convention `username/package` and `package` are aliases for
https://github.com/username/dot-package.

Full usage available via `ellipsis` executable:

```
$ ellipsis -h
Usage: ellipsis <command>
  Options:
    -h, --help     show help
    -v, --version  show version

  Commands:
    new        create a new package
    edit       edit an installed package
    add        add new dotfile to package
    install    install new package
    uninstall  uninstall package
    link       link package
    unlink     unlink package
    broken     list any broken symlinks
    clean      rm broken symlinks
    installed  list installed packages
    links      show symlinks installed by package(s)
    pull       git pull package(s)
    push       git push package(s)
    status     show status of package(s)
    publish    publish package to repository
    search     search package repository
```

### Configuration
You can customize ellipsis by exporting a few different variables:

#### GITHUB_USER / ELLIPSIS_USER
Customizes whose dotfiles are installed when you `ellipsis install` without
specifiying user or a full repo url. Defaults to `$(git config github.user)` or
`zeekay`.

#### ELLIPSIS_REPO
Customize location of ellipsis repo cloned during a curl-based install. Defaults
to `https://github.com/zeekay/ellipsis`.

#### ELLIPSIS_PROTO
Customizes which protocol new packages are cloned with, you can specify
`https`,`ssh`, `git`. Defaults to `https`.

#### ELLIPSIS_HOME
Customize which folder files are symlinked into, defaults to `$HOME`. (Mostly
useful for testing).

#### ELLIPSIS_PATH
Customize where ellipsis lives on your filesystem, defaults to `~/.ellipsis`.

```bash
export ELLIPSIS_USER="zeekay"
export ELLIPSIS_SSH="ssh"
export ELLIPSIS_PATH="~/.el"
```

### Packages
A package is any repo with files you want to symlink into `$ELLIPSIS_PATH`
(typically `$HOME`). By default a given repo's non-hidden files (read: not
beginning with a `.`) will naively be linked into place. Need a more complex
instsall process? No problem. You can customize every aspect of how ellipsis
uses your package using various hooks.

### Hooks
Hooks are defined in `ellipsis.sh` files in the root of your package's
repository. Hooks allow you to customize how ellipsis interacts with your
package. For instance, if you wanted to change how your package is installed you
can define `pkg.install` and specifiy exactly which files are symlinked into
place, compile any libraries necessary, etc.

#### Example
Here's a full example of an `ellipsis.sh` file:

```bash
#!/usr/bin/env bash
```

...of course that's not very helpful! But it's true, the `ellipsis.sh` file is
completely optional if all you want to do is symlink some files into your
`$HOME`.

Here's a more complete example (from
[zeekay/files](https://github.com/zeekay/dot-files), my collection of common,
cross-platform dotfiles):

```bash
#!/usr/bin/env bash

pkg.install() {
    fs.link_files common

    case $(os.platform) in
        cygwin)
            fs.link_files platform/cygwin
            ;;
        osx)
            fs.link_files platform/osx
            ;;
        freebsd)
            fs.link_files platform/freebsd
            ;;
        linux)
            fs.link_files platform/linux
            ;;
    esac
}
```

...and here's a slightly more complex example (used by
[zeekay/vim](https://github.com/zeekay/dot-vim), my vim configuration):

```bash
#!/usr/bin/env bash

pkg.install() {
    files=(gvimrc vimrc vimgitrc vimpagerrc)

    for file in ${files[@]}; do
        fs.link_file $file
    done

    # link module into ~/.vim
    fs.link_file $PKG_PATH

    # install dependencies
    cd ~/.vim/addons
    git.clone https://github.com/zeekay/vice
    git.clone https://github.com/MarcWeber/vim-addon-manager
}

helper() {
    # run command for ourselves
    $1

    # run command for each addon
    for addon in ~/.vim/addons/*; do
        cd $addon
        $1 $addon
    done
}

pkg.pull() {
    helper git.pull
}

pkg.status() {
    helper hooks.status
}

pkg.push() {
    git.push

    # git push only repos where we have push permission
    for addon in ~/.vim/addons/*; do
        if [ "$(cat $addon/.git/config | grep $ELLIPSIS_USER)" ]; then
            cd $addon
            git.push $addon
        fi
    done
}
```

### API
Typically you'll interact with the ellipsis API from your package's
`ellipsis.sh` file. Besides the hooks which you can use to customize how
ellipsis interacts with your package, there is a large collection of functions
and variables which you might find useful in your packages.

Hooks are executed from the root of your package and `$PKG_NAME` and `$PKG_PATH`
are set to reflect your package. The hooks available
are:

#### pkg.add
Customizes how a files is added to your package.

#### pkg.install
Customize how package is installed. By default all files are symlinked into
place.

#### pkg.installed
Customize how package is listed as installed.

#### pkg.links
Customizes which files are detected as symlinks.

#### pkg.pull
Customize how how changes are pulled in when `ellipsis pull` is used.

#### pkg.push
Customize how how changes are pushed `ellipsis push` is used.

#### pkg.status
Customize output of `ellipsis status`.

#### pkg.uninstall
Customize how package is uninstalled. By default all symlinks are removed and
the package is deleted from `$ELLIPSIS_PATH/packages`.

#### pkg.uninstall
Customize which files are unlinked by your package.

For references all the default hooks are available as `hooks.<hookname>`, which
makes it easy to use them in your hooks.

You can also call pretty much any internal ellipsis function, there are several
which you might find useful when writing your own hooks:

#### ellipsis.list_packages
Lists all installed packages.

#### ellipsis.each
Executes command for each installed package.

#### fs.folder_empty
Returns true if folder is empty.

#### fs.file_exists
Returns true if file exists.

#### fs.is_symlink
Returns true if file is a symlink.

#### fs.is_ellipsis_symlink
Returns true if file is a symlink pointing to an ellipsis package.

##### fs.is_broken_symlink
Returns true if file is a broken symlink.

##### fs.list_symlinks
Lists symlinks in a folder, defaulting to `$ELLIPSIS_HOME`.

##### fs.backup
Creates a backup of an existing file, ensuring you don't overwrite existing backups.

##### fs.link_file
Symlinks a single file into `$ELLIPSIS_HOME`.

#### fs.link_files
Symlinks all files in given folder into `$ELLIPSIS_HOME`.

#### git.clone
Clones a Git repo, identical to `git clone`.

#### git.pull
Identical to `git pull`.

#### git.push
Identical to `git push`.

#### git.sha1
Prints last commit's sha1 using `git rev-parse --short HEAD`.

#### git.last_updated
Prints commit's relative last update time.

#### git.head
Prints how far ahead a package is from origin.

#### git.has_changes
Returns true if repository has changes.

#### git.diffstat
Displays `git diff --stat`.

#### os.platform
Returns one of `cygwin`, `freebsd`, `linux`, `osx`.

#### utils.cmd_exists
Returns true if command exists.

#### utils.prompt
Prompts user `$1` message and returns true if `YES` or `yes` is input.

#### utils.run_installer
Downloads and runs web-based shell script installers.

### Available packages

#### [zeekay/alfred][alfred]
Alfred configuration files.

#### [zeekay/atom][atom]
Atom configuration files.

#### [zeekay/emacs][emacs]
Emacs configuration files.

#### [zeekay/files][files]
Common dotfiles for various programs.

#### [zeekay/irssi][irssi]
Irssi configuration.

#### [zeekay/iterm2][iterm2]
iTerm2 configuration files.

#### [zeekay/vim][vim]
Vim configuration based on vice framework.

#### [zeekay/xmonad][xmonad]
Xmonad configuration.

#### [zeekay/zsh][zsh]
Zsh configuration using zeesh! framework.

### Completions
A completion file for zsh is [included](zshcomp). To use it add `_ellipsis` to
your `fpath` and ensure auto-completion is enabled:

```bash
fpath=($HOME/.ellipsis/comp $fpath)
autoload -U compinit; compinit
```

### Development
Pull requests welcome! New code should follow [existing style](style-guide) and include tests
(tests are written with [bats][bats]).

To suggest a feature or report a bug: http://github.com/zeekay/ellipsis/issues.

[alfred]:      https://github.com/zeekay/dot-alfred
[atom]:        https://github.com/zeekay/dot-atom
[emacs]:       https://github.com/zeekay/dot-emacs
[files]:       https://github.com/zeekay/dot-files
[irssi]:       https://github.com/zeekay/dot-irssi
[iterm2]:      https://github.com/zeekay/dot-iterm2
[vim]:         https://github.com/zeekay/dot-vim
[xmonad]:      https://github.com/zeekay/dot-xmonad
[zsh]:         https://github.com/zeekay/dot-zsh
[style-guide]: https://google-styleguide.googlecode.com/svn/trunk/shell.xml
[bats]:        https://github.com/sstephenson/bats
