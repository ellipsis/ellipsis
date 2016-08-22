<h1>Init system</h1>

The init system makes it possible to run init code for you packages each time
you spawn a new shell. This can be handy to add aliases, export variables, add
functions,...

To use the init system you can add the following snippet to your shells rc
file (bashrc, zshrc,...).

```bash
# Source Ellipsis init code or fallback to the older system
if [ -f ~/.ellipsis/init.sh ]; then
    . ~/.ellipsis/init.sh
else
    export PATH=$PATH:~/.ellipsis/bin
fi
```

The init system automatically adds the Ellipsis bin folder to your path (for
older packages and extensions) and exports the following variables:

| Variable            |
|---------------------|
| `ELLIPSIS_HOME`     |
| `ELLIPSIS_USER`     |
| `ELLIPSIS_PATH`     |
| `ELLIPSIS_PACKAGES` |

To use a custom value for any of these variables you can set them before
(re)initializing ellipsis.

On the command line this looks like;
```bash
# Re-init ellipsis with an other package directory
$ ELLIPSIS_PACKAGES=/tmp/tmp_pkg_dir ellipsis init
```
