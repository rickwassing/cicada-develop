function ACT = cic_getDays(ACT, startClock, endClock)
% Defines the number of whole analysis periods
% The function 'cic_ggirSleepWindowDetection' depends on this value

% ---------------------------------------------------------
% Set the start and end clock in the display settings
ACT.display.actogramStartClock = startClock;
ACT.display.actogramEndClock = endClock;
% ---------------------------------------------------------
% Set start and enddate for the data analysis
n = ACT.xmax-ACT.xmin;
if mod(ACT.xmin, 1) < mod(datenum(startClock, 'HH:MM'), 1)
    n = n+1;
    ACT.startdate = datenum(...
        [datestr(ACT.xmin-1, 'yyyymmdd'), 'T', startClock],...
        'yyyymmddTHH:MM');
else
    ACT.startdate = datenum(...
        [datestr(ACT.xmin, 'yyyymmdd'), 'T', startClock],...
        'yyyymmddTHH:MM');
end
if mod(ACT.xmax, 1) > mod(datenum(endClock, 'HH:MM'), 1)
    n = n+1;
    ACT.enddate = datenum(...
        [datestr(ACT.xmax+1, 'yyyymmdd'), 'T', endClock],...
        'yyyymmddTHH:MM');
else
    ACT.enddate = datenum(...
        [datestr(ACT.xmax, 'yyyymmdd'), 'T', endClock],...
        'yyyymmddTHH:MM');
end
% ---------------------------------------------------------
% Calculate the number of days
ACT.ndays = ...
    datenum(datestr(ACT.enddate, 'dd/mm/yyyy'), 'dd/mm/yyyy') - ...
    datenum(datestr(ACT.startdate, 'dd/mm/yyyy'), 'dd/mm/yyyy');
% ---------------------------------------------------------
% Write history
ACT.history = char(ACT.history, '% -----');
ACT.history = char(ACT.history, '% Calculate how many analysis windows exist given its start and end clock');
ACT.history = char(ACT.history, sprintf('ACT = cic_getDays(ACT, ''%s'', ''%s''); %% start and end clock', startClock, endClock));

end % EOF
