function [ACT, ids] = cic_undoAnnotation(ACT)
% ---------------------------------------------------------
% Undo annotation
ACT.analysis.annotate.acceleration.Data = zeros(size(ACT.analysis.annotate.acceleration.Data));
% ---------------------------------------------------------
% Remove any existing sleep periods and waso events
ids = [];
rm = selectEventsUsingTime(ACT.events, ACT.xmin, ACT.xmax, 'Label', 'sleepPeriod', 'Type', 'actigraphy');
if ~isempty(rm)
    [ACT, id] = cic_editEvents(ACT, 'delete', [], [], 'id', rm.id);
    ids = [ids; id];
end
rm = selectEventsUsingTime(ACT.events, ACT.xmin, ACT.xmax, 'Label', 'waso', 'Type', 'actigraphy');
if ~isempty(rm)
    [ACT, id] = cic_editEvents(ACT, 'delete', [], [], 'id', rm.id);
    ids = [ids; id];
end

% ---------------------------------------------------------
% Set saved to false
ACT.saved = false;
% ---------------------------------------------------------
% Write history
ACT.history = char(ACT.history, '% ---------------------------------------------------------');
ACT.history = char(ACT.history, '% Undo the annotation step');
ACT.history = char(ACT.history, 'ACT = cic_undoAnnotation(ACT);');

end