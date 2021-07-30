function ACT = cic_createRelativeEvent(ACT, ref, refLabel, refType, delay, duration, newLabel)
% ---------------------------------------------------------
% Calculate onset based on the onset or offset of the events
idx = strcmpi(ACT.analysis.events.label, refLabel) & strcmpi(ACT.analysis.events.type, refType);
switch ref
    case 'onset'
        onset = ACT.analysis.events.onset(idx) + delay/24; % onset of the events plus the delay
    case 'offset'
        onset = ACT.analysis.events.onset(idx) + ACT.analysis.events.duration(idx) + delay/24; % offset of the events plus delay
end
% ---------------------------------------------------------
% Add events
ACT = cic_editEvents(ACT, 'add', onset, repmat(duration/24, sum(idx), 1), 'Label', newLabel, 'Type', 'customEvent');
% ---------------------------------------------------------
% Set saved to false
ACT.saved = false;
% ---------------------------------------------------------
% Update the pipeline
ACT = cic_updatePipe(ACT, 'preproc');
% ---------------------------------------------------------
% Write history
ACT.history = char(ACT.history, '% ---------------------------------------------------------');
ACT.history = char(ACT.history, '% Create new events relative to existing events');
ACT.history = char(ACT.history, sprintf('ref = ''%s''; %% new events are relative to the %s of existing events', ref, ref));
ACT.history = char(ACT.history, sprintf('refLabel = ''%s''; %% label of existing events', refLabel));
ACT.history = char(ACT.history, sprintf('refType = ''%s''; %% type of existing events', refType));
if mod(delay, 1) == 0
    ACT.history = char(ACT.history, sprintf('delay = %i; %% onset of new events = %s delay relative to %s of existing events in hours', delay, ifelse(delay > 0, 'positive', 'negative'), ref));
else
    ACT.history = char(ACT.history, sprintf('delay = %.4f; %% onset of new events = %s delay relative to %s of existing events in hours', delay, ifelse(delay > 0, 'positive', 'negative'), ref));
end
if mod(duration, 1) == 0
    ACT.history = char(ACT.history, sprintf('duration = %i; %% new events duration in hours', duration));
else
    ACT.history = char(ACT.history, sprintf('duration = %.4f; %% new events duration in hours', duration));
end
ACT.history = char(ACT.history, '% Create the new relative events');
ACT.history = char(ACT.history, sprintf('ACT = cic_createRelativeEvent(ACT, ref, refLabel, refType, delay, duration, ''%s''); %% event label', newLabel));

end % EOF
