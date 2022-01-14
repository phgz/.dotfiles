function cdpd --description "cd parent directory"
    cd (string split / $argv[1] | head -n -1 | string join /)
end
