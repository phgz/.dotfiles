function rw -d "Go back to folder (arg)"
    string match -r '.*'{$argv} (pwd)
end
