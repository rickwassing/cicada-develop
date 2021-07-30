function ACT = cic_writeHistory(ACT, fullpath)
% ---------------------------------------------------------
% Write the history to file
fid = fopen(fullpath, 'w');
for l = 1:size(ACT.history, 1)
    fprintf(fid, '%s\n', deblank(ACT.history(l, :)));
end
fclose(fid);

end % EOF
