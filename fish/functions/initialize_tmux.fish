function tmux_attach
    tmux has-session -t remote
    and tmux attach-session -t remote
end

function tmux_new_session
    tmux new-session -s remote
end

function initialize_tmux
    set PPID (ps -p %self -o ppid="" | xargs)

    if ps -p $PPID | grep -q ssh
        tmux_attach
        or tmux_new_session
        and kill -15 %self
        or echo "tmux failed to start; using plain fish shell"
    end
end
