#!/usr/bin/env bash
#
# scripts/install.sh
# Installer for ellipsis (http://ellipsis.sh).

# Ensure dependencies are installed.
deps=(bash curl git)

for dep in ${deps[*]}; do
    hash "$dep" 2>/dev/null || { echo >&2 "ellipsis requires $dep to be installed."; exit 1; }
done

# Create temp dir.
tmp_dir="$(mktemp -d "${TMPDIR:-tmp}"-XXXXXX)"

# Build the repo url
proto="${ELLIPSIS_PROTO:-https}"
url="${ELLIPSIS_REPO:-$proto://github.com/ellipsis/ellipsis.git}"

# Clone ellipsis into $tmp_dir.
if ! git clone --depth 1 "$url" "$tmp_dir/ellipsis"; then
    # Clean up
    rm -rf "$tmp_dir"

    # Print error message
    echo >&2 "Installation failed!"
    echo >&2 'Please check $ELLIPSIS_REPO and try again!'
    exit 1
fi

# Save reference to specified ELLIPSIS_PATH (if any) otherwise final
# destination: $HOME/.ellipsis.
FINAL_ELLIPSIS_PATH="${ELLIPSIS_PATH:-$HOME/.ellipsis}"

# Temporarily set ellipsis PATH so we can load other files.
ELLIPSIS_PATH="$tmp_dir/ellipsis"
ELLIPSIS_SRC="$ELLIPSIS_PATH/src"

# Initialize ellipsis.
source "$ELLIPSIS_SRC/init.bash"

# Load modules.
load ellipsis
load fs
load os
load msg
load log

ELLIPSIS_PATH="$FINAL_ELLIPSIS_PATH"
ELLIPSIS_SRC="$ELLIPSIS_PATH/src"

# Backup existing ~/.ellipsis if necessary
fs.backup "$ELLIPSIS_PATH"

# Move project into place
if ! mv "$tmp_dir/ellipsis" "$ELLIPSIS_PATH"; then
    # Clean up
    rm -rf "$tmp_dir"

    # Log error
    log.fail "Installation failed!"
    msg.print 'Please check $ELLIPSIS_PATH and try again!'
    exit 1
fi

# Clean up (only necessary on cygwin, really).
rm -rf "$tmp_dir"

# Backwards compatibility, originally referred to packages as modules.
PACKAGES="${PACKAGES:-$MODULES}"

if [ "$PACKAGES" ]; then
    msg.print ''
    for pkg in ${PACKAGES[*]}; do
        msg.bold "Installing $pkg"
        ellipsis.install "$pkg"
    done
fi

msg.print '
                                   ~ fin ~
   _    _    _
  /\_\ /\_\ /\_\
  \/_/ \/_/ \/_/                         …because $HOME is where the <3 is!

Be sure to add `export PATH=~/.ellipsis/bin:$PATH` to your bashrc or zshrc.

Run `ellipsis install <package>` to install a new package.
Run `ellipsis search <query>` to search for packages to install.
Run `ellipsis help` for additional options.'

if [ -z "$PACKAGES" ]; then
    msg.print ''
    msg.print 'Check http://ellipsis.readthedocs.org/en/master/pkgindex for available packages!'
fi
