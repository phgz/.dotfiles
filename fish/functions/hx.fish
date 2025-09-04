function hx --description "run helix with a random theme"
    command hx --config (sed "1i\\
theme='$(_random_helix_theme (theme))'
    " $HOME/.dotfiles/helix/config.toml | psub) $argv
end
