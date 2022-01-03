function lines 
    set sum 0
    for file in (fd)
        if test -f $file
            set sum (math $sum + (bat $file | count))
        end
    end
    echo $sum
end
