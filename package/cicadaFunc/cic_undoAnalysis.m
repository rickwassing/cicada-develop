function ACT = cic_undoAnalysis(ACT)
% ---------------------------------------------------------
% Undo statistics if necessary
if strcmpi(ACT.pipe{end}, 'statistics')
    ACT = cic_undoStatistics(ACT);
end
% ---------------------------------------------------------
% If the current step is not analysis, we don't have to undo anything
if ~strcmpi(ACT.pipe{end}, 'analysis')
    return
end

% ---------------------------------------------------------
% Write history
ACT.history = char(ACT.history, '% ---------------------------------------------------------');
ACT.history = char(ACT.history, '% Some analyses have been run already, but the next steps require them to be undone');
ACT.history = char(ACT.history, 'ACT = cic_undoAnalysis(ACT);');
% ---------------------------------------------------------
% Set saved to false
ACT.saved = false;
% ---------------------------------------------------------
% Undo Annotate Epochs > GGIR annotation
ACT.analysis.annotate.Data = zeros(ACT.analysis.annotate.Length, 1);
% ---------------------------------------------------------
% If there is no sleep window, then we're done
if ~isfield(ACT.analysis.settings, 'sleepWindowType')
    return
end
% ---------------------------------------------------------
% Undo Events > GGIR sleep detection
ACT = cic_editEvents(ACT, 'delete', [], [], 'Label', 'sleepWindow', 'Type', 'GGIR');
% ---------------------------------------------------------
% If the sleep window type is GGIR, we'll reset it to 'manual'
if strcmpi(ACT.analysis.settings.sleepWindowType, 'GGIR')
    ACT.analysis.settings.sleepWindowType = 'manual';
end
% ---------------------------------------------------------
% Remove the last cell of ACT.pipe
ACT.pipe(end) = [];
% ---------------------------------------------------------
% Re-analyse the manual sleep windows, and set pipe to analysis if successful
ACT = cic_actigraphySleepEvents(ACT);

end % EOF
