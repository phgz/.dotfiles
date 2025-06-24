function initialize_zellij
    set PPID (ps -p %self -o ppid="" | xargs)

    if ps -p $PPID | grep -q ssh
        eval (zellij setup --generate-auto-start fish | string collect)
        or echo "tmux failed to start; using plain fish shell"
    end
end
