# Ellipsis [![Build Status][travis-image]][travis-url] [![Documentation status][docs-image]][docs-url] [![Latest tag][tag-image]][tag-url] [![Gitter chat][gitter-image]][gitter-url]

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
**Requirements:** bash, curl, git

Clone and symlink or use handy-dandy installer:

```bash
$ curl -sL ellipsis.sh | sh
```

<sup>...no you didn't read that wrong, [the ellipsis.sh website also doubles as the installer][installer]</sup>

You can also specify which packages to install by setting the `PACKAGES` variable, i.e.:

```bash
$ curl -sL ellipsis.sh | PACKAGES='vim zsh' sh
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

Variable                        | Description
--------------------------------|------------
`GITHUB_USER` / `ELLIPSIS_USER` | Customizes whose dotfiles are installed when you `ellipsis install` without specifying user or a full repo url. Defaults to `$(git config github.user)` or `zeekay`.
`ELLIPSIS_REPO`                 | Customize location of ellipsis repo cloned during a curl-based install. Defaults to `https://github.com/ellipsis/ellipsis`.
`ELLIPSIS_PROTO`                | Customizes which protocol new packages are cloned with, you can specify `https`,`ssh`, `git`. Defaults to `https`.
`ELLIPSIS_HOME`                 | Customize which folder files are symlinked into, defaults to `$HOME`. (Mostly useful for testing)
`ELLIPSIS_PATH`                 | Customize where ellipsis lives on your filesystem, defaults to `~/.ellipsis`.
`ELLIPSIS_PACKAGE`              | Customize where ellipsis installs packages on your filesystem, defaults to `~/.ellipsis/packages`.
`ELLIPSIS_LOGFILE`              | Customize location of the logfile

```bash
export ELLIPSIS_USER="zeekay"
export ELLIPSIS_PROTO="ssh"
export ELLIPSIS_PATH="~/.el"
```

### Packages
A package is any repo with files you want to symlink into `$ELLIPSIS_PATH`
(typically `$HOME`). By default all of a repository's non-hidden files (read:
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
Hooks allow you to control how ellipsis interacts with your package, and how
various commands are executed against your package. Say for instance you wanted
to run the installer for your [favorite zsh framework][zeesh], you could define
a `pkg.install` hook like this:

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

The hooks available in your `ellipsis.sh` are:

Hook            | Description
----------------|------------
`pkg.add`       | Customizes how files are added to your package.
`pkg.install`   | Customize how a package is installed. By default the pkg.link hook is run.
`pkg.installed` | Customize how a package is listed as installed.
`pkg.link`      | Customizes which files are linked into `$ELLIPSIS_HOME`.
`pkg.links`     | Customizes which files are detected as symlinks.
`pkg.pull`      | Customize how changes are pulled in when `ellipsis pull` is used.
`pkg.push`      | Customize how changes are pushed when `ellipsis push` is used.
`pkg.status`    | Customize the output of `ellipsis status`.
`pkg.uninstall` | Customize how a package is uninstalled. By default all symlinks are removed and the package is deleted from `$ELLIPSIS_PATH/packages`.
`pkg.unlink`    | Customize which files are unlinked by your package.

#### Examples
Here's a more complete example (from
[zeekay/files][dot-files]):

```bash
#!/usr/bin/env bash

pkg.link() {
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
[zeekay/vim][dot-vim]):

```bash
#!/usr/bin/env bash

pkg.link() {
    files=(gvimrc vimrc vimgitrc vimpagerrc xvimrc)

    # link files into $HOME
    for file in ${files[@]}; do
        fs.link_file $file
    done

    # link package into $HOME/.vim
    fs.link_file $PKG_PATH
}

pkg.install() {
    cd ~/.vim/addons

    # install dependencies
    git.clone https://github.com/zeekay/vice
    git.clone https://github.com/MarcWeber/vim-addon-manager
}

