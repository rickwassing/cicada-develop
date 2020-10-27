function ACT = cic_importGeneActivBin(fullpath, varargin)

% EDIT 27 OCT 2020 by Rick Wassing, line 116

% ---------------------------------------------------------
% Get a brand new dataset
ACT = newDataset();
% ---------------------------------------------------------
% Read .bin file and convert to .mat variables
[header, times, xyz, light, button, prop_val] = importGeneActivBin(fullpath);
if strcmpi(header, 'cancel')
    return
end
button = diff([0; button > 0.5]) == 1;
% ---------------------------------------------------------
% Store the filename, but keep the path empty so Cicada will ask where to save the Mat file.
ACT.filepath = '';
[~, ACT.filename] = fileparts(fullpath);
% ---------------------------------------------------------
% Store the information variables
ACT.info.device = 'geneactiv';
for h = 1:length(header)
    fnames = fieldnames(header{h});
    for f = 1:length(fnames)
        switch fnames{f}
            case 'Time_Zone'
                ACT.timezone = strsplit(header{3}.Time_Zone, 'GMT ');
                ACT.timezone = ACT.timezone{2};
            case 'Device_Unique_Serial_Code'
                ACT.info.serial = strtrim(header{h,1}.Device_Unique_Serial_Code);
            case 'Study_Centre'
                ACT.info.institute = strtrim(header{h,1}.Study_Centre);
            case 'Investigator_ID'
                ACT.info.researcher = strtrim(header{h,1}.Investigator_ID);
            case 'Subject_Code'
                ACT.info.subject = strtrim(header{h,1}.Subject_Code);
            case 'Date_of_Birth'
                ACT.info.dob = strtrim(header{h,1}.Date_of_Birth);
                % Must convert Date of Birth to a date object
                try
                    ACT.info.dob = datestr(datenum(ACT.info.dob), 'dd/mm/yyyy');
                catch
                    ACT.info.dob = '01/01/2000';
                end
            case 'Sex'
                switch strtrim(header{h,1}.Sex)
                    case {'Male', 'male', 'M', 'm'}
                        ACT.info.sex = 'male';
                    case {'Female', 'female', 'F', 'f'}
                        ACT.info.sex = 'female';
                    otherwise
                        ACT.info.sex = 'not specified';
                end
            case 'Height'
                ACT.info.height = str2double(header{h,1}.Height);
            case 'Weight'
                ACT.info.weight = str2double(header{h,1}.Weight);
            case 'Handedness_Code'
                switch strtrim(header{h,1}.Handedness_Code)
                    case {'Right', 'right', 'R', 'r'}
                        ACT.info.handedness = 'right';
                    case {'Left', 'left', 'L', 'l'}
                        ACT.info.handedness = 'left';
                    otherwise
                        ACT.info.handedness = 'not specified';
                end
            case 'Device_Location_Code'
                switch lower(strtrim(header{h,1}.Device_Location_Code))
                    case 'right wrist'
                        ACT.info.deviceLoc = 'right wrist';
                    case 'left wrist'
                        ACT.info.deviceLoc = 'left wrist';
                    case 'right ankle'
                        ACT.info.deviceLoc = 'right ankle';
                    case 'left ankle'
                        ACT.info.deviceLoc = 'left ankle';
                    case 'right upper arm'
                        ACT.info.deviceLoc = 'right upper arm';
                    case 'left upper arm'
                        ACT.info.deviceLoc = 'left upper arm';
                    case 'right upper leg'
                        ACT.info.deviceLoc = 'right upper leg';
                    case 'left upper leg'
                        ACT.info.deviceLoc = 'left upper leg';
                    case 'right hip'
                        ACT.info.deviceLoc = 'right hip';
                    case 'left hip'
                        ACT.info.deviceLoc = 'left hip';
                    case 'chest'
                        ACT.info.deviceLoc = 'chest';
                    otherwise
                        ACT.info.deviceLoc = 'not specified';
                end
            case 'x_gain'
                ACT.etc.cal.x_gain = str2double(header{h,1}.x_gain);
            case 'y_gain'
                ACT.etc.cal.y_gain = str2double(header{h,1}.y_gain);
            case 'z_gain'
                ACT.etc.cal.z_gain = str2double(header{h,1}.z_gain);
            case 'x_offset'
                ACT.etc.cal.x_offset = str2double(header{h,1}.x_offset);
            case 'y_offset'
                ACT.etc.cal.y_offset = str2double(header{h,1}.y_offset);
            case 'z_offset'
                ACT.etc.cal.z_offset = str2double(header{h,1}.z_offset);
            case 'Volts'
                ACT.etc.cal.volts = str2double(header{h,1}.Volts);
            case 'Lux'
                ACT.etc.cal.lux = str2double(header{h,1}.Lux);
        end
    end
