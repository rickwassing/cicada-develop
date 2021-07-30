function [ACT, ids] = cic_undoAnnotation(ACT, annotationType)
% ---------------------------------------------------------
% Undo annotation
ACT.analysis.annotate = rmfield(ACT.analysis.annotate, annotationType);

% ---------------------------------------------------------
% If the acceleration annotation is removed, also remove any existing sleep periods and waso events
ids = [];
if strcmpi(annotationType, 'acceleration')
    rm = selectEventsUsingTime(ACT.analysis.events, ACT.xmin, ACT.xmax, 'Label', 'sleepPeriod', 'Type', 'actigraphy');
    if ~isempty(rm)
        [ACT, id] = cic_editEvents(ACT, 'delete', [], [], 'id', rm.id);
        ids = [ids; id];
    end
    rm = selectEventsUsingTime(ACT.analysis.events, ACT.xmin, ACT.xmax, 'Label', 'waso', 'Type', 'actigraphy');
    if ~isempty(rm)
        [ACT, id] = cic_editEvents(ACT, 'delete', [], [], 'id', rm.id);
        ids = [ids; id];
    end
end

% ---------------------------------------------------------
% Set saved to false
ACT.saved = false;
% ---------------------------------------------------------
% Write history
ACT.history = char(ACT.history, '% ---------------------------------------------------------');
ACT.history = char(ACT.history, '% Undo the annotation step');
ACT.history = char(ACT.history, sprintf('ACT = cic_undoAnnotation(ACT, ''%s'');', annotationType));

end