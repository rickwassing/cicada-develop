function [header, time, xyz, light, button, prop_val] = importGeneActivBin(fname, varargin)
% BINREAD Reads GENEActive .bin files
%
% [hdr, time, xyz, light, but] = read(fname)
% [hdr, time, xyz, light, but, prop_val] = read(fname, 'key1', 'key2',...)
%
% Where
%
% FNAME is the file name
%
% HDR is a Mx1 cell array containing M header pages (each of them a struct)
%
% TIME is an Nx1 vector of measurement times. The times are expressed as
% serial date numbers (see help datenum)
%
% XYZ is a Nx3 matrix of calibrated accelerometer measurements. The columns
% correspond to the x, y and z axes
%
% LIGHT is a Nx1 vector of calibrated light measurements
%
% BUT is a Nx1 vector of button status values (1 on / 0 off)
%
% 'key1', 'key2' are names of page properties that should be extracted (and
% interpolated) from each data page. For instance
%
%
% (c) German Gomez-Herrero
% german.gomezherrero@ieee.org


% Some constants
DATA_PAGE_NAME = 'Recorded Data';
NB_HEADER_PAGES = 7;
NB_DATA_PAGES = 100;
CALIBRATION_PAGE_NAME = 'Calibration Data';
TIME_NAME = 'Page Time';
TIME_FORMAT = 'yyyy-mm-dd HH:MM:SS:FFF';
DATA_PROPS = {'Battery voltage', 'Temperature'};
INTERPOLATE_PROPS = true;
MEASUREMENT_FREQ_NAME = 'Measurement Frequency';

if nargin < 2
    data_props = DATA_PROPS;
else
    data_props = varargin;
end

% display wait message
fprintf('Reading bin file: %s\n', fname);
showWaitbar('Reading bin file', -1, 'off');

% Open the file
fid = fopen(fname, 'r');

% Skip any blank line at the beginning of file
C = textscan(fid, '%[^\n]',1);
while isempty(C{1})
    C = textscan(fid, '%[^\n]', 1);
end

% Read header pages
header = cell(NB_HEADER_PAGES, 1);
header_page_count = 1;
page_name = C{1}{1};
while ~strcmpi(page_name, DATA_PAGE_NAME)
    C = textscan(fid, '%[^\r\n:*]: %[^\r\n]');
    header{header_page_count} = cell2struct(C{2}, ...
        matlab.lang.makeValidName(C{1}(1:numel(C{2}))), 1);
    header{header_page_count}.Page_Name = page_name;
    if strcmpi(page_name, CALIBRATION_PAGE_NAME)
        x_gain = str2double(header{header_page_count}.xGain);
        y_gain = str2double(header{header_page_count}.yGain);
        z_gain = str2double(header{header_page_count}.zGain);
        x_offset = str2double(header{header_page_count}.xOffset);
        y_offset = str2double(header{header_page_count}.yOffset);
        z_offset = str2double(header{header_page_count}.zOffset);
        volts = str2double(header{header_page_count}.Volts);
        lux =  str2double(header{header_page_count}.Lux);
    end
    if numel(C{2})<numel(C{1})
        page_name = C{1}{end};
        header_page_count = header_page_count + 1;
    else
        keyboard
        % We have reached the end of the file
        xyz = [];
        light = [];
        button = [];
        prop_val = [];
        time = [];
        fclose(fid);
        return;
    end
end
header(header_page_count+1:end) = [];

if isfield(header{end},'NumberOfPages')
    nb_pages_in_header = true;
    nb_pages = str2double(header{end}.NumberOfPages);
else
    nb_pages_in_header = false;
    nb_pages = NB_DATA_PAGES;
end

% Read the data pages
data_page_count = 1;
page_name = DATA_PAGE_NAME;
xyz = nan(300*nb_pages, 3);
light = nan(300*nb_pages, 1);
button = nan(300*nb_pages, 1);
prop_val = nan(nb_pages, length(data_props));
time = nan(nb_pages, 1);
freq = nan(nb_pages, 1);
pct = 0;

