function uts
  if set -q TMUX
    eval (tmux show-environment SSH_AUTH_SOCK | sed 's/\=/ /' | sed 's/^/set /')
  end
end
