function [ACT, err] = cic_ggirDetectNonWear(ACT)
% ---------------------------------------------------------
% Reference:
% van Hees VT, Gorzelniak L, Dean Le�n EC, Eder M, Pias M, Taherian S, 
% Ekelund U, Renstr�m F, Franks PW, Horsch A, Brage S. 
%   Separating movement and gravity components in an acceleration signal 
%   and implications for the assessment of human daily physical activity. 
%   PLoS One. 2013 Apr 23;8(4):e61691. doi: 10.1371/journal.pone.0061691.
% ---------------------------------------------------------
% Initialize variables
ACT.thresholds.winShort = 15*60*ACT.srate; % 15 minutes
ACT.thresholds.winLong  = 60*60*ACT.srate; % 60 minutes
% Extract variable for shortness
winShort   = ACT.thresholds.winShort;
winLong    = ACT.thresholds.winLong;
maxWindows = floor(ACT.pnts/ACT.thresholds.winShort);
if maxWindows == 0
    err = sprintf('Did not perform non-wear detection, data is too short <%i samples>', ACT.pnts);
    fprintf('%s\n', err)
    return
else
    err = '';
end
% ---------------------------------------------------------
% Initialize nonwear as empty vector
nonWear = zeros(ACT.pnts,3);
% ---------------------------------------------------------
% Get thresholds
switch ACT.info.device
    case 'genea'
        ACT.thresholds.offWristStd = 0.003;
        ACT.thresholds.offWristRng = 0.05;
    case 'geneactive'
        ACT.thresholds.offWristStd = 0.013; % 0.0109 in rest test
        ACT.thresholds.offWristRng = 0.15;  % 0.1279 in rest test
    case 'actigraph'
        ACT.thresholds.offWristStd = 0.013; % Adjustment needed for 'actigraph'
        ACT.thresholds.offWristRng = 0.15;
    case 'axivity'
        ACT.thresholds.offWristStd = 0.013; % Adjustment needed for 'axivity'
        ACT.thresholds.offWristRng = 0.15;
    otherwise
        ACT.thresholds.offWristStd = 0.013;
        ACT.thresholds.offWristRng = 0.15;
end

for win = 1:maxWindows
    % ---------------------------------------------------------
    % Create a sliding window of length 'winLong' in steps of 'winShort'
    winEdges = [...
        ((win-1)*winShort + winShort*0.5) - winLong*0.5, ...
        ((win-1)*winShort + winShort*0.5) + winLong*0.5];
    if winEdges(1) < 1; winEdges(1) = 1; end
    if winEdges(end) > ACT.pnts; winEdges(2) = ACT.pnts; end
    % ---------------------------------------------------------
    % For each of the three accelerometer axes:
    for ax = 1:3
        if ax == 1; fname = 'x'; end
        if ax == 2; fname = 'y'; end
        if ax == 3; fname = 'z'; end
        % ---------------------------------------------------------
        % Calculate the standard deviation and range in the window
        stdwacc = nanstd(ACT.data.acceleration.(fname)(winEdges(1)+1:winEdges(2)));
        rngwacc = range(ACT.data.acceleration.(fname)(winEdges(1)+1:winEdges(2)));
        % ---------------------------------------------------------
        % If the standard deviation and range is below the threshold, then
        % this window can be scored as off-wrist.
        if stdwacc < ACT.thresholds.offWristStd && rngwacc < ACT.thresholds.offWristRng
            nonWear(winEdges(1)+1:winEdges(2),ax) = 1;
        end
    end
end
% ---------------------------------------------------------
% A block is classified as non-wear time 
% (1) if the standard deviation is less than the threshold for at least two out of the three axes
% AND 
% (2) if the value range is less than the threshold for at least two out of three axes 
nonWear = sum(nonWear,2) > 2;
% ---------------------------------------------------------
% For ease of further scruitiny, create a table with the onset and duration
% of wear and non-wear periods.
WT = table(); NWT = table();
[WT.onset, WT.duration] = getBouts(~nonWear);
[NWT.onset, NWT.duration] = getBouts(nonWear);
WT.type  = ones(size(WT.onset));
NWT.type = zeros(size(NWT.onset));
% ---------------------------------------------------------
% Concatenate the wear and non-wear events
wear = [WT;NWT];
% ---------------------------------------------------------
% Transform the onset in samples to datetime
wear.onset    = ACT.times(wear.onset)';
% Calculate the duration of each period in seconds
wear.duration = wear.duration ./ ACT.srate;
% Sort the table by the onset
[~,idx] = sort(wear.onset);
wear = wear(idx,:);

