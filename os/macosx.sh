#!/bin/bash

set -x

if type brew >/dev/null 2>&1; then
    echo "brew installed"
else
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

HOMEBREW_NO_AUTO_UPDATE=1

brew cask install java8
brew install gradle maven

pip2 install pygments