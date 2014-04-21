```
 _    _    _
/\_\ /\_\ /\_\
\/_/ \/_/ \/_/   …because $HOME is where the <3 is!
```

Ellipsis is a framework for managing dotfiles.

### Features
- Creating new modules is trivial (any git repository is already a module).
- Ellipsis modules make it easy to share specific bits of your dotfiles. Say a
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

You can also specify which modules to install by setting the `MODULES` variable, i.e.:

```bash
$ curl -sL ellipsis.sh | MODULES='vim zsh' sh
```

I recommend adding `~/.ellipsis/bin` to your `$PATH`, but you can also just
symlink `~/.ellipsis/bin/ellipsis` somewhere convenient.

### Usage
Ellipsis comes with no dotfiles out of the box. To add a dotfiles modules, use
`ellipsis install`. Modules to install can be specified by github-user/repo or
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
    install        install new module
    uninstall      uninstall module
    new            create a new module
    list           list installed modules
    links          list symlinks installed globally or for a module
    available      list modules available for install
    pull           git pull all modules
    push           git push all modules
    status         show status of all modules
```

### Configuration
You can customize ellipsis by exporting a few different variables.

#### ELLIPSIS_USER
Customize whose dotfiles are installed when you `ellipsis install` without
specifiying user or a full repo url.

#### ELLIPSIS_REPO
Customize location of ellipsis repo cloned during a curl-based install.

#### ELLIPSIS_MODULES_URL
Customizes which url is used to display available modules.

```bash
export ELLIPSIS_USER="zeekay"
export ELLIPSIS_REPO="https://github.com/zeekay/ellipsis"
export ELLIPSIS_MODULES_URL="https://raw.githubusercontent.com/zeekay/ellipsis/master/available-modules.txt"
```

### Modules
A module is any repo with files you want to symlink into `$HOME`. By default a
given repo's non-hidden files (read: not beginning with a `.`) will naively be
linked into `$HOME`. Of course this isn't sufficient for a lot of cases, so you
can customize how ellipsis treats your module by defining hooks in an
`ellipsis.sh` file at the root of your repository.

### Hooks
Hooks allow you to customize how ellipsis interacts with your module.  For
instance if you want to change how your module is installed you can define
`mod.install` and specifiy exactly which files are symlinked into `$HOME`,
compile any libraries, etc.

The follow hooks/variables are available in your `ellipsis.sh`:

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

#### $mod_name
Name of your module.

#### $mod_path
Path to your module.

### API
There are a number of functions ellipsis exposes which can be useful in your
module's hooks:

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

### Available modules

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
guide][style-guide]. To suggest a feature or report a bug:
http://github.com/zeekay/ellipsis/issues.

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
