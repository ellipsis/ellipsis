<h1>Hooks</h1>

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

The hooks available in your `ellipsis.sh` are:

| Hook            | Description                                                       |
|-----------------|-------------------------------------------------------------------|
| `pkg.init`      | Run custom init code when a shell is spawned.                     |
| `pkg.add`       | Customizes how files are added to your package.                   |
| `pkg.remove`    | Customizes how files are removed from your package.               |
| `pkg.install`   | Custom installation steps before linking the package.             |
| `pkg.installed` | Customize how a package is listed as installed.                   |
| `pkg.link`      | Customizes which files are linked into `$ELLIPSIS_HOME`.          |
| `pkg.links`     | Customizes which files are detected as symlinks.                  |
| `pkg.pull`      | Customize how changes are pulled in when `ellipsis pull` is used. |
| `pkg.push`      | Customize how changes are pushed when `ellipsis push` is used.    |
| `pkg.status`    | Customize the output of `ellipsis status`.                        |
| `pkg.uninstall` | Custom uninstall steps to undo the install steps.                 |
| `pkg.unlink`    | Customize which files are unlinked by your package.               |

Lets look at this in more detail!

### Installation

When you `ellipsis install` a package, ellipsis:

1. `git clone`'s the package into `~/.ellipsis/packages`.
2. Changes the current working dir to the package.
3. Sets `$PKG_NAME` and `$PKG_PATH`.
4. Sources the package's `ellipsis.sh` (if one exists).
5. Executes the package's `pkg.install` hook if available.
6. Executes the package's `pkg.link` hook if available, else the default link
   hook is run.

The default link hook symlinks all non-hidden files (read: not beginning with a
`.`) into `$ELLIPSIS_HOME` (typically `$HOME`). A few common text files like the
README, LICENSE, etc are not linked.

##### pkg.install
The `pkg.install` hook lets you run custom install steps. The hook is run after
cloning the repo.
This is the place to install plugin managers, dependencies,...

If the install hook returns with return code 1, the installation is aborted.

##### pkg.link
The `pkg.link` hook lets you customize which files are linked. It is recommended
to use the `fs.link_file` function, because it provides backup capability's.

### Uninstalling

When you `ellipsis uninstall` a package, ellipsis:

2. Changes the current working dir to the package.
3. Sets `$PKG_NAME` and `$PKG_PATH`.
4. Sources the package's `ellipsis.sh` (if one exists).
5. Executes the package's `pkg.unlink` hook if available, else the default
   unlink hook is run.
6. Executes the package's `pkg.uninstall` hook if available.
6. Deletes the package from the packages.

The default unlink hook removes all symlinks to the package from the `$ELLIPSIS_HOME` (typically
`$HOME`).

##### pkg.unlink
The `pkg.unlink` hook lets you customize which files are unlinked. It should
almost always be used when using a custom `pkg.link` hook.

##### pkg.uninstall
The `pkg.uninstall` hook lets you run custom uninstall steps.
If your `pkg.install` hook does anything outside of the `PKG_PATH` this is the
place to restore the original state.

### Initializing

If the init system is used, all `pkg.init` hooks will be called when a new
shell is spawned. How to enable the init system is explained in the [init
chapter][init].

##### pkg.init
This hook is called when a new shell is spawned. It can be used to add
functions, aliases, exports,... to the environment. The ellipsis api won't be
directly available from this hook. You can use the `ellipsis api` command to
access it, but for performance reasons it's not recommended.

**Attention:** As this code will be sourced by the users shell (which could be
any shell), this hook should be written with POSIX compliancy in mind!

### Other hooks

##### pkg.add
Alter the way an existing (dot)file is added to your package. By default the
file will be moved to your package and linked to it's original location. New
files will not be tracked by Git.

##### pgk.remove
Alter the way a (dot)file is deleted from your package. By default the file
will be moved to it's original location. The file will not be untracked by Git.

##### pkg.push
Alter the way a repository is pushed to git. This can be useful if you also
need to push submodules for example.

##### pkg.pull
Custom update hook, code to update plugins or submodules, recompile
files,... goes here. Don't forget to update the package itself by calling the
original update hook (`hooks.pull`).

##### pkg.links
The 'pkg.links' hook is purely informational and should echo the links to the
package. This hook is not used by the `unlink` hook, so you should still unlink
all custom links with the `pkg.unlink` hook.

##### pkg.installed
This hook should echo information about the installed version of your package,
and is purely informational.

##### pkg.status
This hook should echo information about the installation status of your
package. The hook is only used for informing the user.

#### Examples
Here's a more complete example (from
[zeekay/files][zeekay/dot-files]):

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
[zeekay/vim][zeekay/dot-vim]):

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

...and another example (from [groggemans/vim][groggemans/dot-vim]):

```bash
##############################################################################

# Minimal ellipsis version
ELLIPSIS_VERSION_DEP='1.9.0'

# Package dependencies (informational/not used!)
ELLIPSIS_PKG_DEPS=''

##############################################################################

pkg.install() {
    # Create vim folders
    mkdir -p "$PKG_PATH"/{undo,swap,spell}

    # Install Vundle
    mkdir -p "$PKG_PATH/bundle"
    cd "$PKG_PATH/bundle"
    git.clone https://github.com/vundlevim/vundle.vim

    # Run vim and install plugins
    PKG_PATH=$PKG_PATH\
        vim +PluginInstall +qall -u "$PKG_PATH/install.vim"

    # Install YouCompleteMe
    if [ -f "$PKG_PATH/bundle/youcompleteme/install.py" ]; then
        "$PKG_PATH/bundle/youcompleteme/install.py"
    fi
}

##############################################################################

pkg.link() {
    # Link vimrc
    fs.link_file vimrc

    # Link package into ~/.config/vim
    mkdir -p "$ELLIPSIS_HOME/.config"
    fs.link_file "$PKG_PATH" "$ELLIPSIS_HOME/.config/vim"
    fs.link_file "$PKG_PATH" "$ELLIPSIS_HOME/.config/nvim"
}

##############################################################################

pkg.links() {
    local files="$ELLIPSIS_HOME/.config/vim $ELLIPSIS_HOME/.config/nvim $ELLIPSIS_HOME/.vimrc"

    msg.bold "${1:-$PKG_NAME}"
    for file in $files; do
        local link="$(readlink "$file")"
        echo "$(path.relative_to_packages "$link") -> $(path.relative_to_home "$file")";
    done
}

##############################################################################

pkg.pull() {
    # Update dot-vim repo
    git.pull

    # Update plugins (clean than install and update)
    PKG_PATH=$PKG_PATH\
        vim +PluginClean! +PluginInstall! +qall -u "$PKG_PATH/install.vim"
}

##############################################################################

pkg.unlink() {
    # Remove config dir
    rm "$ELLIPSIS_HOME/.config/vim"
    rm "$ELLIPSIS_HOME/.config/nvim"

    # Remove all links in the home folder
    hooks.unlink
}

##############################################################################

pkg.uninstall() {
    : # No action
}

##############################################################################
```

You should also checkout the [package index][pkgindex] for more examples!

[zeesh]:                https://github.com/zeekay/zeesh
[zeekay/dot-files]:     https://github.com/zeekay/dot-files
[zeekay/dot-vim]:       https://github.com/zeekay/dot-vim
[groggemans/dot-vim]:   https://github.com/zeekay/dot-vim
[init]:                 init.md
[pkgindex]:             pkgindex.md
