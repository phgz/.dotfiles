function restore --argument filename
    set original_name (string match -r '(.*).bak' $filename)[2]
    echo restoring $filename to $original_name
    mv $filename $original_name
end
