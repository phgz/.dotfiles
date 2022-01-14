function grbu --description "get git remote branch url"
    git remote get-url --push origin | string replace -r "(https://)(.*?@)" '$1'
end
