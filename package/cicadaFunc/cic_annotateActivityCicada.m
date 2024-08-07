function ACT = cic_annotateActivityCicada(ACT, params)
% ---------------------------------------------------------
% Initialize variables and save the thresholds to the stucture
ACT.analysis.settings.inactTime   = params.thrInact_time; % minutes
ACT.analysis.settings.inactAngle  = params.thrInact_angle; % degrees
ACT.analysis.settings.actTime     = params.thrAct_time; % minutes
ACT.analysis.settings.actLight    = params.thrAct_lig; % g
ACT.analysis.settings.actModerate = params.thrAct_mod; % g
ACT.analysis.settings.actVigorous = params.thrAct_vig; % g
ACT.analysis.settings.boutCrit    = params.boutCrit; % percentage
ACT.analysis.settings.boutClosed  = params.boutClosed; % logical
ACT.analysis.settings.boutMetric  = params.boutMetric; % integer
% ---------------------------------------------------------
% Extract angle in z-axis and initialize sleep vector (sustainedInactive)
ang = ACT.metric.acceleration.angle_z.Data;
times = ACT.metric.acceleration.angle_z.Time;
% insert NaNs for rejected data
ang(events2idx(ACT, ACT.metric.acceleration.angle_z.Time, 'Label', 'reject')) = nan;
% Initialize 'sustainedInactive vector'
sustainedInactive = zeros(length(ACT.metric.acceleration.angle_z.Time),1);

% --------------------------------------------------------------------
% PART 1 - ANNOTATE SUSTAINED INACTIVITY EPOCHS
% --------------------------------------------------------------------
% Find posture changes of at least 5 degrees
postureChanges = find(abs(diff(ang)) > params.thrInact_angle);
% ---------------------------------------------------------
% Only keep the posture changes with intervals of more than 5 minutes
if length(postureChanges) > 1
    thresPostureChanges = find(diff(postureChanges) > (params.thrInact_time*(60/ACT.epoch)));
end
if ~isempty(thresPostureChanges)
    for p = 1:length(thresPostureChanges)
        % Periods with no posture change indicate sleep
        sustainedInactive(postureChanges(thresPostureChanges(p)):postureChanges(thresPostureChanges(p)+1)) = 1;
    end
else % no posture change with intervals of 5 minutes found
    if length(postureChanges) < 10
        sustainedInactive(1:end) = 1; % no posture change the entire time
    else
        sustainedInactive(1:end) = 0; % constant posture changes the entire time
    end
end
% -----
% Initialize an empty a timeseries object
ACT.analysis.annotate.acceleration = timeseries(ones(length(times), 1), times, 'Name', 'annotateAcceleration');
ACT.analysis.annotate.acceleration.DataInfo.Units = 'a.u.';
ACT.analysis.annotate.acceleration.TimeInfo.Units = 'days';
ACT.analysis.annotate.acceleration.TimeInfo.Format = 'dd-mmm-yyyy HH:MM:SS';
ACT.analysis.annotate.acceleration.TimeInfo.StartDate = '00-Jan-0000 00:00:00';

% ---------------------------------------------------------
% Save 'sustainedInactivity' as a timeseries in 'ACT.analysis.annotate'
ACT.analysis.annotate.acceleration.Data(sustainedInactive == 1) = 0;

% ---------------------------------------------------------
% PART 2 - FIND EPOCHS OF LIGHT, MODERATE AND VIGOROUS ACTIVITY
% ---------------------------------------------------------
% Get the bouts of moderate to vigorous activity
idxMVPA = ...
    ACT.metric.acceleration.euclNormMinOne.Data >= params.thrAct_mod & ...
    sustainedInactive ~= 1;
idxMVPA = ggirGetBout(idxMVPA, params.thrAct_time*(60/ACT.epoch), ...
    'boutcriter', params.boutCrit/100, ...
    'boutClosed', params.boutClosed == 1, ...
    'boutMetric', params.boutMetric, ...
    'ws3', ACT.epoch) == 1;
