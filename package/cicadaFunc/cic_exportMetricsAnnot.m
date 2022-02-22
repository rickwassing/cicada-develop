function ACT = cic_exportMetricsAnnot(ACT, fullpath)

% Initialize empty table
MET = table();

% Extract all the metric types, e.g. accelerometry, light, temperature etc.
fnames = fieldnames(ACT.metric);

% If there are no metrics, then throw and error
if isempty(fnames)
    error('Dataset does not contain any metrics')
end

% Check to see if there are any metrics in the default epoch length
hasData = false;

% For each metric type...
for i = 1:length(fnames)
    % ... extract the names of the metric
    metNames = fieldnames(ACT.metric.(fnames{i}));
    % For each metric name...
    for j = 1:length(metNames)
        % ... extract the timeseries (time and data)
        t = ACT.metric.(fnames{i}).(metNames{j}).Time;
        % Before extracting the data, first check sampling rate, should be equal to ACT.epoch
        thisEpoch = mean(diff(t))*24*60*60;
        if not(thisEpoch >= ACT.epoch - 10e-6 && thisEpoch <= ACT.epoch + 10e-6)
            % The metric is not epoched to the default epoch length
            continue
        end
        % Extract and store data in table
        d = ACT.metric.(fnames{i}).(metNames{j}).Data;
        MET.([fnames{i}, '_', metNames{j}]) = d;
        % We have data, so set boolean to true
        hasData = true;
    end
end

% If there are no metrics, then throw and error
if ~hasData
    error('Dataset does not contain any metrics with an epoch length of %i seconds', ACT.epoch)
end

% For each annotation
if isfield(ACT.analysis, 'annotate')
    fnames = fieldnames(ACT.analysis.annotate);
    for i = 1:length(fnames)
        t = ACT.analysis.annotate.(fnames{i}).Time;
        % Before extracting the data, first check sampling rate, should be equal to ACT.epoch
        thisEpoch = mean(diff(t))*24*60*60;
        if not(thisEpoch >= ACT.epoch - 10e-6 && thisEpoch <= ACT.epoch + 10e-6)
            % The metric is not epoched to the default epoch length
            continue
        end
        d = ACT.analysis.annotate.(fnames{i}).Data;
        MET.(['annot_', fnames{i}]) = d;
    end
end

% For each event
eventLabels = unique(ACT.analysis.events.label);
for i = 1:length(eventLabels)
    if strcmpi(eventLabels{i}, 'start')
        continue
    end
    idx = strcmpi(ACT.analysis.events.label, eventLabels{i});
    eventTypes = unique(ACT.analysis.events.type(idx));
    for j = 1:length(eventTypes)
        if length(eventTypes) == 1
            varName = eventLabels{i};
        else
            varName = [eventLabels{i}, '_', eventTypes{j}];
        end
        d = events2idx(ACT, t, 'Label', eventLabels{i}, 'Type', eventTypes{j});
        MET.(['event_', varName]) = d;
    end
end

% Set the date-time
MET.datetime = datestr(t, 'yyyy-mm-ddTHH:MM:SS');
MET.time = round((t-t(1))*24*60*60*1000)/1000; % Round to millisecond precision
% Reorder the variables, put the time up front
MET = movevars(MET, 'time', 'Before', MET.Properties.VariableNames{1});
MET = movevars(MET, 'datetime', 'Before', MET.Properties.VariableNames{1});

% Write table to CSV file
writetable(MET, [fullpath, '.csv']);

% ---------------------------------------------------------
% Write history 
ACT.history = char(ACT.history, '% ---------------------------------------------------------');
ACT.history = char(ACT.history, '% Export metrics to .CSV files');
ACT.history = char(ACT.history, sprintf('ACT = cic_exportMetrics(ACT, ''%s'');', fullpath));

end % EOF
