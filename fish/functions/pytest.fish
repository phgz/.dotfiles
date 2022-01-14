function pytest
    set PYTHONBREAKPOINT pdb.set_trace
    command pytest --pdb $argv
    set PYTHONBREAKPOINT pdbr.set_trace
end
