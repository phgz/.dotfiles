function lines --argument arg
    set -f sum 0
    if test -d $arg
        for file in (fd -t f . $arg)
            set sum (math $sum + (cat $file | count))
        end
        echo $sum
    else
        cat $arg | count
    end
end
