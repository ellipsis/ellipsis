#!/bin/sh

# I need this stuff installed to operate. Specifically for OSX.

# Install homebrew
/usr/bin/ruby -e "$(/usr/bin/curl -fsSL https://raw.github.com/mxcl/homebrew/master/Library/Contributions/install_homebrew.rb)"

# Use homebrew to install a few necessities
brew install \
    ack \
    cloc \
    clojure \
    cmake \
    cowsay \
    ctags \
    dos2unix \
    elinks \
    fuse4x \
    fuse4x-kext \
    gettext \
    gist \
    git \
    haskell-platform \
    html2text \
    https://raw.github.com/Homebrew/homebrew-dupes/master/grep.rb \
    https://raw.github.com/Homebrew/homebrew-dupes/master/httpd.rb \
    https://raw.github.com/Homebrew/homebrew-games/master/nethack.rb \
    hub \
    lame \
    leiningen \
    libev \
    libevent \
    macvim \
    mercurial \
    mongodb \
    node \
    pianobar \
    postgresql \
    pypy \
    pyqt \
    pyside \
    pyside-tools \
    python \
    python3 \
    readline \
    redis \
    rhino \
    riak \
    rlwrap \
    ruby \
    sqlite \
    ssh-copy-id \
    sshfs \
    tmux \
    tree \
    unrar \
    valgrind \
    vimpager \
    wget \
    z \
    zeromq \
    zsh

# brew refuses to install npm for whatever reason
curl http://npmjs.org/install.sh | sh

# Install node.js utilities
npm install -g \
    coffee-script \
    coffeelint \
    chai \
    cdir \
    docco \
    html2jade \
    jitsu \
    js2coffee \
    jsontool \
    mocha

rehash

# Ruby gems
gem install CoffeeTags
gem install git-issues

# Python packages
pip install httpie
pip install virtualenv

# Clojure
lein plugin install org.clojars.ibdknox/lein-nailgun 1.1.1

# Install syntax checkers
cabal install ghc-mod
npm install -g jshint
pip install flake8