error_occurred = false;
while strcmpi(page_name, DATA_PAGE_NAME)
    if nb_pages_in_header
        if ((data_page_count/nb_pages)-pct) > 0.01
            pct = (data_page_count/nb_pages);
            cancel = showWaitbar(sprintf('Reading .bin file (%.0f%%)', pct*100), pct, 'on');
            if cancel
                header = 'cancel';
                return
            end
        end
    end
    C = textscan(fid, '%[^\r\n:*]: %[^\r\n]');
    if numel(C{1}) ~= numel(C{2})+1
        error('Invalid format in %dth data page', data_page_count);
    end
    % Get the numeric properties of that the user wants to get
    [prop_idx, prop_loc] = ismember(C{1}(1:end-1), data_props);
    [prop_loc, idx] = sort(prop_loc(prop_idx));
    prop_idx = find(prop_idx);
    prop_idx = prop_idx(idx);
    prop_val(data_page_count, prop_loc) = str2double(C{2}(prop_idx));
    
    % Get the measurement time
    prop_idx = ismember(C{1}(1:end-1), TIME_NAME);
    if any(prop_idx)
        try
        time(data_page_count) = datenum(C{2}(prop_idx), ...
            TIME_FORMAT);
        catch ME
            error_occurred = true;
        end
    end
    
    % Get the measurement frequency
    prop_idx = ismember(C{1}(1:end-1), MEASUREMENT_FREQ_NAME);
    if any(prop_idx)
        freq(data_page_count) = str2double(C{2}(prop_idx));
    end
    
    % Get the measurements
    meas_idx = (data_page_count-1)*300+1:(data_page_count*300);
    try
        [xyz(meas_idx,:), light(meas_idx), button(meas_idx)] = hex2xyz(C{1}{end});
    catch ME
        error_occurred = true;
    end
    % Check the page name
    page_name = textscan(fid, '%[^\r\n]',1);
    if ~isempty(page_name{1}) && ~error_occurred
        page_name = page_name{1};
        data_page_count = data_page_count + 1;
    elseif ~error_occurred
        page_name = '';
    else
        page_name = '';
        data_page_count = data_page_count - 1;
    end
end
if ~isempty(page_name)
    warning('Unknown page name %s', page_name);
end
if nb_pages_in_header && data_page_count ~= nb_pages
    warning('Only %d data pages were found although %d pages are annotated in the header', ...
        data_page_count, nb_pages);
    xyz      = xyz(1:300*data_page_count, :);
    light    = light(1:300*data_page_count, :);
    button   = button(1:300*data_page_count, :);
    prop_val = prop_val(1:data_page_count, :);
    time     = time(1:data_page_count, 1);
    freq     = freq(1:data_page_count, 1);
end
showWaitbar('Calibrating data', -1, 'off');

% Interpolate the time
if any(diff(freq))
    error('Not implemented yet');
else
    % The data has been read in segments of 300 samples: how much time in
    % each segment?
    diffTime       = 300/round(nanmean(freq))/60/60/24;
    diffTimeMinOne = diffTime - 1/24/60/60/round(nanmean(freq));
    % Redefine time-segment vector starting from a whole rounded second.
    startTime = datenum(datestr(time(1),'yyyy-mm-dd HH:MM:SS'));
    time_interp = (startTime:diffTime:startTime+diffTime*(length(time)-1))';
    % Create an offset vector to add to each segment
    offset = linspace(0, diffTimeMinOne, 300);
    % Repeat the time vector 300 columns, and add the offset to each column
    time_interp = repmat(time_interp(:), 1, 300) + repmat(offset, numel(time_interp), 1);
    % Reshape the timevector
    time_interp = time_interp';
    time_interp = time_interp(:)';
    % Round the time to the nearest whole millisecond
    time_interp = round(time_interp*24*60*60*1000)/1000/60/60/24;
end

% Intepolate the selected page properties
if INTERPOLATE_PROPS
    prop_val_interp = nan(numel(time_interp), size(prop_val, 2));
    for i = 1:size(prop_val, 2)
        prop_val_interp(:, i) = interp1(time, prop_val(:,i), time_interp, 'spline');
    end
    prop_val = prop_val_interp;
end
time = time_interp;

% Calibrate the data
xyz = (xyz*100 - repmat([x_offset, y_offset, z_offset], ...
    data_page_count*300, 1))./repmat([x_gain, y_gain, z_gain], ...
    data_page_count*300, 1);
light = floor(light*lux/volts);

end


function [xyz, light, button] = hex2xyz(hstr)
% Hexadecimal to decimal conversion of data values
n_bytes = floor(numel(hstr)/2);
n_meas = floor(n_bytes/6);
hstr = reshape(hstr(1:n_bytes*2), 2, n_bytes)';
bin_values = dec2bin(hex2dec(hstr))';
bin_values = reshape(bin_values, 1, n_bytes*8);
idx = repmat((1:48:48*n_meas)', 1, 12) + repmat(0:11, n_meas, 1);
x = tc2dec(bin_values(idx),12);
y = tc2dec(bin_values(idx+12),12);
z = tc2dec(bin_values(idx+24),12);
idx = repmat((37:48:48*n_meas)', 1, 10) + repmat(0:9, n_meas, 1);
light = bin2dec(bin_values(idx));
button = bin_values((47:48:48*n_meas)')=='1';
f = bin_values((48:48:48*n_meas)')=='1';
if any(f)
    error('The (f) field is not zero!');
end

xyz = [x(:),y(:),z(:)];
button = button(:);
light = light(:);

end


function value = tc2dec(bin,N)
% Two-complement to decimal conversion

val = bin2dec(bin);
y = sign(2^(N-1)-val).*(2^(N-1)-abs(2^(N-1)-val));

value = y;
condition = (y==0 & val~=0);
value(condition) = -val(condition);

end

