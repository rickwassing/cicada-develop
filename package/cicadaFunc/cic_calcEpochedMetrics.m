function ACT = cic_calcEpochedMetrics(ACT, epoch)
% ---------------------------------------------------------
% Set epoch length
ACT.epoch = epoch;
% ---------------------------------------------------------
% OAKLEY & TE LINDERT
% Convert Accelerometer data to activity counts
ACT = g2count(ACT);
% ---------------------------------------------------------
% GGIR
% The following metrics are based on the functions in 'g.applymetrics.R'
% and 'g.metric.R' from the R package GGIR version 1.9-2
% -----
% First, create a new time series for the epoched data
step  = 1/(24*60*60/ACT.epoch);
nWins = floor(ACT.pnts/(ACT.srate*ACT.epoch));
times = ACT.xmin + step/2 : step : ACT.xmin + step/2 + (nWins-1) * step;
% -----
% Initialize an empty a timeseries object, which will be used by other
% preprocessing and analyses algorithms to indicate:
% -2  = sleep (inactive while in bed)
% -1  = inactive (inactive while out of bed)
% 0   = not scored
% 1   = light activity
% 2   = moderate activity
% 3   = vigorous activity
ACT.analysis.annotate = timeseries(zeros(nWins,1), times, 'Name', 'annotate');
ACT.analysis.annotate.TimeInfo.Units = 'days';
% -----
% Euclidean Norm Minus One
tmp = sqrt(ACT.data.acceleration.x .^2 + ACT.data.acceleration.y .^2 + ACT.data.acceleration.z .^2) - 1;
tmp(tmp < 0) = 0;
ACT.metric.acceleration.euclNormMinOne = timeseries(averagePerWindow(...
    tmp, ...
    ACT.srate, ...
    ACT.epoch)', times, 'Name', 'euclNormMinOne');
ACT.metric.acceleration.euclNormMinOne.TimeInfo.Units = 'days';
% -----
% Bandpass filtered Euclidean Norm @ 0.2 - 14.95 Hz
[b, a] = butter(4, [0.2/(ACT.srate/2) 14.95/(ACT.srate/2)], 'bandpass');
tmp_x = filtfilt(b, a, ACT.data.acceleration.x);
tmp_y = filtfilt(b, a, ACT.data.acceleration.y);
tmp_z = filtfilt(b, a, ACT.data.acceleration.z);
ACT.metric.acceleration.bpFiltEuclNorm = timeseries(averagePerWindow(...
    sqrt(tmp_x.^2 + tmp_y.^2 + tmp_z.^2),...
    ACT.srate, ...
    ACT.epoch)', times, 'Name', 'bpFiltEuclNorm');
ACT.metric.acceleration.bpFiltEuclNorm.TimeInfo.Units = 'days';
% -----
% Calculate moving medians for angles
k = ACT.epoch*ACT.srate;
if mod(k,2) == 0; k = k+1; end % Force an odd-sized window
% -----
% Calculate moving medians
tmp_x = movmedian(ACT.data.acceleration.x, k, 'EndPoints', 'fill');
tmp_y = movmedian(ACT.data.acceleration.y, k, 'EndPoints', 'fill');
tmp_z = movmedian(ACT.data.acceleration.z, k, 'EndPoints', 'fill');
% -----
% Replace any NaN's in the first 1000 samples with the first non-NaN value
if any(isnan(tmp_x(1:1000))) && any(~isnan(tmp_x(1:1000)))
    tmp_x(isnan(tmp_x(1:1000))) = tmp_x(find(~isnan(tmp_x(1:1000)), 1, 'first'));
elseif any(isnan(tmp_x(1:1000))) && ~any(~isnan(tmp_x(1:1000)))
    tmp_x(isnan(tmp_x(1:1000))) = nanmedian(tmp_x);
end
if any(isnan(tmp_y(1:1000))) && any(~isnan(tmp_y(1:1000)))
    tmp_y(isnan(tmp_y(1:1000))) = tmp_y(find(~isnan(tmp_y(1:1000)), 1, 'first'));
elseif any(isnan(tmp_y(1:1000))) && ~any(~isnan(tmp_y(1:1000)))
    tmp_x(isnan(tmp_y(1:1000))) = nanmedian(tmp_y);
end
if any(isnan(tmp_z(1:1000))) && any(~isnan(tmp_z(1:1000)))
    tmp_z(isnan(tmp_z(1:1000))) = tmp_z(find(~isnan(tmp_z(1:1000)), 1, 'first'));
elseif any(isnan(tmp_z(1:1000))) && ~any(~isnan(tmp_z(1:1000)))
    tmp_x(isnan(tmp_z(1:1000))) = nanmedian(tmp_z);
end
% -----
% Replace any remaining NaN's with the last non-NaN value
if any(isnan(tmp_x)); tmp_x(isnan(tmp_x)) = tmp_x(find(~isnan(tmp_x), 1, 'last')); end
if any(isnan(tmp_y)); tmp_y(isnan(tmp_y)) = tmp_y(find(~isnan(tmp_y), 1, 'last')); end
if any(isnan(tmp_z)); tmp_z(isnan(tmp_z)) = tmp_z(find(~isnan(tmp_z), 1, 'last')); end
% -----
% Z-axis angle
ACT.metric.acceleration.angle_z = timeseries(averagePerWindow(...
    atan(tmp_z ./ sqrt(tmp_x.^2 + tmp_y.^2)) ./ (pi/180), ...
    ACT.srate, ...
    ACT.epoch)', times, 'Name', 'angle_z');
ACT.metric.acceleration.angle_z.TimeInfo.Units = 'days';
% ---------------------------------------------------------
% Calculate epoched data
dataTypes = fieldnames(ACT.data);
dataTypes(strcmpi(dataTypes, 'acceleration')) = [];
for di = 1:length(dataTypes)
    fnames = fieldnames(ACT.data.(dataTypes{di}));
    for fi = 1:length(fnames)
        ACT.metric.(dataTypes{di}).(fnames{fi}) = timeseries(averagePerWindow(...
            ACT.data.(dataTypes{di}).(fnames{fi}), ...
            ACT.srate, ...
            ACT.epoch)', times, 'Name', fnames{fi});
        ACT.metric.(dataTypes{di}).(fnames{fi}).TimeInfo.Units = 'days';
    end
end
% ---------------------------------------------------------
% Set saved to false
ACT.saved = false;
% ---------------------------------------------------------
% Write history
ACT.history = char(ACT.history, '% -----');
ACT.history = char(ACT.history, '% Calculate epoched metrics');
ACT.history = char(ACT.history, sprintf('ACT = cic_calcEpochedMetrics(ACT, %i); %% epoch length in seconds', epoch));

end % EOF
