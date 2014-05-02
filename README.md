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
- [Works with existing dotfiles!](#upgrading-to-ellipsis)

### Install
Clone and symlink or use handy-dandy installer:

```bash
$ curl ellipsis.sh | sh
```

<sup>...no you didn't read that wrong, [this website also doubles as the installer](https://github.com/zeekay/ellipsis/blob/gh-pages/index.html)</sup>

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
(typically `$HOME`). By default all of a respository's non-hidden files (read:
not beginning with a `.`) will naively be linked into place, with the exception
of a few common text files (`README`, `LICENSE`, etc).

You can customize how ellipsis interacts with your package by adding an
`ellipsis.sh` file to the root of your project. Here's an example of a complete
`ellipsis.sh` file:

```bash
#!/usr/bin/env bash
```

Yep, that's it :) If all you want to do is symlink some files into `$HOME`,
adding an `ellipsis.sh` to your package is completely optional. But what if you
need more? That's where hooks come in...

### Hooks
Hooks allow you to control how ellipis interacts with your package, and how
various commands are executed against your package. Say for instance you wanted
to run the installer for your [favorite zsh
framework](https://github.com/zeekay/zeesh), you could define a `pkg.install`
hook like this:

```bash
#!/usr/bin/env bash

pkg.install() {
    utils.run_installer 'https://raw.github.com/zeekay/zeesh/master/scripts/install.sh'
}
```

When you `ellipsis install` a package, ellipsis:

1. `git clone`'s the package into `~/.ellipsis/packages`.
2. Changes the current working dir to the package.
3. Sets `$PKG_NAME` and `$PKG_PATH`.
4. Sources the package's `ellipsis.sh` (if one exists).
5. Executes the package's `pkg.install` hook or `hooks.install` (the default hook).

### Examples
Here's a more complete example (from
[zeekay/files](https://github.com/zeekay/dot-files)):

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

...and here's a slightly more complex example (from
[zeekay/vim](https://github.com/zeekay/dot-vim)):

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

The hooks available in your `ellipsis.sh` are:

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

### API
Besides the default hook implementations which are available to you from your
`ellipsis.sh` as `hooks.<name>`, there are a number of useful functions and
variables which ellipsis exposes for you:

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

#### fs.is_broken_symlink
Returns true if file is a broken symlink.

#### fs.list_symlinks
Lists symlinks in a folder, defaulting to `$ELLIPSIS_HOME`.

#### fs.backup
Creates a backup of an existing file, ensuring you don't overwrite existing backups.

#### fs.link_file
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

### <a class="anchor" href="#upgrading-to-ellipsis" name="upgrading-to-ellipsis">Upgrading to ellipsis</a>
So you've been around the block, got your own collection of dotfiles and you've
been managing them with a collection of scripts you've cobbled together over the
years...we've all been there. Luckily it's easy to convert your existing
dotfiles into a shiny new ellipsis package:

```bash
$ export ELLIPSIS_USER=your-github-user
$ ellipsis new dotfiles
Initialized empty Git repository in /home/user/.ellipsis/packages/dotfiles/.git/
[master (root-commit) 5f5d2a9] Initial commit
 2 files changed, 35 insertions(+)
 create mode 100644 README.md
 create mode 100644 ellipsis.sh
new package created at ~/.ellipsis/packages/dotfiles
$ ellipsis add dotfiles .*
mv ~/my-dotfiles/.vimrc dotfiles/vimrc
linking dotfiles/vimrc -> ~/.vimrc
mv ~/my-dotfiles/.zshrc dotfiles/zshrc
linking dotfiles/zshrc -> ~/.zshrc
```

### Completion
A completion file for zsh is [included][zshcomp]. To use it add `_ellipsis` to
your `fpath` and ensure auto-completion is enabled:

```bash
fpath=($HOME/.ellipsis/comp $fpath)
autoload -U compinit; compinit
```

### Development
Pull requests welcome! New code should follow the [existing style][style-guide]
(and ideally include [tests][bats]).

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
[zshcomp]:     https://github.com/zeekay/ellipsis/blob/master/comp/_ellipsis
