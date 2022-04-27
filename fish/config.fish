set -g fish_greeting
string match -q (uname -ms) "Darwin arm64" && fish_add_path -g /opt/homebrew/bin
fish_add_path -g $HOME/.local/bin $HOME/.cargo/bin $HOME/.local/node/bin
set -gx LD_LIBRARY_PATH $HOME/.local/lib $LD_LIBRARY_PATH
set -gx MANPATH $HOME/.local/share/man $MANPATH

set -gx STARSHIP_CONFIG ~/.config/starship/config.toml
set -gx EDITOR nvim
# set -gx TERM xterm-kitty
set -gx PYTHONBREAKPOINT pdbr.set_trace
### "bat" as manpager
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

bind -M insert \ca beginning-of-line
bind -M insert \ce end-of-line
bind -M insert \ck kill-line
bind -M insert \cn kill-word
bind -M insert \cs 'clear; commandline -f repaint'
bind -M insert \cc kill-whole-line repaint

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
eval $HOME/.miniconda3/bin/conda "shell.fish" "hook" $argv | source
# <<< conda initialize <<<

~/.local/bin/starship init fish | source

abbr -ag :q exit

abbr -ag nv nvim

abbr -ag ga git add
abbr -ag gb git branch
abbr -ag gcl git clone
abbr -ag gc git commit -m
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

# kb
abbr -ag kbl kb list
abbr -ag kbe kb edit
abbr -ag kba kb add
abbr -ag kbv kb view
abbr -ag kbd kb delete --id
abbr -ag kbg kb grep
abbr -ag kbt kb list --tags

abbr -ag cat bat
abbr -ag ls exa
abbr -ag ll exal
abbr -ag la exal -a
abbr -ag grep rg
abbr -ag psh poetry shell

if set -q KITTY_INSTALLATION_DIR
    set --global KITTY_SHELL_INTEGRATION enabled
    source "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_conf.d/kitty-shell-integration.fish"
    set --prepend fish_complete_path "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_completions.d"
end

if set -q KITTY_INSTALLATION_DIR
    set --global KITTY_SHELL_INTEGRATION enabled
    source "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_conf.d/kitty-shell-integration.fish"
    set --prepend fish_complete_path "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_completions.d"
end

test -t 0 && initialize_tmux
