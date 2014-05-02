# github.bash
#
# Assorted functions for querying Github for package information and formatting
# responses.

# Search epmi org on Github for a given package.
github.search() {
    curl -s https://api.github.com/search/repositories\?q\=$1+user:epmi+fork:only
}

# List packages forked to epmi org on Github.
github.list_repos() {
    curl -s https://api.github.com/orgs/epmi/repos\?type\=forks
}

# Parses Github JSON API responses into:
#   name         zeekay/alfred
#   description  My alfred dotfiles, ellipsis.sh compatible.
#   homepage     https://github.com/zeekay/dot-alfred
github.format_json() {
    grep -e '"description": "[^"]*[^"]'                      \
         -e '"name": "[^"]*[^"]'                             \
         -e '"homepage": "[^"]*[^"]'                         \
         -e '"default_branch": "[^"]*[^"]'                   \
   | sed -e 's/"default_branch":.*//'                        \
   | cut -f2- -d '"'                                         \
   | sed -E 's/name": "(.+[^-])-(.+[^-])-(.+)/name  \1\/\3/' \
   | sed -e 's/description": "/desc  /'                      \
         -e 's/homepage": "/url   /'                         \
         -e 's/,$//'                                         \
         -e 's/"$//'
}

# Parses Github JSON API responses into:
#   name         zeekay/dot-alfred
#   description  My alfred dotfiles, ellipsis.sh compatible.
#   homepage     https://github.com/zeekay/dot-alfred
#   forks        0
#   watchers     0
github.format_json_long() {
    grep -e '"description": "[^"]*[^"]'                  \
         -e '"name": "[^"]*[^"]'                         \
         -e '"homepage": "[^"]*[^"]'                     \
         -e '"watchers": [^"]*[^"]'                      \
         -e '"forks": [^"]*[^"]'                         \
         -e '"default_branch": "[^"]*[^"]'               \
   | sed -e 's/"default_branch":.*//'                    \
   | cut -f2- -d '"'                                     \
   | sed -e 's/name": "/name      \'$'\033[1m/'          \
         -e 's/-/\//'                                    \
         -e 's/description": "/\'$'\033[0mdesc      /'   \
         -e 's/homepage": "/url       /'                 \
         -e 's/watchers": /watchers  /'                  \
         -e 's/forks": /forks     /'                     \
         -e 's/,$//'                                     \
         -e 's/"$//'
}
