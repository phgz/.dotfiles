#!/bin/bash

HOME=/Users/philip

ln -fs $HOME/.dotfiles/tmux/"$1"-theme.conf $HOME/.dotfiles/tmux/current-theme.conf &&
    /opt/homebrew/bin/tmux source-file $HOME/.dotfiles/tmux/current-theme.conf 2>/dev/null

/opt/homebrew/bin/kitty +kitten themes --reload-in=all Theme-"$1" 2>/dev/null

cp $HOME/.dotfiles/nvim/lua/config/"$1-theme".lua $HOME/.dotfiles/nvim/lua/config/current-theme.lua
