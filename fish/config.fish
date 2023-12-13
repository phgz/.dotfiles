set -g fish_greeting
string match -q (uname -ms) "Darwin arm64" && fish_add_path /opt/homebrew/bin
fish_add_path $HOME/.local/bin $HOME/.cargo/bin $HOME/.local/node/bin $HOME/.local/wezterm/usr/bin $HOME/.local/nvim/bin $HOME/.miniconda/bin
set -gx MANPATH $HOME/.local/share/man /usr/share/man $MANPATH
set -gx DIRENV_LOG_FORMAT ""

set -gx STARSHIP_CONFIG ~/.config/starship/config.toml
set -gx GHCUP_USE_XDG_DIRS true
set -gx EDITOR nvim
set -gx PYTHONBREAKPOINT pdbr.set_trace
### "bat" as manpager
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

set fish_vi_force_cursor 1
set fish_cursor_default underscore
fish_vi_cursor

bind \ca beginning-of-line
bind \ce end-of-line
bind \c_ kill-line
bind \ck kill-word
bind \cs 'clear; commandline -f repaint'
bind \cc kill-whole-line repaint
bind \cg expand-abbr

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# eval $HOME/.miniconda3/bin/conda "shell.fish" hook $argv | source
# <<< conda initialize <<<

~/.cargo/bin/starship init fish | source
direnv hook fish | source

abbr -ag nv nvim

abbr -ag ga git add
abbr -ag gb git branch
abbr -ag gco git checkout
abbr -ag gcl git clone
abbr -ag gc --set-cursor "git commit -m \"%\""
abbr -ag gd git diff
abbr -ag gf git fetch
abbr -ag gfp git fetch --prune
abbr -ag gl git log
abbr -ag gld git log -p
abbr -ag gg git log --all --decorate --oneline --graph
abbr -ag gpll git pull
abbr -ag gpsh git push
abbr -ag gpu git push -u origin \(git branch --show-current\)
abbr -ag gs git status
abbr -ag gsw git switch
abbr -ag gst git stash -u
abbr -ag gstp git stash pop
abbr -ag gr git restore
abbr -ag gm git merge
abbr -ag gcln git clean -df
abbr -ag gcane git commit --amend --no-edit

abbr 4DIRS --set-cursor=! "$(string join \n -- 'for dir in */' 'cd $dir' '!' 'cd ..' 'end')"

function multicd
    echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end

abbr --add dotdot --regex '^\.\.\.+$' --function multicd

abbr -ag cat bat
abbr -ag ls exa
abbr -ag ll exal
abbr -ag la exal -a
abbr -ag grep rg

# test -t 0 && initialize_tmux
