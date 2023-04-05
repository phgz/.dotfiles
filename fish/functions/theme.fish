function theme
    set -l options (fish_opt -s f -l force)
    argparse $options -- $argv

    if test "$argv" != day
        and test "$argv" != night
        return 1
    end

    set -f current_theme_path $HOME/.dotfiles/theme/current
    set -f current_theme (head -n 1 $current_theme_path)
    set -f coordinates "@45.5031824 -73.5698065"

    if set -q _flag_force
        or begin
            test "$current_theme" != $argv
            and test (sunshine --simple "$coordinates") = $argv
        end

        /bin/ln -fs $HOME/.dotfiles/tmux/$argv-theme.conf $HOME/.dotfiles/tmux/current-theme.conf \
            && tmux source-file $HOME/.dotfiles/tmux/current-theme.conf 2>/dev/null

        kitty +kitten themes --reload-in=all Theme-$argv 2>/dev/null

        /bin/cp $HOME/.dotfiles/nvim/theme/lua/$argv-theme.lua $HOME/.dotfiles/nvim/theme/lua/current-theme.lua

        echo $argv >$HOME/.dotfiles/theme/current
    end

end
