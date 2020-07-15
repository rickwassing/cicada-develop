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
times = ACT.times;
[~, ACT.times] = selectDataUsingTime(ACT.data.acceleration.x, times, startDate, endDate);
datatypes = fieldnames(ACT.data);
for d = 1:length(datatypes)
    if isstruct(ACT.data.(datatypes{d}))
        fnames = fieldnames(ACT.data.(datatypes{d}));
        for f = 1:length(fnames)
            ACT.data.(datatypes{d}).(fnames{f}) = selectDataUsingTime(ACT.data.(datatypes{d}).(fnames{f}), times, startDate, endDate);
        end
    end
end
ACT.pnts = length(ACT.times);
ACT.xmin = ACT.times(1);
ACT.xmax = ACT.times(end);
% ---------------------------------------------------------
% Cut the annotation data
[data, time] = selectDataUsingTime(ACT.analysis.annotate.Data, ACT.analysis.annotate.Time, startDate, endDate);
ACT.analysis.annotate = timeseries(data, time, 'Name', 'annotate');
ACT.analysis.annotate.TimeInfo.Units = 'days';
% ---------------------------------------------------------
% Cut the metrics
metrictypes = fieldnames(ACT.metric);
for m = 1:length(metrictypes)
    if isstruct(ACT.metric.(metrictypes{m}))
        fnames = fieldnames(ACT.metric.(metrictypes{m}));
        for f = 1:length(fnames)
            [data, time] = selectDataUsingTime(ACT.metric.(metrictypes{m}).(fnames{f}).Data, ACT.metric.(metrictypes{m}).(fnames{f}).Time, startDate, endDate);
            ACT.metric.(metrictypes{m}).(fnames{f}) = timeseries(data, time, 'Name', fnames{f});
            ACT.metric.(metrictypes{m}).(fnames{f}).TimeInfo.Units = 'days';
        end
    else
        [data, time] = selectDataUsingTime(ACT.metric.(metrictypes{m}).Data, ACT.metric.(metrictypes{m}).Time, startDate, endDate);
        ACT.metric.(metrictypes{m}) = timeseries(data, time, 'Name', metrictypes{m});
        ACT.metric.(metrictypes{m}).TimeInfo.Units = 'days';
    end
end
% ---------------------------------------------------------
% Cut the events
ACT.events = selectEventsUsingTime(ACT.events, startDate, endDate);
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
ACT.history = char(ACT.history, 'ACT = cic_selectDatasetUsingTime(ACT, startDate, endDate, ''dd/mm/yyyy HH:MM'');');

end % EOF
