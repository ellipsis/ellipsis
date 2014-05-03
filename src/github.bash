# github.bash
#
# Assorted functions for querying Github for package information and formatting
# responses.

# Search ellipsis-index org on Github for a given package.
github.search() {
    curl -s https://api.github.com/search/repositories\?q\=$1+user:ellipsis-index+fork:only
}

# List packages forked to ellipsis-index org on Github.
github.list_repos() {
    curl -s https://api.github.com/orgs/ellipsis-index/repos\?type\=forks
}

# Parses Github JSON API responses into:
#   name         zeekay/alfred
#   description  My alfred dotfiles, ellipsis.sh compatible.
#   homepage     https://github.com/zeekay/dot-alfred
github.format_json() {
    grep -e '"total_count": '                                \
         -e '"description": "[^"]*[^"]'                      \
         -e '"name": "[^"]*[^"]'                             \
         -e '"homepage": "[^"]*[^"]'                         \
         -e '"items": \['                                    \
         -e '"default_branch": "[^"]*[^"]'                   \
   | sed -e 's/"default_branch":.*//'                        \
   | sed -e 's/"items": \[//'                                \
   | cut -f2- -d '"'                                         \
   | sed -E 's/name": "(.+[^-])-(.+[^-])-(.+)/name  \1\/\3/' \
   | sed -E 's/total_count": ([0-9]+)/matches: \1/'          \
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
