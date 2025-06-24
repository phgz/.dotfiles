function theme
    if test "$argv" = day
        or test "$argv" = evening
        or test "$argv" = night
        echo $argv >$HOME/.dotfiles/theme/current
        return 0
    end

    set -f current_theme_path $HOME/.dotfiles/theme/current
    set -f current_theme (head -n 1 $current_theme_path)
    set -f current_time (date +%s)

    if test (uname -s) = Linux
        set -f night_start (date -d "$(date +%Y-%m-%d) 00:00:00" "+%s")
        set -f day_start (date -d "$(date +%Y-%m-%d) 06:00:00" "+%s")
    else
        set -f night_start (date -j -f "%Y-%m-%d %H:%M:%S" "$(date +%Y-%m-%d) 00:00:00" "+%s")
        set -f day_start (date -j -f "%Y-%m-%d %H:%M:%S" "$(date +%Y-%m-%d) 06:00:00" "+%s")
    end

    set -f coordinates "@45.5031824 -73.5698065"
    set -f info (sunshine -f %s "$coordinates")
    set -f evening_start (string split ' ' $info[2])[2]

    set -f cycle

    if test $current_time -ge $night_start
        and test $current_time -lt $day_start
        set cycle night
    else if test $current_time -ge $day_start
        and test $current_time -lt $evening_start
        set cycle day
    else
        set cycle evening
    end

    if begin
            test "$current_theme" != $cycle
        end
        echo $cycle >$HOME/.dotfiles/theme/current
        # Helix
        # change config, then
        # pkill -USR1 hx
        # Zellij
        set night solarized-dark
        set day iceberg-light
        set evening gruvbox-dark
        sd "^theme\s.*" "theme \"$$cycle\"" $HOME/.dotfiles/zellij/config.kdl
    end
    echo $cycle

end
