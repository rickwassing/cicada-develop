function ACT = cic_createDailyEvent(ACT, onset, duration, label, days)
% ---------------------------------------------------------
% Convert onset
if ~isnumeric(onset)
    onset = mod(datenum(onset, 'HH:MM'), 1); % We'll assume that if onset is not a nummeric value in units 'day', it is specified as 'HH:MM'
end
% ---------------------------------------------------------
% Repeat 'onset' for each day in the recording
startDay = floor(ACT.xmin);
endDay = ceil(ACT.xmax);
onset = startDay + onset : endDay + onset;
onset(onset < ACT.xmin | onset+(duration/24) > ACT.xmax) = [];
% ---------------------------------------------------------
% Remove the days that are not in 'days'
daystring = {'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'};
onset = onset(ismember(datestr(onset, 'ddd'), daystring(days == 1)));
% ---------------------------------------------------------
% Add events
ACT = cic_editEvents(ACT, 'add', onset, repmat(duration/24, length(onset), 1), 'Label', label, 'Type', 'customEvent');
% ---------------------------------------------------------
% Set saved to false
ACT.saved = false;
% -----------------------------------------------onset----------
% Update the pipeline
ACT = cic_updatePipe(ACT, 'preproc');
% ---------------------------------------------------------
% Write history
ACT.history = char(ACT.history, '% ---------------------------------------------------------');
ACT.history = char(ACT.history, '% Create daily events');
ACT.history = char(ACT.history, sprintf('onset = ''%s''; %% daily event onset at ''HH:MM''', datestr(onset(1), 'HH:MM')));
if mod(duration, 1) == 0
    ACT.history = char(ACT.history, sprintf('duration = %i; %% daily event duration in hours', duration));
else
    ACT.history = char(ACT.history, sprintf('duration = %.4f; %% daily event duration in hours', duration));
end
ACT.history = char(ACT.history, sprintf('days = [%i, %i, %i, %i, %i, %i, %i]; %% boolean for each day of the week (Monday to Sunday)', days));
ACT.history = char(ACT.history, sprintf('ACT = cic_createDailyEvent(ACT, onset, duration, ''%s''); %% event label', label));

end % EOF