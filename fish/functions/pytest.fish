function pytest
    set PYTHONBREAKPOINT pdb.set_trace
    command pytest --pdb --pdbcls=pdbr:RichPdb $argv
    set PYTHONBREAKPOINT pdbr.set_trace
end
