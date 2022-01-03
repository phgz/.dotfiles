function tmux_attach
    tmux has-session -t remote
    and tmux attach-session -t remote
end

function tmux_new_session
    tmux -f $HOME/.config/tmux/tmux.conf new-session -s remote
    and kill %self
end

function initialize_tmux
    set PPID (echo (ps --pid %self -o ppid --no-headers) | xargs)

    if ps --pid $PPID | grep -q ssh
        tmux_attach
        or tmux_new_session
        and kill %self
        or echo "tmux failed to start; using plain fish shell"
    end
end
