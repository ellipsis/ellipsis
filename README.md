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
- [Works with existing dotfiles!][docs-upgrading]

### Install
**Requirements:** bash, curl, git

Clone and symlink or use handy-dandy installer:

```bash
$ curl ellipsis.sh | sh
```

<sup>...no you didn't read that wrong, [the ellipsis.sh website also doubles as the installer][installer]</sup>

You can also specify which packages to install by setting the `PACKAGES` variable, i.e.:

```bash
$ curl ellipsis.sh | PACKAGES='vim zsh' sh
```

Add `~/.ellipsis/bin` to your `$PATH` (or symlink somewhere convenient) and
start managing your dotfiles in style :)

As of version `1.7.3` you can also use the init system to automatically setup
you environment. As a bonus it will allow you to use the powerful `pkg.init`
hook to do the same for your packages.

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
https://github.com/username/dot-package. (customizable using `ELLIPSIS_PREFIX`)

For full usage information you can read the [docs][docs-usage] or ask help from
the command line with the `-h` option.

### Configuration
You can customize ellipsis by exporting a few different variables:

| Variable                        | Description                                                                                                                                                          |
|---------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `GITHUB_USER` / `ELLIPSIS_USER` | Customizes whose dotfiles are installed when you `ellipsis install` without specifying user or a full repo url. Defaults to `$(git config github.user)` or `whoami`. |
| `ELLIPSIS_REPO`                 | Customize location of ellipsis repo cloned during a curl-based install. Defaults to `https://github.com/ellipsis/ellipsis`.                                          |
| `ELLIPSIS_PROTO`                | Customizes which protocol new packages are cloned with, you can specify `https`,`ssh`, `git`. Defaults to `https`.                                                   |
| `ELLIPSIS_PREFIX`               | Customizes the prefix of ellipsis configuration packages (default: `dot-`).                                                                                                            |
| `ELLIPSIS_HOME`                 | Customize which folder files are symlinked into, defaults to `$HOME`. (Mostly useful for testing)                                                                    |
| `ELLIPSIS_PATH`                 | Customize where ellipsis lives on your filesystem, defaults to `~/.ellipsis`.                                                                                        |
| `ELLIPSIS_PACKAGES`             | Customize where ellipsis installs packages on your filesystem, defaults to `~/.ellipsis/packages`.                                                                   |
| `ELLIPSIS_LOGFILE`              | Customize location of the logfile, defaults to `/tmp/ellipsis.log`.                                                                                                  |

```bash
export ELLIPSIS_USER="zeekay"
export ELLIPSIS_PROTO="ssh"
export ELLIPSIS_PATH="~/.el"
```

### Packages
A package is any repo with files you want to symlink into `$ELLIPSIS_HOME`
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
need more? [That's where hooks come in...][docs-hooks]

### Docs
Please consult the [docs][docs-url] for more information.

Specific parts that could be off interest:
- [Hooks][docs-hooks]
- [Init system][docs-init]
- [API][docs-api]
- [Package index][docs-pkgindex]
- [Upgrading to Ellipsis][docs-upgrading]
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
[docs-url]:     http://docs.ellipsis.sh
[tag-image]:    https://img.shields.io/github/tag/ellipsis/ellipsis.svg
[tag-url]:      https://github.com/ellipsis/ellipsis/tags
[gitter-image]: https://badges.gitter.im/ellipsis/ellipsis.svg
[gitter-url]:   https://gitter.im/ellipsis/ellipsis

[docs-installation]:    http://docs.ellipsis.sh/install
[docs-usage]:           http://docs.ellipsis.sh/usage
[docs-packages]:        http://docs.ellipsis.sh/packages
[docs-hooks]:           http://docs.ellipsis.sh/hooks
[docs-init]:            http://docs.ellipsis.sh/init
[docs-api]:             http://docs.ellipsis.sh/api
[docs-pkgindex]:        http://docs.ellipsis.sh/pkgindex
[docs-upgrading]:       http://docs.ellipsis.sh/upgrading
[docs-completion]:      http://docs.ellipsis.sh/completion

[bats]:         https://github.com/sstephenson/bats
[installer]:    https://github.com/ellipsis/ellipsis/blob/gh-pages/index.html
[style-guide]:  https://google.github.io/styleguide/shell.xml
[issues]:       http://github.com/ellipsis/ellipsis/issues
[mit-license]:  http://opensource.org/licenses/MIT
