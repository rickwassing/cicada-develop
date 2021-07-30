function ACT = cic_undoStatistics(ACT)
% ---------------------------------------------------------
% If the current step is not statistics, we don't have to undo anything
if ~strcmpi(ACT.pipe{end}, 'statistics')
    return
end

% ---------------------------------------------------------
% Write history
ACT.history = char(ACT.history, '% ---------------------------------------------------------');
ACT.history = char(ACT.history, '% Some statistics have been calculated already, but the next steps require them to be undone');
ACT.history = char(ACT.history, 'ACT = cic_undoStatistics(ACT);');
% ---------------------------------------------------------
% Set saved to false
ACT.saved = false;
% ---------------------------------------------------------
% Remove all statistics tables
fnames = fieldnames(ACT.stats);
fnames(ismember(fnames, {'settings', 'ursettings'})) = [];
ACT.stats = rmfield(ACT.stats, fnames);
% ---------------------------------------------------------
% remove all statistics timeseries
if isfield(ACT.metric, 'average')
    ACT.metric = rmfield(ACT.metric, 'average');
end
if isfield(ACT.metric, 'custom')
    ACT.metric = rmfield(ACT.metric, 'custom');
end
% ---------------------------------------------------------
% Remove the last cell of ACT.pipe
ACT.pipe(end) = [];

end % EOF
