#!/bin/bash

current_theme_path="$HOME/.dotfiles/theme/current"
current_theme=$(head -n 1 "$current_theme_path")
coordinates="@45.5031824 -73.5698065"

if [ "$current_theme" != "$1" ] && [ "$(/opt/homebrew/bin/sunshine --simple "$coordinates")" = "$1" ]; then
    /bin/ln -fs "$HOME"/.dotfiles/tmux/"$1"-theme.conf "$HOME"/.dotfiles/tmux/current-theme.conf &&
        /opt/homebrew/bin/tmux source-file "$HOME"/.dotfiles/tmux/current-theme.conf 2>/dev/null

    /opt/homebrew/bin/kitty +kitten themes --reload-in=all Theme-"$1" 2>/dev/null

    /bin/cp "$HOME/.dotfiles/nvim/lua/config/$1-theme.lua" "$HOME"/.dotfiles/nvim/lua/config/current-theme.lua
    echo "$1" >>"$HOME/log.txt"
    echo "$1" >"$current_theme_path"
fi