% ---------------------------------------------------------
% Get the bouts of inactivity
% ##################################################
% EDIT
% By: Rick Wassing
% Date: Aug 2022
% Reason: 'sustainedInactive ~= 1' was not part of the logical statement,
% so I added it.
idxLowActivity = ...
    ACT.metric.acceleration.euclNormMinOne.Data < params.thrAct_lig & ...
    sustainedInactive ~= 1;
idxLowActivity = ggirGetBout(idxLowActivity, params.thrInact_time*(60/ACT.epoch), ...
    'boutcriter', params.boutCrit/100, ...
    'boutClosed', params.boutClosed == 1, ...
    'boutMetric', params.boutMetric, ...
    'ws3', ACT.epoch) == 1;
% ---------------------------------------------------------
% Get the bouts of light activity
% ##################################################
% EDIT
% By: Rick Wassing
% Date: Aug 2022
% Reason: '~idxMVPA' was not part of the logical statement,
% so I added it.
idxLightActivity = ...
    ACT.metric.acceleration.euclNormMinOne.Data >= params.thrAct_lig & ...
    sustainedInactive ~= 1;
idxLightActivity = ggirGetBout(idxLightActivity, params.thrAct_time*(60/ACT.epoch), ...
    'boutcriter', params.boutCrit/100, ...
    'boutClosed', params.boutClosed == 1, ...
    'boutMetric', params.boutMetric, ...
    'ws3', ACT.epoch) == 1;
% ---------------------------------------------------------
% Indices of vigorous activity
idxVigorousActivity = sustainedInactive ~= 1 & ...
    ACT.metric.acceleration.euclNormMinOne.Data >= params.thrAct_vig;
% ---------------------------------------------------------
% Save these activity levels as a timeseries in 'ACT.analysis.annotate'
ACT.analysis.annotate.acceleration.Data(idxLowActivity)                = 1; % Low activity bouts
ACT.analysis.annotate.acceleration.Data(idxLightActivity)              = 2; % light activity
ACT.analysis.annotate.acceleration.Data(idxMVPA)                       = 3; % moderate activity
ACT.analysis.annotate.acceleration.Data(idxMVPA & idxVigorousActivity) = 4; % vigorous activity
% ---------------------------------------------------------
% Set saved to false
ACT.saved = false;
% ---------------------------------------------------------
% Update the pipeline
ACT = cic_updatePipe(ACT, 'analysis');
% ---------------------------------------------------------
% Write history
ACT.history = char(ACT.history, '% ---------------------------------------------------------');
ACT.history = char(ACT.history, '% Annotate the accelerometry data using GGIR''s ''identify_level.R'' function');
ACT.history = char(ACT.history, '% -----');
ACT.history = char(ACT.history, '% Define the parameters');
ACT.history = char(ACT.history, sprintf('params.thrInact_time = %i; %% minutes', params.thrInact_time));
ACT.history = char(ACT.history, sprintf('params.thrInact_angle = %i; %% degrees', params.thrInact_angle));
ACT.history = char(ACT.history, sprintf('params.thrAct_time = %i; %% minutes', params.thrAct_time));
ACT.history = char(ACT.history, sprintf('params.thrAct_lig = %.4f; %% g', params.thrAct_lig));
ACT.history = char(ACT.history, sprintf('params.thrAct_mod = %.4f; %% g', params.thrAct_mod));
ACT.history = char(ACT.history, sprintf('params.thrAct_vig = %.4f; %% g', params.thrAct_vig));
ACT.history = char(ACT.history, sprintf('params.boutCrit = %i; %% percentage', params.boutCrit));
ACT.history = char(ACT.history, sprintf('params.boutClosed = %i; %% logical', params.boutClosed));
ACT.history = char(ACT.history, sprintf('params.boutMetric = %i; %% integer [1 to 4]', params.boutMetric));
ACT.history = char(ACT.history, '% -----');
ACT.history = char(ACT.history, '% Call the annotation function');
ACT.history = char(ACT.history, 'ACT = cic_annotateActivityGGIR(ACT, params);');

end % EOF