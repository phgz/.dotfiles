function pytest
    set PYTHONBREAKPOINT pdb.set_trace
    command pytest --pdb $argv[1]
    set PYTHONBREAKPOINT pdbr.set_trace
end
