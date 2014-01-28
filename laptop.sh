trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

set -e

if [ ! -d "$HOME/.bin/" ]; then
  mkdir "$HOME/.bin"
fi

if [[ ":$PATH:" != *":$HOME/.bin:"* ]]; then
  echo 'export PATH="$HOME/.bin:$PATH"' >> ~/.zshrc
  source ~/.zshrc
fi

fancy_echo() {
  printf "\n%b\n" "$1"
}

if [[ -f /etc/zshenv ]]; then
  fancy_echo "Fixing OSX zsh environment bug ..."
    sudo mv /etc/{zshenv,zshrc}
fi

if (( ! $+commands[brew] )); then
  fancy_echo "Installing Homebrew, a good OS X package manager ..."
    ruby <(curl -fsSL https://raw.github.com/mxcl/homebrew/go/install)
    brew update

  if ! grep -qs "recommended by brew doctor" ~/.zshrc; then
    fancy_echo "Put Homebrew location earlier in PATH ..."
      echo "\n# recommended by brew doctor" >> ~/.zshrc
      echo "export PATH=\"/usr/local/bin:\$PATH\"\n" >> ~/.zshrc
      source ~/.zshrc
  fi
else
  fancy_echo "Homebrew already installed. Skipping ..."
fi

fancy_echo "Installing Postgres, a good open source relational database ..."
  brew install postgres --no-python

fancy_echo "Installing MySQL ..."
  brew install mysql
  
fancy_echo "Installing The Silver Searcher (better than ack or grep) to search the contents of files ..."
  brew install the_silver_searcher

fancy_echo "Installing vim from Homebrew to get the latest version ..."
  brew install vim

fancy_echo "Installing ImageMagick, to crop and resize images ..."
  brew install imagemagick

fancy_echo "Installing rbenv, to change Ruby versions ..."
  brew install rbenv

  if ! grep -qs "rbenv init" ~/.zshrc; then
    echo 'eval "$(rbenv init - --no-rehash)"' >> ~/.zshrc

    fancy_echo "Enable shims and autocompletion ..."
      eval "$(rbenv init -)"
  fi

  source ~/.zshrc

fancy_echo "Installing rbenv-gem-rehash so the shell automatically picks up binaries after installing gems with binaries..."
  brew install rbenv-gem-rehash

fancy_echo "Installing ruby-build, to install Rubies ..."
  brew install ruby-build

fancy_echo "Installing GNU Compiler Collection, a necessary prerequisite to installing Ruby ..."
  brew tap homebrew/dupes
  brew install apple-gcc42

fancy_echo "Upgrading and linking OpenSSL ..."
  brew install openssl

fancy_echo "Installing sphinx 0.9.9 ..."
  brew install https://raw.github.com/rnaveiras/homebrew-sphinx/master/sphinx.rb

fancy_echo "Installing rabbitmq ..."
  brew install rabbitmq

fancy_echo "Installing autojump ..."
  brew install autojump

fancy_echo "Installing s3cmd: bj tool dependency ..."
  brew install s3cmd

fancy_echo "Installing pv bj tool dependency ..."
  brew install pv
  
export CC=gcc-4.2

fancy_echo "Installing Ruby 2.0.0-p353 ..."
  rbenv install 2.0.0-p353

fancy_echo "Setting Ruby 2.0.0-p353 as global default Ruby ..."
  rbenv global 2.0.0-p353
  rbenv rehash

fancy_echo "Updating to latest Rubygems version ..."
  gem update --system

fancy_echo "Installing Bundler to install project-specific Ruby gems ..."
  gem install bundler --no-document --pre

fancy_echo "Installing Rails ..."
  gem install rails --no-document

fancy_echo "Installing GitHub CLI client ..."
  curl http://hub.github.com/standalone -sLo ~/.bin/hub
  chmod +x ~/.bin/hub

fancy_echo "Configuring Bundler for faster, parallel gem installation ..."
  number_of_cores=`sysctl -n hw.ncpu`
  bundle config --global jobs `expr $number_of_cores - 1`

fancy_echo "Installing Heroku CLI client ..."
  brew install heroku-toolbelt

fancy_echo "Installing the heroku-config plugin to pull config variables locally to be used as ENV variables ..."
  heroku plugins:install git://github.com/ddollar/heroku-config.git