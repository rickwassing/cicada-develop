function ACT = cic_savemat(ACT, fullpath)
% ---------------------------------------------------------
% Write history
ACT.history = char(ACT.history, '% ---------------------------------------------------------');
ACT.history = char(ACT.history, '% Save ACT structure to .mat file');
ACT.history = char(ACT.history, sprintf('ACT = cic_savemat(ACT, ''%s'');', fullpath));
% ---------------------------------------------------------
% Save the file
[fpath, fname] = fileparts(fullpath);
ACT.filename = fname;
ACT.filepath = fpath;
ACT.saved    = true;
save(fullpath, 'ACT', '-v7.3')

end % EOF
