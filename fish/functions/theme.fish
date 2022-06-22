function theme
    cat $HOME/.dotfiles/tmux/$argv-theme.conf > $HOME/.dotfiles/tmux/current-theme.conf \
    && tmux source-file $HOME/.dotfiles/tmux/current-theme.conf 2> /dev/null

    kitty +kitten themes --reload-in=all Theme-$argv 2> /dev/null

    cat $HOME/.dotfiles/nvim/lua/config/$argv-theme.lua > $HOME/.dotfiles/nvim/lua/config/current-theme.lua
end
