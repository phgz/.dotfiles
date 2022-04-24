function theme
    if test -n "$TMUX"
        tmux source-file $HOME/.dotfiles/tmux/$argv-theme.conf
    else
        kitty +kitten themes --reload-in=all Theme-$argv
    end
    cat $HOME/.dotfiles/nvim/lua/config/$argv-theme.lua > $HOME/.dotfiles/nvim/lua/config/current-theme.lua
end
