function rmallbut --description "remove all files except those mentioned"
    set toKeep (string join "|" $argv)
    rm -rf (exa --no-icons --ignore-glob="$toKeep")
end
