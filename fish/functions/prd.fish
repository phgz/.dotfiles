function prd --description "get project root directory"
    set path (pwd)
    echo (string split / $path | head -n 4 | string join /)
end
