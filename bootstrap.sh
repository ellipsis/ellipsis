#!/bin/sh

# I need this stuff installed to operate. Specifically for OSX.

# Install homebrew
/usr/bin/ruby -e "$(/usr/bin/curl -fsSL https://raw.github.com/mxcl/homebrew/master/Library/Contributions/install_homebrew.rb)"

export PATH=/usr/local/bin:/usr/local/share/python:$PATH

# Use homebrew to install a few necessities
brew install libevent
brew link libevent
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
    gnu-sed \
    gist \
    git \
    haskell-platform \
    html2text \
    https://raw.github.com/Homebrew/homebrew-dupes/master/grep.rb \
    https://raw.github.com/Homebrew/homebrew-dupes/master/httpd.rb \
    https://raw.github.com/Homebrew/homebrew-games/master/nethack.rb \
    https://raw.github.com/simonair/homebrew-dupes/e5177ef4fc82ae5246842e5a544124722c9e975b/ab.rb \
    hub \
    lame \
    leiningen \
    libev \
    https://raw.github.com/gist/3046782/099ff1aea934fc1169babfbb57b985f55f735d91/macvim.rb \
    mercurial \
    mongodb \
    netcat \
    node \
    pianobar \
    postgresql \
    pypy \
    python \
    python3 \
    readline \
    redis \
    repl \
    rhino \
    riak \
    ruby \
    spidermonkey \
    ssh-copy-id \
    sshfs \
    tmux \
    tree \
    unrar \
    vimpager \
    watch \
    wget \
    z \
    zeromq \
    zsh

# links apps installed by homebrew
brew linkapps

# Add zsh to list of shells
sudo sh -c "echo /usr/local/bin/zsh >> /etc/shells"

# Fix apple misconfiguration so Zsh has proper PATH
sudo mv /etc/zshenv /etc/zprofile

# Install fuse4x kext
sudo cp -rfX /usr/local/Cellar/fuse4x-kext/0.9.1/Library/Extensions/fuse4x.kext /Library/Extensions
sudo chmod +s /Library/Extensions/fuse4x.kext/Support/load_fuse4x

# Update cabal
cabal update

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

# Ruby gems
gem install CoffeeTags
gem install git-issues

# Python packages
easy_install pip
pip install httpie
pip install virtualenv

# Clojure
lein plugin install org.clojars.ibdknox/lein-nailgun 1.1.1

# Install syntax checkers
cabal install ghc-mod
npm install -g jshint
pip install flake8
