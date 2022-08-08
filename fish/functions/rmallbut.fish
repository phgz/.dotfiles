function rmallbut --description "remove all files except those mentioned"
    set toKeep (string join "|" $argv)
    rm (exa --no-icons --ignore-glob="$toKeep")
end
