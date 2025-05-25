function ACT = cic_importAxivityCwa(fullpath, varargin)

% ---------------------------------------------------------
% Get a brand new dataset
ACT = newDataset();
% ---------------------------------------------------------
% Read .bin file and convert to .mat variables
Info = importAxivityCwa(fullpath, 'info', 1, 'modality', [1 1 1], 'verbose', 0);
Data = importAxivityCwa(fullpath, ...
    'startTime', Info.start.mtime, ...
    'stopTime', Info.stop.mtime, ...
    'info', 0, ...
    'modality', [1 1 1], ...
    'verbose', 0);
% ---------------------------------------------------------
% Store the filename, but keep the path empty so Cicada will ask where to save the Mat file.
ACT.filepath = '';
[~, ACT.filename] = fileparts(fullpath);
% ---------------------------------------------------------
% Store the information variables
ACT.info.device = 'axivityax3';
% timezone is not save in the header file, so assume its
% the local timezon
tz = char(datetime('now', 'TimeZone', 'local', 'Format', 'XXX'));
if strcmpi(tz, 'Z')
    tz = '+00:00';
end
ACT.timezone = tz;
ACT.info.serial = Info.deviceId;
ACT.info.institute = '';
ACT.info.researcher = '';
ACT.info.subject = '';
ACT.info.dob = '01/01/2000';
ACT.info.sex = 'not specified';
ACT.info.height = zeros(0);
ACT.info.weight = zeros(0);
ACT.info.handedness = 'not specified';
ACT.info.deviceLoc = 'not specified';
ACT.etc.cal.x_gain = 1;
ACT.etc.cal.y_gain = 1;
ACT.etc.cal.z_gain = 1;
ACT.etc.cal.x_offset = 0;
ACT.etc.cal.y_offset = 0;
ACT.etc.cal.z_offset = 0;
ACT.etc.cal.volts = 1;
ACT.etc.cal.lux = 1;
% ---------------------------------------------------------
% Creat timeseries for raw data
ACT.times = Data.AXES(:, 1);
% Update the time variables
ACT.srate = round(1/(mean(diff(ACT.times))*60*60*24));
ACT.pnts = length(ACT.times);
ACT.xmin = ACT.times(1);
ACT.xmax = ACT.times(end);
% ---------------------------------------------------------
% Store the data
% -----
% x-axis
ACT.data.acceleration.x = timeseries(Data.AXES(:,2), ACT.times, 'Name', 'acceleration_x');
ACT.data.acceleration.x.DataInfo.Units = 'g';
ACT.data.acceleration.x.TimeInfo.Units = 'days';
ACT.data.acceleration.x.TimeInfo.Format = 'dd-mmm-yyyy HH:MM:SS';
ACT.data.acceleration.x.TimeInfo.StartDate = '00-Jan-0000 00:00:00';
% Force the timeseries to have uniform interval
ACT.data.acceleration.x = setuniformtime(ACT.data.acceleration.x, 'StartTime', ACT.xmin, 'Interval', 1/(ACT.srate*60*60*24));
% -----
% y-axis
ACT.data.acceleration.y = timeseries(Data.AXES(:,3), ACT.times, 'Name', 'acceleration_y');
ACT.data.acceleration.y.DataInfo.Units = 'g';
ACT.data.acceleration.y.TimeInfo.Units = 'days';
ACT.data.acceleration.y.TimeInfo.Format = 'dd-mmm-yyyy HH:MM:SS';
ACT.data.acceleration.y.TimeInfo.StartDate = '00-Jan-0000 00:00:00';
% Force the timeseries to have uniform interval
ACT.data.acceleration.y = setuniformtime(ACT.data.acceleration.y, 'StartTime', ACT.xmin, 'Interval', 1/(ACT.srate*60*60*24));
% -----
% x-axis
ACT.data.acceleration.z = timeseries(Data.AXES(:,4), ACT.times, 'Name', 'acceleration_z');
ACT.data.acceleration.z.DataInfo.Units = 'g';
ACT.data.acceleration.z.TimeInfo.Units = 'days';
ACT.data.acceleration.z.TimeInfo.Format = 'dd-mmm-yyyy HH:MM:SS';
ACT.data.acceleration.z.TimeInfo.StartDate = '00-Jan-0000 00:00:00';
% Force the timeseries to have uniform interval
ACT.data.acceleration.z = setuniformtime(ACT.data.acceleration.z, 'StartTime', ACT.xmin, 'Interval', 1/(ACT.srate*60*60*24));
% -----
% Light data
light = interp1(Data.LIGHT(:, 1), Data.LIGHT(:, 2), ACT.times, 'linear');
ACT.data.light.wideSpec = timeseries(light, ACT.times, 'Name', 'light_broadSpec');
ACT.data.light.wideSpec.DataInfo.Units = 'lux';
ACT.data.light.wideSpec.TimeInfo.Units = 'days';
ACT.data.light.wideSpec.TimeInfo.Format = 'dd-mmm-yyyy HH:MM:SS';
ACT.data.light.wideSpec.TimeInfo.StartDate = '00-Jan-0000 00:00:00';
% Force the timeseries to have uniform interval
ACT.data.light.wideSpec = setuniformtime(ACT.data.light.wideSpec, 'StartTime', ACT.xmin, 'Interval', 1/(ACT.srate*60*60*24));
% -----
% Temperature data
temp = interp1(Data.TEMP(:, 1), Data.TEMP(:, 2), ACT.times, 'linear');
ACT.data.temperature.wrist = timeseries(temp, ACT.times, 'Name', 'temperature_wrist');
ACT.data.temperature.wrist.DataInfo.Units = '*C';
ACT.data.temperature.wrist.TimeInfo.Units = 'days';
ACT.data.temperature.wrist.TimeInfo.Format = 'dd-mmm-yyyy HH:MM:SS';
ACT.data.temperature.wrist.TimeInfo.StartDate = '00-Jan-0000 00:00:00';
% Force the timeseries to have uniform interval
ACT.data.temperature.wrist = setuniformtime(ACT.data.temperature.wrist, 'StartTime', ACT.xmin, 'Interval', 1/(ACT.srate*60*60*24));
% ---------------------------------------------------------
% Store events
ACT.analysis.events = table();
ACT.analysis.events.id       = 1;
ACT.analysis.events.onset    = ACT.times(1);
ACT.analysis.events.duration = zeros(1,1);
ACT.analysis.events.label    = {'start'};
ACT.analysis.events.type     = {''};
% ---------------------------------------------------------
% Save the Dynamic Range of this device: required for clipping detection
ACT.etc.dynRange = 8;
% ---------------------------------------------------------
% Initialize saved as false
ACT.saved = false;
% ---------------------------------------------------------
% Update the pipeline
ACT = cic_updatePipe(ACT, 'load');
% ---------------------------------------------------------
% Write history
ACT.history = char(ACT.history, '% ---------------------------------------------------------');
ACT.history = char(ACT.history, '% Import Axivity AX3 data from .cwa file');
ACT.history = char(ACT.history, sprintf('ACT = cic_importAxivityCwa(''%s'');', fullpath));

end %EOF
