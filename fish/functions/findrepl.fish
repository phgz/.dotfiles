function findrepl --description "Find and replace recursively in files in the current directory"
    argparse h/help -- $argv
    or return # exit if argparse failed (found an option it didn't recognize)

    if set -q _flag_help
        echo "findrepl [-h|--help] FILENAME_REGEX BEFORE AFTER"
        return 0
    end

    fd $argv[1] --exec sd $argv[2] $argv[3]
end
