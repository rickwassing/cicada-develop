function ACT = cic_annotateLight(ACT, params)
% ---------------------------------------------------------
% Initialize variables and save the thresholds to the stucture
ACT.analysis.settings.lightMetric = params.metric;       % string
ACT.analysis.settings.lightDim    = params.threshold(1); % lux
ACT.analysis.settings.lightBright = params.threshold(2); % lux
% ---------------------------------------------------------
% First, create a new time series for the epoched data
step  = 1/(24*60*60/ACT.epoch);
times = ACT.xmin:step:ACT.xmax;
% ---------------------------------------------------------
% Create a timeseries in 'ACT.analysis.annotate.light'
ACT.analysis.annotate.light = timeseries(zeros(length(times),1), times, 'Name', 'annotateLight');
ACT.analysis.annotate.light.DataInfo.Units = 'a.u.';
ACT.analysis.annotate.light.TimeInfo.Units = 'days';
ACT.analysis.annotate.light.TimeInfo.Format = 'dd-mmm-yyyy HH:MM:SS';
ACT.analysis.annotate.light.TimeInfo.StartDate = '00-Jan-0000 00:00:00';
% ---------------------------------------------------------
% Find the indices
idxMod = ...
    app.ACT.metric.light.(params.metric) >= params.threshold(1) && ...
    app.ACT.metric.light.(params.metric) < params.threshold(2);
idxBright = app.ACT.metric.light.(params.metric) >= params.threshold(2);
% ---------------------------------------------------------
% Set the annotation
ACT.analysis.annotate.light.Data(idxMod) = 1;
ACT.analysis.annotate.light.Data(idxBright) = 2;
% ---------------------------------------------------------
% Set saved to false
ACT.saved = false;
% ---------------------------------------------------------
% Update the pipeline
ACT = cic_updatePipe(ACT, 'analysis');
% ---------------------------------------------------------
% Write history
ACT.history = char(ACT.history, '% ---------------------------------------------------------');
ACT.history = char(ACT.history, '% Annotate the light data');
ACT.history = char(ACT.history, '% -----');
ACT.history = char(ACT.history, '% Define the parameters');
ACT.history = char(ACT.history, sprintf('params.metric = %s; %% name of the metric', params.metric));
ACT.history = char(ACT.history, sprintf('params.threshold = [%i, %i]; %% lux', params.threshold(1), params.threshold(2)));
ACT.history = char(ACT.history, '% -----');
ACT.history = char(ACT.history, '% Call the annotation function');
ACT.history = char(ACT.history, 'ACT = cic_annotateLight(ACT, params);');

end % EOF