end
% ---------------------------------------------------------
% Store the time variables
ACT.pnts  = length(times);
% EDIT 27 OCT 2020 by Rick Wassing
% The header information is not always accurate, so rather calculate
% sampling rate from the timeseries vector to be sure
% ACT.srate = str2double(header{3,1}.Measurement_Frequency(1:end-2));
ACT.srate = round(1/(mean(diff(times))*60*60*24));
ACT.xmin  = times(1);
ACT.xmax  = times(end);
% ---------------------------------------------------------
% Store the data, note that GeneActiv does not measure heart-rate
% -----
% x-axis
ACT.data.acceleration.x = timeseries(xyz(:,1), times, 'Name', 'acceleration_x');
ACT.data.acceleration.x.DataInfo.Units = 'g';
ACT.data.acceleration.x.TimeInfo.Units = 'days';
ACT.data.acceleration.x.TimeInfo.Format = 'dd-mmm-yyyy HH:MM:SS';
ACT.data.acceleration.x.TimeInfo.StartDate = '00-Jan-0000 00:00:00';
% Force the timeseries to have uniform interval
ACT.data.acceleration.x = setuniformtime(ACT.data.acceleration.x, 'StartTime', ACT.xmin, 'Interval', 1/(ACT.srate*60*60*24));
% -----
% y-axis
ACT.data.acceleration.y = timeseries(xyz(:,2), times, 'Name', 'acceleration_y');
ACT.data.acceleration.y.DataInfo.Units = 'g';
ACT.data.acceleration.y.TimeInfo.Units = 'days';
ACT.data.acceleration.y.TimeInfo.Format = 'dd-mmm-yyyy HH:MM:SS';
ACT.data.acceleration.y.TimeInfo.StartDate = '00-Jan-0000 00:00:00';
% Force the timeseries to have uniform interval
ACT.data.acceleration.y = setuniformtime(ACT.data.acceleration.y, 'StartTime', ACT.xmin, 'Interval', 1/(ACT.srate*60*60*24));
% -----
% x-axis
ACT.data.acceleration.z = timeseries(xyz(:,3), times, 'Name', 'acceleration_z');
ACT.data.acceleration.z.DataInfo.Units = 'g';
ACT.data.acceleration.z.TimeInfo.Units = 'days';
ACT.data.acceleration.z.TimeInfo.Format = 'dd-mmm-yyyy HH:MM:SS';
ACT.data.acceleration.z.TimeInfo.StartDate = '00-Jan-0000 00:00:00';
% Force the timeseries to have uniform interval
ACT.data.acceleration.z = setuniformtime(ACT.data.acceleration.z, 'StartTime', ACT.xmin, 'Interval', 1/(ACT.srate*60*60*24));
% -----
% Light data
ACT.data.light.wideSpec = timeseries(light, times, 'Name', 'light_broadSpec');
ACT.data.light.wideSpec.DataInfo.Units = 'lux';
ACT.data.light.wideSpec.TimeInfo.Units = 'days';
ACT.data.light.wideSpec.TimeInfo.Format = 'dd-mmm-yyyy HH:MM:SS';
ACT.data.light.wideSpec.TimeInfo.StartDate = '00-Jan-0000 00:00:00';
% Force the timeseries to have uniform interval
ACT.data.light.wideSpec = setuniformtime(ACT.data.light.wideSpec, 'StartTime', ACT.xmin, 'Interval', 1/(ACT.srate*60*60*24));
% -----
% Temperature data
ACT.data.temperature.wrist = timeseries(prop_val(:,2), times, 'Name', 'temperature_wrist');
ACT.data.temperature.wrist.DataInfo.Units = '*C';
ACT.data.temperature.wrist.TimeInfo.Units = 'days';
ACT.data.temperature.wrist.TimeInfo.Format = 'dd-mmm-yyyy HH:MM:SS';
ACT.data.temperature.wrist.TimeInfo.StartDate = '00-Jan-0000 00:00:00';
% Force the timeseries to have uniform interval
ACT.data.temperature.wrist = setuniformtime(ACT.data.temperature.wrist, 'StartTime', ACT.xmin, 'Interval', 1/(ACT.srate*60*60*24));
% ---------------------------------------------------------
% Creat timeseries for raw data
ACT.times = ACT.data.acceleration.x.Time;
% Update the time variables
ACT.pnts = length(ACT.times);
ACT.xmin = times(1);
ACT.xmax = times(end);
% ---------------------------------------------------------
% Store events
ACT.analysis.events = table();
if any(button)
    ACT.analysis.events.id       = [1;(2:length(find(button))+1)'];
    ACT.analysis.events.onset    = [times(1);round2minute(times(button))];
    ACT.analysis.events.duration = zeros(sum(button)+1,1);
    ACT.analysis.events.label    = [{'start'};repmat({'button'},length(find(button)),1)];
    ACT.analysis.events.type     = [{''};repmat({'button'},length(find(button)),1)];
else
    ACT.analysis.events.id       = 1;
    ACT.analysis.events.onset    = times(1);
    ACT.analysis.events.duration = zeros(1,1);
    ACT.analysis.events.label    = {'start'};
    ACT.analysis.events.type     = {''};
end
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
ACT.history = char(ACT.history, '% Import GeneActiv data from .bin file');
ACT.history = char(ACT.history, sprintf('ACT = cic_importGeneActivBin(''%s'');', fullpath));

end %EOF