helper() {
    # run command for ourselves
    $1

    # run command for each addon
    for addon in ~/.vim/addons/*; do
        # git status/push only repos which are ours
        if [ $1 = "git.pull" ] || [ "$(cat $addon/.git/config | grep url | grep $ELLIPSIS_USER)" ]; then
            cd $addon
            $1 vim/$(basename $addon)
        fi
    done
}

pkg.pull() {
    helper git.pull
}

pkg.status() {
    helper hooks.status
}

pkg.push() {
    helper git.push
}
```

### API
Besides the default hook implementations which are available to you from your
`ellipsis.sh` as `hooks.<name>`, there are a number of useful functions and
variables which ellipsis exposes for you:

Function/Variable             | Description
------------------------------|------------
`ellipsis.each`               | Executes command for each installed package.
`ellipsis.list_packages`      | Lists all installed packages.
`fs.backup`                   | Creates a backup of an existing file, ensuring you don't overwrite existing backups.
`fs.file_exists`              | Returns true if file exists.
`fs.folder_empty`             | Returns true if folder is empty.
`fs.is_broken_symlink`        | Returns true if file is a broken symlink.
`fs.is_ellipsis_symlink`      | Returns true if file is a symlink pointing to an ellipsis package.
`fs.is_symlink`               | Returns true if file is a symlink.
`fs.link_file`                | Symlinks a single file into `$ELLIPSIS_HOME`.
`fs.link_files`               | Symlinks all files in given folder into `$ELLIPSIS_HOME`.
`fs.list_dirs`                | Lists directories, useful for passing subdirectories to `fs.link_files`.
`fs.list_symlinks`            | Lists symlinks in a folder, defaulting to `$ELLIPSIS_HOME`.
`fs.strip_dot`                | Removes `.` prefix from files in a given directory.
`git.clone`                   | Clones a Git repo, identical to `git clone`.
`git.diffstat`                | Displays `git diff --stat`.
`git.has_changes`             | Returns true if repository has changes.
`git.head`                    | Prints how far ahead a package is from origin.
`git.last_updated`            | Prints commit's relative last update time.
`git.pull`                    | Identical to `git pull`.
`git.push`                    | Identical to `git push`.
`git.sha1`                    | Prints last commit's sha1 using `git rev-parse --short HEAD`.
`os.platform`                 | Returns one of `cygwin`, `freebsd`, `linux`, `osx`.
`path.abs_path`               | Return absolute path to `$1`.
`path.is_path`                | Simple heuristic to determine if `$1` is a path.
`path.relative_to_home`       | Replaces `$HOME` with `~`
`path.expand`                 | Replaces `~` with `$HOME`
`path.relative_to_packages`   | Strips `$ELLIPSIS_PACKAGES` from path.
`path.strip_dot`              | Strip dot from hidden files/folders.
`utils.cmd_exists`            | Returns true if command exists.
`utils.prompt`                | Prompts user `$1` message and returns true if `YES` or `yes` is input.
`utils.run_installer`         | Downloads and runs web-based shell script installers.

<a class="anchor" href="#upgrading-to-ellipsis" name="upgrading-to-ellipsis"></a>

### Upgrading to ellipsis
No stranger to dotfiles? Spent years hording complex configurations for esoteric
and archaic programs? Have your own system for managing them using a bunch of
scripts you've cobbled together over the years? I've been there, friend.

Luckily it's easy to convert your existing dotfiles into a shiny new ellipsis
package:

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
mv ~/.vimrc dotfiles/vimrc
linking dotfiles/vimrc -> ~/.vimrc
mv ~/.zshrc dotfiles/zshrc
linking dotfiles/zshrc -> ~/.zshrc
```

### Docs
Please consult the [docs][docs-url] for more information.

Specific parts that could be off interest:
- [Hooks][docs-hooks]
- [API][docs-api]
- [Package index][docs-pkgindex]
- [Zsh completion][docs-completion]

### Development
Pull requests welcome! New code should follow the [existing style][style-guide]
(and ideally include [tests][bats]).

Suggest a feature or report a bug? Create an [issue][issues]!

### License
Ellipsis is open-source software licensed under the [MIT license][mit-license].

[travis-image]: https://img.shields.io/travis/ellipsis/ellipsis.svg
[travis-url]:   https://travis-ci.org/ellipsis/ellipsis
[docs-image]:   https://readthedocs.org/projects/ellipsis/badge/?version=master
[docs-url]:     http://ellipsis.readthedocs.org/en/master
[tag-image]:    https://img.shields.io/github/tag/ellipsis/ellipsis.svg
[tag-url]:      https://github.com/ellipsis/ellipsis/tags
[gitter-image]: https://badges.gitter.im/ellipsis/ellipsis.svg
[gitter-url]:   https://gitter.im/ellipsis/ellipsis

[docs-hooks]:       http://ellipsis.readthedocs.org/en/master/hooks
[docs-api]:         http://ellipsis.readthedocs.org/en/master/api
[docs-pkgindex]:    http://ellipsis.readthedocs.org/en/master/pkgindex
[docs-completion]:  http://ellipsis.readthedocs.org/en/master/completion

[bats]:         https://github.com/sstephenson/bats
[dot-alfred]:   https://github.com/zeekay/dot-alfred
[dot-atom]:     https://github.com/zeekay/dot-atom
[dot-emacs]:    https://github.com/zeekay/dot-emacs
[dot-files]:    https://github.com/zeekay/dot-files
[dot-irssi]:    https://github.com/zeekay/dot-irssi
[dot-iterm2]:   https://github.com/zeekay/dot-iterm2
[dot-vim]:      https://github.com/zeekay/dot-vim
[dot-xmonad]:   https://github.com/zeekay/dot-xmonad
[dot-zsh]:      https://github.com/zeekay/dot-zsh
[installer]:    https://github.com/ellipsis/ellipsis/blob/gh-pages/index.html
[style-guide]:  https://google-styleguide.googlecode.com/svn/trunk/shell.xml
[vice]:         https://github.com/zeekay/vice
[zeesh]:        https://github.com/zeekay/zeesh
[zshcomp]:      https://github.com/ellipsis/ellipsis/blob/master/comp/_ellipsis

[issues]:       http://github.com/ellipsis/ellipsis/issues
[mit-license]:  http://opensource.org/licenses/MIT
