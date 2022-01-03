function ssh_agent
  if test -z (pgrep ssh-agent)
      eval (ssh-agent -c)
        #      set -gx SSH_AUTH_SOCK $SSH_AUTH_SOCK
        #      set -gx SSH_AGENT_PID $SSH_AGENT_PID
        #      set -gx SSH_AUTH_SOCK $SSH_AUTH_SOCK
  end
end
