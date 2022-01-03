function compare -d "Compare a file with the same one from a different commit or branch"
    set suffix (string match -r '.*(\..*)' $argv[2])[2]
    nvim -d (git show $argv[1]:$argv[2] | psub -f -s $suffix) $argv[2]
end
