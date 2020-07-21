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
[~, ACT.times] = selectDataUsingTime(ACT.data.acceleration.x.Data, times, startDate, endDate);
datatypes = fieldnames(ACT.data);
for di = 1:length(datatypes)
    if isstruct(ACT.data.(datatypes{di}))
        fnames = fieldnames(ACT.data.(datatypes{di}));
        for fi = 1:length(fnames)
            ACT.data.(datatypes{di}).(fnames{fi}) = getsampleusingtime(ACT.data.(datatypes{di}).(fnames{fi}), startDate, endDate);
        end
    end
end
ACT.pnts = length(ACT.times);
ACT.xmin = ACT.times(1);
ACT.xmax = ACT.times(end);
% ---------------------------------------------------------
% Cut the annotation data
ACT.analysis.annotate.acceleration = getsampleusingtime(ACT.analysis.annotate.acceleration, startDate, endDate);
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
