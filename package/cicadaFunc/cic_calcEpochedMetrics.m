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
times = ACT.xmin:step:ACT.xmax;

% -----
% Euclidean Norm Minus One
tmp = sqrt(ACT.data.acceleration.x.Data .^2 + ACT.data.acceleration.y.Data .^2 + ACT.data.acceleration.z.Data .^2) - 1;
tmp(tmp < 0) = 0;
ACT.metric.acceleration.euclNormMinOne = timeseries(averagePerWindow(...
    tmp, ...
    ACT.srate, ...
    ACT.epoch)', times, 'Name', 'euclNormMinOne');
ACT.metric.acceleration.euclNormMinOne.DataInfo.Units = 'g';
ACT.metric.acceleration.euclNormMinOne.TimeInfo.Units = 'days';
ACT.metric.acceleration.euclNormMinOne.TimeInfo.Format = 'dd-mmm-yyyy HH:MM:SS';
ACT.metric.acceleration.euclNormMinOne.TimeInfo.StartDate = '00-Jan-0000 00:00:00';
% -----
% Bandpass filtered Euclidean Norm @ 0.2 - 14.95 Hz
[b, a] = butter(4, [0.2/(ACT.srate/2) 14.95/(ACT.srate/2)], 'bandpass');
tmp_x = filtfilt(b, a, ACT.data.acceleration.x.Data);
tmp_y = filtfilt(b, a, ACT.data.acceleration.y.Data);
tmp_z = filtfilt(b, a, ACT.data.acceleration.z.Data);
ACT.metric.acceleration.bpFiltEuclNorm = timeseries(averagePerWindow(...
    sqrt(tmp_x.^2 + tmp_y.^2 + tmp_z.^2),...
    ACT.srate, ...
    ACT.epoch)', times, 'Name', 'bpFiltEuclNorm');
ACT.metric.acceleration.bpFiltEuclNorm.DataInfo.Units = 'g';
ACT.metric.acceleration.bpFiltEuclNorm.TimeInfo.Units = 'days';
ACT.metric.acceleration.bpFiltEuclNorm.TimeInfo.Format = 'dd-mmm-yyyy HH:MM:SS';
ACT.metric.acceleration.bpFiltEuclNorm.TimeInfo.StartDate = '00-Jan-0000 00:00:00';
% -----
% Calculate moving medians for angles
k = ACT.epoch*ACT.srate;
if mod(k,2) == 0; k = k+1; end % Force an odd-sized window
% -----
% Calculate moving medians
tmp_x = movmedian(ACT.data.acceleration.x.Data, k, 'EndPoints', 'fill');
tmp_y = movmedian(ACT.data.acceleration.y.Data, k, 'EndPoints', 'fill');
tmp_z = movmedian(ACT.data.acceleration.z.Data, k, 'EndPoints', 'fill');
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
ACT.metric.acceleration.angle_z.DataInfo.Units = '*';
ACT.metric.acceleration.angle_z.TimeInfo.Units = 'days';
ACT.metric.acceleration.angle_z.TimeInfo.Format = 'dd-mmm-yyyy HH:MM:SS';
ACT.metric.acceleration.angle_z.TimeInfo.StartDate = '00-Jan-0000 00:00:00';

% ---------------------------------------------------------
% Calculate epoched data, except for acceleration
dataTypes = fieldnames(ACT.data);
dataTypes(strcmpi(dataTypes, 'acceleration')) = [];
for di = 1:length(dataTypes)
    % Extract all the fieldnames of this data type
    fnames = fieldnames(ACT.data.(dataTypes{di}));
    for fi = 1:length(fnames)
        % Resample the timeseries
        srate = 1/(ACT.data.(dataTypes{di}).(fnames{fi}).TimeInfo.Increment*60*60*24);
        if srate > 1/ACT.epoch
            % Downsample the data
            tmp = retime(timetable(ACT.data.(dataTypes{di}).(fnames{fi}).Data, 'SampleRate', srate), ...
                'Regular', 'mean', ...
                'SampleRate', 1/ACT.epoch);
        elseif srate < 1/ACT.epoch
            % Upsample the data
            tmp = retime(timetable(ACT.data.(dataTypes{di}).(fnames{fi}).Data, 'SampleRate', srate), ...
                'Regular', 'linear', ...
                'SampleRate', 1/ACT.epoch);
        else
            % Do nothing
            tmp = timetable(ACT.data.(dataTypes{di}).(fnames{fi}).Data, 'SampleRate', srate);
        end
        % Convert timetable back to timeseries
        times = ACT.data.(dataTypes{di}).(fnames{fi}).Time(1) + seconds(tmp.Time) / (60*60*24);
        ACT.metric.(dataTypes{di}).(fnames{fi}) = timeseries(tmp{:, :}, times, 'Name', [dataTypes{di}, '-', fnames{fi}]);
        ACT.metric.(dataTypes{di}).(fnames{fi}).DataInfo.Units = ACT.data.(dataTypes{di}).(fnames{fi}).DataInfo.Units;
        ACT.metric.(dataTypes{di}).(fnames{fi}).TimeInfo.Units = 'days';
        ACT.metric.(dataTypes{di}).(fnames{fi}).TimeInfo.Format = 'dd-mmm-yyyy HH:MM:SS';
        ACT.metric.(dataTypes{di}).(fnames{fi}).TimeInfo.StartDate = '00-Jan-0000 00:00:00';
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
