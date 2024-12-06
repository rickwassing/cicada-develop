function ACT = cic_selectDatasetUsingTime(ACT, startDate, endDate, varargin)
% ---------------------------------------------------------
% Initialize the varargin parser
p = inputParser;
addParameter(p, 'format', 'dd/mmm/yyyy HH:MM', ...
    @(x) validateattributes(x, {'char'}, {'nonempty'}) ...
    );
% Parse the variable arguments
parse(p,varargin{:});
if ~isnumeric(startDate) && ~isnumeric(endDate)
    startDate = datenum(startDate, p.Results.format);
    endDate   = datenum(endDate, p.Results.format);
end
% ---------------------------------------------------------
% Cut the raw data
datatypes = fieldnames(ACT.data);
hasAnyData = false;
for di = 1:length(datatypes)
    if isstruct(ACT.data.(datatypes{di}))
        fnames = fieldnames(ACT.data.(datatypes{di}));
        for fi = 1:length(fnames)
            hasAnyData = true;
            % Crop the timeseries
            ACT.data.(datatypes{di}).(fnames{fi}) = getsampleusingtime(ACT.data.(datatypes{di}).(fnames{fi}), startDate, endDate);
            % For some reason, the Interval is lost after cropping the timeseries
            times = ACT.data.(datatypes{di}).(fnames{fi}).TimeInfo.Time;
            % Force the timeseries to have uniform interval
            ACT.data.(datatypes{di}).(fnames{fi}) = setuniformtime(ACT.data.(datatypes{di}).(fnames{fi}), 'StartTime', times(1), 'Interval', mean(diff(times)));
        end
    end
end
if ~hasAnyData
    return
end
ACT.times = ACT.data.(datatypes{di}).(fnames{fi}).Time;
ACT.pnts  = length(ACT.times);
ACT.xmin  = ACT.times(1);
ACT.xmax  = ACT.times(end);
% ---------------------------------------------------------
% Cut the metrics
metrictypes = fieldnames(ACT.metric);
for mi = 1:length(metrictypes)
    if isstruct(ACT.metric.(metrictypes{mi}))
        fnames = fieldnames(ACT.metric.(metrictypes{mi}));
        for fi = 1:length(fnames)
            ACT.metric.(metrictypes{mi}).(fnames{fi}) = getsampleusingtime( ...
                ACT.metric.(metrictypes{mi}).(fnames{fi}), ...
                startDate, endDate);
        end
    else
        ACT.metric.(metrictypes{mi}) = getsampleusingtime(...
            ACT.metric.(metrictypes{mi}), ...
            startDate, endDate);
    end
end
% ---------------------------------------------------------
% Cut the annotation data
anottypes = fieldnames(ACT.analysis.annotate);
for ai = 1:length(anottypes)
    ACT.analysis.annotate.(anottypes{ai}) = getsampleusingtime(ACT.analysis.annotate.(anottypes{ai}), startDate, endDate);
end
% ---------------------------------------------------------
% Cut the events
ACT.analysis.events = selectEventsUsingTime(ACT.analysis.events, startDate, endDate);
% ---------------------------------------------------------
% Set saved to false
ACT.saved = false;
% ---------------------------------------------------------
% Update the pipeline
ACT = cic_updatePipe(ACT, 'preproc');
% ---------------------------------------------------------
% Write history
ACT.history = char(ACT.history, '% ---------------------------------------------------------');
ACT.history = char(ACT.history, '% Select a subset of the dataset between two timepoints');
ACT.history = char(ACT.history, sprintf('startDate = ''%s'';', datestr(startDate, 'dd/mm/yyyy HH:MM')));
ACT.history = char(ACT.history, sprintf('endDate = ''%s'';', datestr(endDate, 'dd/mm/yyyy HH:MM')));
ACT.history = char(ACT.history, 'ACT = cic_selectDatasetUsingTime(ACT, startDate, endDate, ''format'', ''dd/mm/yyyy HH:MM'');');

end % EOF
