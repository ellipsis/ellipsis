<h1>Installation</h1>

**Requirements:** bash, curl, git

Clone and symlink or use handy-dandy installer:

```bash
# Manual install
$ git clone https://github.com/ellipsis/ellipsis .ellipsis

# Using installer
$ curl -sL ellipsis.sh | sh
```

With the installer you can also specify which packages to install by setting
the `PACKAGES` variable, i.e.:

```bash
$ curl -sL ellipsis.sh | PACKAGES='vim zsh' sh
```

Add `~/.ellipsis/bin` to your `$PATH` (or symlink somewhere convenient) and
start managing your dotfiles in style :)

As of version `1.7.3` you can also use [the init system][init] to automatically
setup your environment. As a bonus it will allow you to use the powerful
`pkg.init` hook to do the same for your packages.

[init]: init.md
