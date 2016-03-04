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

Hook            | Description
----------------|------------
`pkg.add`       | Customizes how files are added to your package.
`pkg.install`   | Custom installation steps before linking the package.
`pkg.installed` | Customize how a package is listed as installed.
`pkg.link`      | Customizes which files are linked into `$ELLIPSIS_HOME`.
`pkg.links`     | Customizes which files are detected as symlinks.
`pkg.pull`      | Customize how changes are pulled in when `ellipsis pull` is used.
`pkg.push`      | Customize how changes are pushed when `ellipsis push` is used.
`pkg.status`    | Customize the output of `ellipsis status`.
`pkg.uninstall` | Custom uninstall steps to undo the install steps.
`pkg.unlink`    | Customize which files are unlinked by your package.

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
The `pkg.unlink` hook lets you customize which files are unlinked.

##### pkg.uninstall
The `pkg.uninstall` hook lets you run custom uninstall steps.
If your `pkg.install` hook does anything outside of the `PKG_PATH` this is the
place to restore the original state.

#### Examples
Here's a more complete example (from
[zeekay/files][dot-files]):

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
[zeekay/vim][dot-vim]):

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

[zeesh]:        https://github.com/zeekay/zeesh
[dot-files]:    https://github.com/zeekay/dot-files
[dot-vim]:      https://github.com/zeekay/dot-vim
