function cdpr --description "cd project root"
    if test -n "$argv[1]"
        set path (realpath $argv[1])

    else
        set path (pwd)
    end
    cd (string split / $path | head -n 4 | string join /)
end

function cdpd --description "cd parent directory"
    cd (string split / $argv[1] | head -n -1 | string join /)
end
