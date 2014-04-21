
EOF

# shim for ellipsis install.sh
#
# This is used on ellipsis.sh to bootstrap the full installer, which you
# otherwise can't curl and pipe to sh (as it requires bash). Not meant to be
# run standalone.

# wait for curl output to finish
sleep 0.5

# Ensure dependencies are installed.
deps=(bash curl git)

for dep in ${deps[*]}; do
    hash $dep 2>/dev/null || { echo >&2 "ellipsis requires $dep to be installed."; exit 1; }
done

# Download full installer and execute with bash
curl -sL https://raw.githubusercontent.com/zeekay/ellipsis/master/scripts/install.sh > install-$$.sh
bash install-$$.sh

# Clean up
rm install-$$.sh
