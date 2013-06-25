# Install homebrew
ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"

export PATH=/usr/local/bin:$PATH

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
    sshfs \
    gnu-sed \
    git \
    haskell-platform \
    html2text \
    https://raw.github.com/Homebrew/homebrew-games/master/nethack.rb \
    hub \
    lame \
    leiningen \
    libev \
    macvim \
    mercurial \
    mkvtoolnix \
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
    zeromq

brew install zsh --disable-etcdir
brew install --HEAD ffmpeg
brew install --HEAD https://raw.github.com/pigoz/homebrew-mplayer2/master/Formula/mplayer2.rb

# install wc3 version of tidy, which is a head only formula
brew install https://raw.github.com/gist/3790109/373a9eb28d41ee413caf189cdb1d3044bec24857/tidy-html5.rb --HEAD

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
    cdir \
    chai \
    coffee-script \
    coffeelint \
    csslint \
    docco \
    html2jade \
    jitsu \
    js2coffee \
    jshint \
    jsontool \
    mocha

# Ruby gems
gem install CoffeeTags
gem install git-issues
gem install coloration
gem install jist

# Python packages
pip install httpie
pip install virtualenv
pip install flake8

# Clojure
lein plugin install org.clojars.ibdknox/lein-nailgun 1.1.1

# Haskell
cabal install ghc-mod pandoc
# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.osx` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

sudo scutil --set ComputerName "qi"
sudo scutil --set HostName "qi"
sudo scutil --set LocalHostName "qi"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "qi"

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Disable the crash reporter
defaults write com.apple.CrashReporter DialogType -string "none"

# Check for software updates daily, not just once per week
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Restart automatically if the computer freezes
systemsetup -setrestartfreeze on

# Never go into computer sleep mode
# systemsetup -setcomputersleep Off > /dev/null

# Reveal IP address, hostname, OS version, etc. when clicking the clock
# in the login window
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Trackpad: swipe between pages with three fingers
defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerHorizSwipeGesture -int 1
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 1

# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Automatically illuminate built-in MacBook keyboard in low light
defaults write com.apple.BezelServices kDim -bool true
# Turn off keyboard illumination when computer is not used for 5 minutes
defaults write com.apple.BezelServices kDimTime -int 300

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Enable subpixel font rendering on non-Apple LCDs
# defaults write NSGlobalDomain AppleFontSmoothing -int 2

# Enable HiDPI display modes (requires restart)
sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

# Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
defaults write com.apple.finder QuitMenuItem -bool true

# Finder: allow text selection in Quick Look
defaults write com.apple.finder QLEnableTextSelection -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Disable disk image verification
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

# Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Enable AirDrop over Ethernet and on unsupported Macs running Lion
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

# Enable the MacBook Air SuperDrive on any Mac
sudo nvram boot-args="mbasd=1"

# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true

# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1

# Don’t group windows by application in Mission Control
# (i.e. use the old Exposé behavior instead)
defaults write com.apple.dock expose-group-by-app -bool false

# Disable Dashboard
defaults write com.apple.dashboard mcx-disabled -bool true

# Don’t show Dashboard as a Space
defaults write com.apple.dock dashboard-in-overlay -bool true

# Allow hitting the Backspace key to go to the previous page in history
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true

# Hide Safari’s bookmarks bar by default
defaults write com.apple.Safari ShowFavoritesBar -bool false

# Disable Safari’s thumbnail cache for History and Top Sites
defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

# Enable Safari’s debug menu
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

# Make Safari’s search banners default to Contains instead of Starts With
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

# Remove useless icons from Safari’s bookmarks bar
# defaults write com.apple.Safari ProxiesInBookmarksBar "()"

# Enable the Develop menu and the Web Inspector in Safari
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

# Only use UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4

# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Disable local Time Machine backups
hash tmutil &> /dev/null && sudo tmutil disablelocal

# Use plain text mode for new TextEdit documents
defaults write com.apple.TextEdit RichText -int 0
# Open and save files as UTF-8 in TextEdit
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

# Enable the debug menu in Disk Utility
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
defaults write com.apple.DiskUtility advanced-image-options -bool true

# Allow installing user scripts via GitHub or Userscripts.org
defaults write com.google.Chrome ExtensionInstallSources -array "https://*.github.com/*" "http://userscripts.org/*"
defaults write com.google.Chrome.canary ExtensionInstallSources -array "https://*.github.com/*" "http://userscripts.org/*"

# Disable smart quotes as it’s annoying for code tweets
defaults write com.twitter.twitter-mac AutomaticQuoteSubstitutionEnabled -bool false

# Open links in the background
defaults write com.twitter.twitter-mac openLinksInBackground -bool true

# Allow closing the ‘new tweet’ window by pressing `Esc`
defaults write com.twitter.twitter-mac ESCClosesComposeWindow -bool true
