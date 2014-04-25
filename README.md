## ellipsis [![Build Status](https://travis-ci.org/zeekay/ellipsis.svg?branch=master)](https://travis-ci.org/zeekay/ellipsis)

```
 _    _    _
/\_\ /\_\ /\_\
\/_/ \/_/ \/_/   …because $HOME is where the <3 is!
```

ellipsis is a package manager for dotfiles.

### Features
- Creating new packages is trivial (any git repository is already a package).
- Ellipsis packages make it easy to share specific bits of your dotfiles. Say a
  friend wants to test out your ZSH setup but doesn't want to adopt the madness
  that is your Vim config? No problem, he can just `ellipsis install
  github-user/dot-zsh`
- Quickly see which dotfiles have been modified, and keep them updated and in
  sync across systems.
- Cross platform, known to work on Mac OS X, Linux, FreeBSD and even Cygwin.
- Completely customizable.

### Install
Clone and symlink or use handy-dandy installer:

```bash
$ curl -sL ellipsis.sh | sh
```

You can also specify which packages to install by setting the `PACKAGES` variable, i.e.:

```bash
$ curl -sL ellipsis.sh | PACKAGES='vim zsh' sh
```

I recommend adding `~/.ellipsis/bin` to your `$PATH`, but you can also just
symlink `~/.ellipsis/bin/ellipsis` somewhere convenient.

### Usage
Ellipsis comes with no dotfiles out of the box. To add a dotfiles packages, use
`ellipsis install`. Packages to install can be specified by github-user/repo or
full ssh/git/http(s) urls:

```bash
$ ellipsis install ssh://github.com/zeekay/private.git
$ ellipsis install zeekay/vim
$ ellipsis install zsh
```

...all work.

Full usage available via `ellipsis` executable:

```
$ ellipsis -h
Usage: ellipsis <command>
  Options:
    -h, --help     show help
    -v, --version  show version

  Commands:
    install        install new package
    uninstall      uninstall package
    new            create a new package
    list           list installed packages
    links          list symlinks installed globally or for a package
    available      list packages available for install
    pull           git pull all packages
    push           git push all packages
    status         show status of all packages
```

### Configuration
You can customize ellipsis by exporting a few different variables.

#### ELLIPSIS_USER
Customize whose dotfiles are installed when you `ellipsis install` without
specifiying user or a full repo url.

#### ELLIPSIS_REPO
Customize location of ellipsis repo cloned during a curl-based install.

#### ELLIPSIS_PACKAGES_URL
Customizes which url is used to display available packages.

```bash
export ELLIPSIS_USER="zeekay"
export ELLIPSIS_REPO="https://github.com/zeekay/ellipsis"
export ELLIPSIS_PACKAGES_URL="https://raw.githubusercontent.com/zeekay/ellipsis/master/available-packages.txt"
```

### Packages
A package is any repo with files you want to symlink into `$HOME`. By default a
given repo's non-hidden files (read: not beginning with a `.`) will naively be
linked into `$HOME`. Of course this isn't sufficient for a lot of cases, so you
can customize how ellipsis treats your package by defining hooks in an
`ellipsis.sh` file at the root of your repository.

### Hooks
Hooks allow you to customize how ellipsis interacts with your package.  For
instance if you want to change how your package is installed you can define
`pkg.install` and specifiy exactly which files are symlinked into `$HOME`,
compile any libraries, etc.

The follow hooks/variables are available in your `ellipsis.sh`:

#### pkg.install
Customize how package is installed. By default all files are symlinked into
`$HOME`.

#### pkg.uninstall
Customize how package is uninstalled. By default all symlinks are removed from
`$HOME`.

#### pkg.push
Customize how how changes are pushed `ellipsis push` is used.

#### pkg.pull
Customize how how changes are pulled in when `ellipsis pull` is used.

#### pkg.status
Customize output of `ellipsis status`.

#### $PKG_NAME
Name of your package.

#### $PKG_PATH
Path to your package.

### API
There are a number of functions ellipsis exposes which can be useful in your
package's hooks:

#### ellipsis.backup
Moves existing file `$1` to `$1.bak`, taking care not to overwrite any existing
backups.

#### ellipsis.link_file
Link a single file `$1` into `$HOME`, taking care to backup an existing file.

#### ellipsis.link_files
Links files in `$1` into `$HOME`, taking care to backup any existing files.

#### ellipsis.run_installer
Download an installation script from url `$1` with `curl` and execute it.

#### utils.platform
Platform detection, returns lowercase result of `uname`.

#### git.[command]
There are also several wrappers around common git operations which can be used
for consistency with the rest of ellipsis: **git.clone**, **git.pull**,
**git.push**, and **git.status**.

### Available packages

#### [zeekay/dot-alfred][alfred]
Alfred configuration files.

#### [zeekay/dot-atom][atom]
Atom configuration files.

#### [zeekay/dot-emacs][emacs]
Emacs configuration files.

#### [zeekay/dot-files][files]
Default dotfiles for ellipsis.

#### [zeekay/dot-irssi][irssi]
Irssi configuration.

#### [zeekay/dot-iterm2][iterm2]
iTerm2 configuration files.

#### [zeekay/dot-vim][vim]
Vim configuration based on vice framework.

#### [zeekay/dot-xmonad][xmonad]
Xmonad configuration.

#### [zeekay/dot-zsh][zsh]
Zsh configuration using zeesh! framework.

### Development
Pull requests welcome! New code should follow [Google's style
guide][style-guide]. To run tests you need to install [bats][bats].

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
