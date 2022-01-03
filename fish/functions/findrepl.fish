function findrepl --description "Find and replace recursively in files in the current directory"
    argparse h/help -- $argv
    or return # exit if argparse failed (found an option it didn't recognize)

    if set -q _flag_help
        echo "findrepl [-h|--help] FILENAME_REGEX SUBSTITUTION_STRING"
        return 0
    end

    fd $argv[1] | xargs perl -pi -e $argv[2]
end
