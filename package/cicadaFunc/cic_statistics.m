function ACT = cic_statistics(ACT, varargin)

if nargin == 1 % if analysis type is not specified, do all
    do = {'daily', 'sleep', 'average'};
elseif ismember('average', varargin) % to calculate averages, we first need to calculate sleep and daily
    do = {'daily', 'sleep', 'average'};
else % otherwise do whatever the user specified
    do = varargin;
end

% ---------------------------------------------------------
% VARIABLES ABOUT EACH DAY
if ismember('daily', do)
    % Run stats
    ACT = cic_statisticsDaily(ACT);
end

% ---------------------------------------------------------
% VARIABLES ABOUT EACH SLEEP WINDOW
if ismember('sleep', do)
    if isfield(ACT.analysis.settings, 'sleepWindowType')
        % Run stats
        ACT = cic_statisticsSleep(ACT, 'actigraphy');
        ACT = cic_statisticsSleep(ACT, 'sleepDiary');
    end
end

% ---------------------------------------------------------
% AVERAGE VARIABLES
if ismember('average', do)
    % Run stats
    ACT = cic_statisticsAverage(ACT);
end


% ---------------------------------------------------------
% CUSTOM EVENT VARIABLES
if ismember('customEvent', do)
    % Run stats
    ACT = cic_statisticsCustom(ACT, varargin{2});
end

% ---------------------------------------------------------
% Set saved to false
ACT.saved = false;
% ---------------------------------------------------------
% Update the pipeline
ACT = cic_updatePipe(ACT, 'statistics');
% ---------------------------------------------------------
% Write history
if ismember('customEvent', do)
    ACT.history = char(ACT.history, '% -----');
    ACT.history = char(ACT.history, '% Generate statistics for custom events');
    ACT.history = char(ACT.history, sprintf('ACT = cic_statistics(ACT, ''customEvent'', ''%s'');', varargin{2}));
else
    ACT.history = char(ACT.history, '% ---------------------------------------------------------');
    ACT.history = char(ACT.history, '% Generate statistics');
    ACT.history = char(ACT.history, 'ACT = cic_statistics(ACT);');
end

end % EOF
