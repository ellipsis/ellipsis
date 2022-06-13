<h1>Completion</h1>

Completion file for [bash][bashcomp] and [zsh][zshcomp] are provided. 

For bash, you just need to source `_ellipsis_bash`:

```bash
. $HOME/.ellipsis/comp/_ellipsis_bash
```

For zsh, add `_ellipsis` to your `fpath` and ensure auto-completion is enabled:

```bash
fpath=($HOME/.ellipsis/comp $fpath)
autoload -U compinit; compinit
```

[zshcomp]:      https://github.com/ellipsis/ellipsis/blob/master/comp/_ellipsis
[bashcomp]:     https://github.com/ellipsis/ellipsis/blob/master/comp/_ellipsis_bash
