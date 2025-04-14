function hx --description "run helix with a random theme"
    nu -c "open $HOME/.dotfiles/helix/config.toml | update theme $(_random_helix_theme (theme)) | save -f $HOME/.dotfiles/helix/config.toml"
    command hx $argv
end
