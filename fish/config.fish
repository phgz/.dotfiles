set -g fish_greeting
string match -q (uname -ms) "Darwin arm64" && fish_add_path /opt/homebrew/bin
fish_add_path $HOME/.local/bin $HOME/.cargo/bin $HOME/.local/nvim/bin $HOME/.miniconda3/bin $HOME/.local/share/nvim/mason/bin
set -gx MANPATH $HOME/.local/share/man /usr/share/man $MANPATH
set -gx DIRENV_LOG_FORMAT ""

set -gx STARSHIP_CONFIG ~/.config/starship/config.toml
set -gx EDITOR nvim
set -gx PYTHONBREAKPOINT pdbr.set_trace
# "bat" as manpager
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

set fish_vi_force_cursor 1
set fish_cursor_default line
fish_vi_cursor

bind ctrl-a beginning-of-buffer
bind ctrl-e end-of-buffer
bind ctrl-_ kill-line
bind ctrl-k kill-word
bind alt-d kill-bigword
# bind ctrl-c cancel-commandline # now defaults to clear commandline
# ctrl-x copies text to the clipboard
# alt-e to edit command in $EDITOR
# ctrl-space to not expand abbr
# alt-# toggle line commenting
# alt-u uppercase-word
# alt-s toggle sudo
# alt-w what is under cursor
# alt-o open preview of file
# ctrl-z undo typing
bind ctrl-g expand-abbr
bind shift-up history-search-backward # shift up
bind shift-down history-search-forward # Shift down

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# eval $HOME/.miniconda3/bin/conda "shell.fish" hook $argv | source
# <<< conda initialize <<<

~/.cargo/bin/starship init fish | source
direnv hook fish | source

abbr -ag nv nvim

abbr -a --position anywhere -- --help '--help | bat -plhelp'
abbr -a --position anywhere -- -h '-h | bat -plhelp'

abbr -ag ga git add
abbr -ag gb git branch
abbr -ag gco git checkout
abbr -ag gcl git clone
abbr -ag gcp git cherry-pick
abbr -ag gc --set-cursor "git commit -m \"%\""
abbr -ag gd git diff
abbr -ag gds git diff --staged
abbr -ag gdg --set-cursor "git diff --name-only -G \"%\""
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
abbr -ag gst git stash
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
abbr --add projrootdir --position anywhere --regex '^prd$' --function prd

abbr -ag cat bat
abbr -ag ls eza
abbr -ag ll ezal
abbr -ag la ezal -a
abbr -ag grep rg

test -t 0 && initialize_tmux
