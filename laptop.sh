#!/usr/bin/env bash
### end common-components/bash-shebang

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

set -e
### end common-components/exit-trap

if [[ ! -d "$HOME/.bin/" ]]; then
  mkdir "$HOME/.bin"
fi

if [ ! -f "$HOME/.zshrc" ]; then
  touch $HOME/.zshrc
fi

if [[ ":$PATH:" != *":$HOME/.bin:"* ]]; then
  printf 'export PATH="$HOME/.bin:$PATH"\n' >> ~/.zshrc
  export PATH="$HOME/.bin:$PATH"
fi
### end common-components/check-home-bin

fancy_echo() {
  printf "\n%b\n" "$1"
}
### end common-components/shared-functions

fancy_echo "Changing your shell to zsh ..."
  chsh -s $(which zsh)
### end common-components/zsh

brew_install_or_upgrade() {
  if brew list -1 | grep -Fqx "$1"; then
    (brew upgrade "$@") || true
  else
    brew install "$@"
  fi
}
### end mac-components/mac-functions

if [[ -f /etc/zshenv ]]; then
  fancy_echo "Fixing OSX zsh environment bug ..."
    sudo mv /etc/{zshenv,zshrc}
fi
### end mac-components/zsh-fix

if ! command -v brew &>/dev/null; then
  fancy_echo "Installing Homebrew, a good OS X package manager ..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

  if ! grep -qs "recommended by brew doctor" ~/.zshrc; then
    fancy_echo "Put Homebrew location earlier in PATH ..."
      printf '\n# recommended by brew doctor\n' >> ~/.zshrc
      printf 'export PATH="/usr/local/bin:$PATH"\n' >> ~/.zshrc
      export PATH="/usr/local/bin:$PATH"
  fi
else
  fancy_echo "Homebrew already installed. Skipping ..."
fi

fancy_echo "Updating Homebrew formulas ..."
brew update
### end mac-components/homebrew
fancy_echo "Removing old git installation and installing git from homebrew..."
  sudo rm -rf /usr/bin/git
  brew_install_or_upgrade 'git'

fancy_echo "Installing vim from Homebrew to get the latest version ..."
  brew_install_or_upgrade 'vim'

fancy_echo "Installing ImageMagick, to crop and resize images ..."
  brew_install_or_upgrade 'imagemagick'

### end mac-components/packages

fancy_echo "Installing rbenv, to change Ruby versions ..."
  brew_install_or_upgrade 'rbenv'

  if ! grep -qs "rbenv init" ~/.zshrc; then
    printf 'export PATH="$HOME/.rbenv/bin:$PATH"\n' >> ~/.zshrc
    printf 'eval "$(rbenv init - zsh --no-rehash)"\n' >> ~/.zshrc

    fancy_echo "Enable shims and autocompletion ..."
      eval "$(rbenv init - zsh)"
  fi

  export PATH="$HOME/.rbenv/bin:$PATH"

fancy_echo "Installing rbenv-gem-rehash so the shell automatically picks up binaries after installing gems with binaries..."
  brew_install_or_upgrade 'rbenv-gem-rehash'

fancy_echo "Installing ruby-build, to install Rubies ..."
  brew_install_or_upgrade 'ruby-build'
### end mac-components/rbenv

fancy_echo "Upgrading and linking OpenSSL ..."
  brew_install_or_upgrade 'openssl'
  brew link openssl --force
### end mac-components/compiler-and-libraries

ruby_version="$(curl -sSL http://ruby.thoughtbot.com/latest)"

fancy_echo "Installing Ruby $ruby_version ..."
  rbenv install -s "$ruby_version"

fancy_echo "Setting $ruby_version as global default Ruby ..."
  rbenv global "$ruby_version"
  rbenv rehash

fancy_echo "Updating to latest Rubygems version ..."
  gem update --system

fancy_echo "Installing Bundler to install project-specific Ruby gems ..."
  gem install bundler --no-document --pre
### end common-components/ruby-environment

fancy_echo "Configuring Bundler for faster, parallel gem installation ..."
  number_of_cores=$(sysctl -n hw.ncpu)
  bundle config --global jobs $((number_of_cores - 1))
### end mac-components/bundler

fancy_echo "Installing Heroku CLI client ..."
  brew_install_or_upgrade 'heroku-toolbelt'

fancy_echo "Installing the heroku-config plugin to pull config variables locally to be used as ENV variables ..."
  heroku plugins:install git://github.com/ddollar/heroku-config.git
### end mac-components/heroku

fancy_echo "Installing GitHub CLI client ..."
  brew_install_or_upgrade 'hub'
### end mac-components/github

fancy_echo "Installing mysql ..."
  brew_install_or_upgrade mysql

fancy_echo "Installing postgresql ..."
  brew_install_or_upgrade postgresql

fancy_echo "Installing mongo ..."
  brew_install_or_upgrade mongodb

fancy_echo "Installing redis ..."
  brew_install_or_upgrade redis

fancy_echo "Installing rabbitmq ..."
  brew_install_or_upgrade rabbitmq

fancy_echo "Installing autojump ..."
  brew_install_or_upgrade autojump

fancy_echo "Installing wget ..."
  brew_install_or_upgrade wget

fancy_echo "Installing nvm ..."
  brew_install_or_upgrade nvm
  printf 'eval "source $(brew --prefix nvm)/nvm.sh"\n' >> ~/.zshrc
  
fancy_echo "Installing node 0.10 ..."
  nvm install 0.10

fancy_echo "Configuring node 0.10 as default ..."
  nvm use 0.10

fancy_echo "Installing icu 51 ..."
  wget http://download.icu-project.org/files/icu4c/51.2/icu4c-51_2-src.tgz
  tar xvf icu4c-51_2-src.tgz
  cd icu/source
  chmod +x runConfigureICU configure install-sh
  ./runConfigureICU MacOSX
  make
  sudo make install

fancy_echo "Installing rmtrash"
  brew_install_or_upgrade rmtrash

fancy_echo "Installing ngrok"
  brew_install_or_upgrade ngrok

fancy_echo "Installing js-hint"
  npm install jshint

fancy_echo "Installing nodemon"
  npm install -g nodemon
### end common-components/personal-additions

