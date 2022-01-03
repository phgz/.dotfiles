function jump -d "cd to folder and mark current position"
    if set -q $argv
        cd $LAST_DIR
   else
        set -g LAST_DIR (pwd)
        cd $argv
    end
end