if size(wear,1) > 1
    % ---------------------------------------------------------
    % All detected wear-periods of less than six hours and less than 30% of the
    % combined duration of their bordering non-wear periods are classified as non-wear. 
    % Additionally, all wear-periods of less than three hours and which formed 
    % less than 80% of their bordering non-wear periods were classified as non-wear.
    % Applying this algorithm in three iterative stages improved classification 
    % of periods characterised by intermittent periods of non-wear and apparent wear.
    for perLength = 6:-3:3
        for iter = 1:5
            if perLength == 6; pctThres = 0.3; end
            if perLength == 3; pctThres = 0.8; end
            % So, find all wear-periods lasting less then 'perLength' hours
            idx = find(wear.type == 1 & wear.duration < perLength*60*60);
            if isempty(idx)
                continue
            end
            % Keep only the first index, deal with that one now, and then try
            % a new iteration
            idx = idx(1);
            % if this period is not the first or last one:
            if idx > 1 && idx < size(wear,1)
                % Check if the wear-duration is less than 30% of the duration of the
                % bordering non-wear periods.
                if wear.duration(idx) / (wear.duration(idx-1) + wear.duration(idx+1)) < pctThres
                    % If so, we can remove the wear and subsequent non-wear period,
                    % while adding their duration to the preceding non-wear period.
                    wear.duration(idx-1) = wear.duration(idx-1) + wear.duration(idx) + wear.duration(idx+1);
                    wear(idx+1,:) = [];
                    wear(idx,:)   = [];
                end
            end
        end
    end
    % ---------------------------------------------------------
    % An additional rule was introduced for the final 24 hours of each measurement.
    % All wear-periods in the final 24 hrs of each measurement shorter than three
    % hours and preceded by at least one hour of non-wear time were classified as non-wear.
    for iter = 1:5
        idx = find(wear.onset > ACT.xmax-1 & wear.type == 1 & wear.duration < 3*60*60);
        if ~isempty(idx)
            % Keep only the first index, deal with that one now, and then try
            % a new iteration
            idx = idx(1);
            if wear.type(idx-1) == 1 && wear.duration(idx-1) >= 1*60*60
                if idx == size(wear,1)
                    wear.duration(idx-1) = wear.duration(idx-1) + wear.duration(idx);
                    wear(idx,:) = [];
                else
                    wear.duration(idx-1) = wear.duration(idx-1) + wear.duration(idx) + wear.duration(idx+1);
                    wear(idx+1,:) = [];
                    wear(idx,:)   = [];
                end
            end
        end
    end
    % ---------------------------------------------------------
    % Finally, if the measurement starts or ends with a period of less than three 
    % hours of wear followed by non-wear of any length then this period of wear 
    % is classified as non-wear. 
    if wear.type(1) == 1 && wear.duration(1) < 3*60*60 && wear.type(2) == 0
        wear.duration(1) = wear.duration(1) + wear.duration(2);
        wear.type(1) = 0;
        wear(2,:) = [];
    end
end
% ---------------------------------------------------------
% Keep only the non-wear periods
wear = wear(wear.type == 0,:);
% Transform duration to days
wear.duration = wear.duration/(60*60*24);
% ---------------------------------------------------------
% Save the non-wear events to the events table
ACT = cic_editEvents(ACT, 'delete', [], [], 'Label', 'reject', 'Type', 'GGIR');
ACT = cic_editEvents(ACT, 'add', wear.onset, wear.duration, 'Label', 'reject', 'Type', 'GGIR');
% ---------------------------------------------------------
% Set saved to false
ACT.saved = false;
% ---------------------------------------------------------
% Update the pipeline
ACT = cic_updatePipe(ACT, 'preproc');
% ---------------------------------------------------------
% Write history
ACT.history = char(ACT.history, '% ---------------------------------------------------------');
ACT.history = char(ACT.history, '% GGIR''s Automatic non-wear detection algorithm (DOI: 10.1371/journal.pone.0061691)');
ACT.history = char(ACT.history, 'ACT = cic_ggirDetectNonWear(ACT);');

end % EOF

