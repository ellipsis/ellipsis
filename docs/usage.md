<h1>Usage</h1>

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

Full usage available via `ellipsis` executable:

```
$ ellipsis -h
Usage: ellipsis <command>
  Options:
    -h, --help     show help
    -v, --version  show version

  Commands:

    # Informations
    info       show ellipsis info
    search     search package repository
    list       list installed packages
    status     show status of package(s)
    links      show symlinks installed by package(s)

    # Package manager
    install    install new package
    link       link package
    reinstall  re-install a package
    unlink     unlink package
    uninstall  uninstall package

    # Package editor
    new        create a new package
    edit       edit an installed package
    add        add new dotfile to package
    remove     remove a files form a package

    # Repository
    pull       git pull package(s)
    push       git push package(s)
    publish    publish package to repository

    # Maintenance
    broken     list any broken symlinks
    clean      rm broken symlinks

    # Utils
    strip      strip . from filenames
    init       source init code for your shell

```

### Configuration
You can customize ellipsis by exporting a few different variables:

| Variable                        | Description                                                                                                                                                          |
|---------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `GITHUB_USER` / `ELLIPSIS_USER` | Customizes whose dotfiles are installed when you `ellipsis install` without specifying user or a full repo url. Defaults to `$(git config github.user)` or `whoami`. |
| `ELLIPSIS_REPO`                 | Customize location of ellipsis repo cloned during a curl-based install. Defaults to `https://github.com/ellipsis/ellipsis`.                                          |
| `ELLIPSIS_PROTO`                | Customizes which protocol new packages are cloned with, you can specify `https`,`ssh`, `git`. Defaults to `https`.                                                   |
| `ELLIPSIS_PREFIX`               | Customizes the prefix of ellipsis configuration packages (default: `dot-`).                                                                                          |
| `ELLIPSIS_HOME`                 | Customize which folder files are symlinked into, defaults to `$HOME`. (Mostly useful for testing)                                                                    |
| `ELLIPSIS_PATH`                 | Customize where ellipsis lives on your filesystem, defaults to `~/.ellipsis`.                                                                                        |
| `ELLIPSIS_PACKAGES`             | Customize where ellipsis installs packages on your filesystem, defaults to `~/.ellipsis/packages`.                                                                   |
| `ELLIPSIS_LOGFILE`              | Customize location of the logfile, defaults to `/tmp/ellipsis.log`.                                                                                                  |

```bash
export ELLIPSIS_USER="zeekay"
export ELLIPSIS_PROTO="ssh"
export ELLIPSIS_PATH="~/.el"
```
