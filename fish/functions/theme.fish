function theme
    if test "$argv" = day
        or test "$argv" = night
        or test "$argv" = midnight
        or test "$argv" = transition
        echo $argv >$HOME/.dotfiles/theme/current
        return 0
    end

    set -f current_theme_path $HOME/.dotfiles/theme/current
    set -f system_mode (head -n 1 $current_theme_path)
    set -f coordinates "@45.5031824 -73.5698065"
    set -f info (sunshine -f %s "$coordinates")
    set -f sunrise (string split ' ' $info[1])[2]
    set -f sunset (string split ' ' $info[2])[2]
    set -f midnight (date -j -f "%Y-%m-%d %H:%M:%S" "$(date +%Y-%m-%d) 00:00:00" "+%s")
    set -f current (date +%s)

    set -f choices day night midnight
    set -f diffs

    for event in $sunrise $sunset $midnight
        set -a diffs (math $current - $event)
    end
    set -f dists

    for diff in $diffs
        set -a dists (math abs $diff)
    end
    set -f seeking $choices[1]
    set -f dist $dists[1]
    set -f diff $diffs[1]

    for i in 2 3
        if test $dists[$i] -lt $dist
            set dist $dists[$i]
            set seeking $choices[$i]
            set diff $diffs[$i]
        end
    end

    set -f cycle

    if test $current -ge $midnight
        and test $current -lt $sunrise
        set cycle midnight
    else if test $current -ge $sunrise
        and test $current -lt $sunset
        set cycle day
    else
        set cycle night
    end

    echo current $current >>/Users/philip/theme-status.txt
    echo sunrise $sunrise >>/Users/philip/theme-status.txt
    echo sunset $sunset >>/Users/philip/theme-status.txt
    echo midnight $midnight >>/Users/philip/theme-status.txt
    echo seeking $seeking >>/Users/philip/theme-status.txt
    echo cycle $cycle >>/Users/philip/theme-status.txt
    echo --- >>/Users/philip/theme-status.txt

    if test "$seeking" != "$cycle"
        and test $seeking != midnight
        and test $diff -lt 0
        and test $dist -le 7200
        set seeking transition
        set cycle transition
    end

    echo $seeking >>/Users/philip/theme-status.txt
    echo $diff >>/Users/philip/theme-status.txt
    echo $cycle >>/Users/philip/theme-status.txt

    if begin
            test "$seeking" = $cycle
            and test "$system_mode" != $seeking
        end
        echo $seeking >$HOME/.dotfiles/theme/current
    end

end
