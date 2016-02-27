<h1>Installation</h1>

**Requirements:** bash, curl, git

Clone and symlink or use handy-dandy installer:

```bash
$ curl -sL ellipsis.sh | sh
```

You can also specify which packages to install by setting the `PACKAGES` variable, i.e.:

```bash
$ curl -sL ellipsis.sh | PACKAGES='vim zsh' sh
```

Add `~/.ellipsis/bin` to your `$PATH` (or symlink somewhere convenient) and
start managing your dotfiles in style :)

