function theme
    if test -n "$TMUX"
        cat $HOME/.dotfiles/tmux/$argv-theme.conf > $HOME/.dotfiles/tmux/current-theme.conf \
        && tmux source-file $HOME/.dotfiles/tmux/current-theme.conf
    else
        kitty +kitten themes --reload-in=all Theme-$argv
    end
    cat $HOME/.dotfiles/nvim/lua/config/$argv-theme.lua > $HOME/.dotfiles/nvim/lua/config/current-theme.lua
end
