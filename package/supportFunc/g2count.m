function ACT = g2count(ACT)

% Calculate Counts from accelerometer data
% filter z-accelerometer data
cutoffFreq = [3/(ACT.srate/2) 11/(ACT.srate/2)];
cutoffFreq(2) = min([0.99, 11/(ACT.srate/2)]);
[b, a] = butter(5, cutoffFreq, 'bandpass');
z_filt = filtfilt(b, a, ACT.data.acceleration.z.Data);

% convert data to 128 bins between 0 and 5
[~, binned] = histc(abs(z_filt), linspace(0, 5, 128+1));

% convert to counts/epoch
ACT.metric.acceleration.counts = max2epochs(binned, ACT.srate, 15);

% NOTE: Please be aware that the algorithm used here has only been
% validated for 15 s epochs and 50 Hz raw accelerometery palmar-dorsal
% z-axis data. The formula (1) used below is based on these settings.
% The longer the epoch, the higher the constant offset/residual noise
% will be (18 in this case). Sampling frequencies will probably affect
% the constant offset less. However, due to the band-pass of 3-11 Hz
% used above and human movement frequencies of up to 10 Hz, a sampling
% of less than 30 Hz is not reliable.

% subtract constant offset and multiply with factor for distal location
ACT.metric.acceleration.counts = (ACT.metric.acceleration.counts-18).*3.07; % ---> formula (1)

% set any negative values to 0
ACT.metric.acceleration.counts(ACT.metric.acceleration.counts < 0) = 0;

% create a new time series for the epoch data
step = 1/(24*60*60/15);
times = ACT.xmin+step/2:step:ACT.xmin+step/2+(length(ACT.metric.acceleration.counts)-1)*step;

% Save the metric
ACT.metric.acceleration.counts = timeseries(ACT.metric.acceleration.counts', times, 'Name', 'counts');
ACT.metric.acceleration.counts.DataInfo.Units = 'a.u.';
ACT.metric.acceleration.counts.TimeInfo.Units = 'days';
ACT.metric.acceleration.counts.TimeInfo.Format = 'dd-mmm-yyyy HH:MM:SS';
ACT.metric.acceleration.counts.TimeInfo.StartDate = '00-Jan-0000 00:00:00';

end
