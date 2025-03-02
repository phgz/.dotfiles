function gitmodpattern --description "get git modified files that contains `pattern`"
    git diff | rg -B 10 "$argv" | awk '/^diff --git/{print $3}' | sd '^a/' '' | sort | uniq
end
