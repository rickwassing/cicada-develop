function [ACT, ids] = cic_actigraphySleepEvents(ACT, varargin)
% ---------------------------------------------------------
% Extract 'select' values, if the user specified them
% - varargin may either be
%   (1) a datenum numeric array of length 2 containing start and end dates
%   (2) a datestring cell array of length 2 formatted as dd/mm/yyyy HH:MM
if nargin == 1
    select = [ACT.xmin, ACT.xmax];
else
    select = varargin{:};
    if ~isnumeric(select)
        select = datenum(select, 'dd/mm/yyyy HH:MM');
    end
end
ids = [];
% ---------------------------------------------------------
% Start by removing any existing sleep periods and waso events
rm = selectEventsUsingTime(ACT.analysis.events, select(1), select(2), 'Label', 'sleepPeriod', 'Type', 'actigraphy');
if ~isempty(rm)
    [ACT, id] = cic_editEvents(ACT, 'delete', [], [], 'id', rm.id);
    ids = [ids; id];
end
rm = selectEventsUsingTime(ACT.analysis.events, select(1), select(2), 'Label', 'waso', 'Type', 'actigraphy');
if ~isempty(rm)
    [ACT, id] = cic_editEvents(ACT, 'delete', [], [], 'id', rm.id);
    ids = [ids; id];
end
% ---------------------------------------------------------
% Write history
ACT.history = char(ACT.history, '% -----');
ACT.history = char(ACT.history, '% Calculate sleep period and WASO events from sleep windows and annotation,');
ACT.history = char(ACT.history, '% Or delete any sleep periods and waso events if required.');
ACT.history = char(ACT.history, 'ACT = cic_actigraphySleepEvents(ACT);');
% ---------------------------------------------------------
% If there is no sleep window yet, return
if ~isfield(ACT.analysis.settings, 'sleepWindowType')
    return
end
% ---------------------------------------------------------
% If there is no annotation yet, return
if ~any(ACT.analysis.annotate.acceleration.Data ~= 0) && ~any(isnan(ACT.analysis.annotate.acceleration.Data))
    return
end
% ---------------------------------------------------------
% Select all sleep windows 
sleepWindow = selectEventsUsingTime(ACT.analysis.events, select(1), select(2), 'Label', 'sleepWindow', 'Type', ACT.analysis.settings.sleepWindowType);
% ---------------------------------------------------------
% If there are no sleep windows, return
if isempty(sleepWindow)
    return
end
% ---------------------------------------------------------
% Calculate sleep period based on actigraphy
sleepPeriod = struct();
waso = struct();
waso.onset = [];
waso.duration = [];
for si = 1:size(sleepWindow, 1)
    [annotate, time] = selectDataUsingTime(ACT.analysis.annotate.acceleration.Data, ACT.analysis.annotate.acceleration.Time, sleepWindow.onset(si), sleepWindow.onset(si) + sleepWindow.duration(si));
    sleepPeriod.onset(si, 1) = time(find(annotate == -1, 1, 'first'));
    sleepPeriod.duration(si, 1) = time(find(annotate == -1, 1, 'last')) - sleepPeriod.onset(si, 1);
    % Get all Awakenings
    [annotate, time] = selectDataUsingTime(ACT.analysis.annotate.acceleration.Data, ACT.analysis.annotate.acceleration.Time, sleepPeriod.onset(si), sleepPeriod.onset(si) + sleepPeriod.duration(si));
    [o, d] = getBouts(annotate > -1);
    waso.onset = [waso.onset; time(o)];
    waso.duration = [waso.duration; (d*ACT.epoch)/(24*60*60)];
end
% ---------------------------------------------------------
% Add the new sleepPeriod and WASO events
[ACT, id] = cic_editEvents(ACT, 'add', sleepPeriod.onset, sleepPeriod.duration, 'Label', 'sleepPeriod', 'Type', 'actigraphy');
ids = [ids; id];
[ACT, id] = cic_editEvents(ACT, 'add', waso.onset, waso.duration, 'Label', 'waso', 'Type', 'actigraphy');
ids = [ids; id];
% ---------------------------------------------------------
% Set saved to false
ACT.saved = false;
% ---------------------------------------------------------
% Update the pipeline
ACT = cic_updatePipe(ACT, 'analysis');

end % EOF
