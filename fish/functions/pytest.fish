function pytest
    set PYTHONBREAKPOINT pdb.set_trace
    command pytest --pdb --pdbcls=pdbr:RichPdb -vvv $argv
    set PYTHONBREAKPOINT pdbr.set_trace
end
