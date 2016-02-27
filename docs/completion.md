<h1>Completion</h1>

A completion file for zsh is [included][zshcomp]. To use it add `_ellipsis` to
your `fpath` and ensure auto-completion is enabled:

```bash
fpath=($HOME/.ellipsis/comp $fpath)
autoload -U compinit; compinit
```

[zshcomp]:      https://github.com/ellipsis/ellipsis/blob/master/comp/_ellipsis
