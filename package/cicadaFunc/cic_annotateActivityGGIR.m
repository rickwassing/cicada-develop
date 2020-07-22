function ACT = cic_annotateActivityGGIR(ACT, params)
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
% ---------------------------------------------------------
% Save 'sustainedInactivity' as a timeseries in 'ACT.analysis.annotate'
% First remove any epoch that was annotated as sustained inactive
ACT.analysis.annotate.acceleration.Data(ACT.analysis.annotate.acceleration.Data == -1) = 0; 
% Now add the sustained inactive epochs
ACT.analysis.annotate.acceleration.Data(sustainedInactive == 1) = -1;

% ---------------------------------------------------------
% PART 2 - FIND EPOCHS OF LIGHT, MODERATE AND VIGOROUS ACTIVITY
% ---------------------------------------------------------
% Get the bouts of moderate to vigorous activity
idxMVPA = ...
    ACT.metric.acceleration.euclNormMinOne.Data >= params.thrAct_mod & sustainedInactive ~= 1;
idxMVPA = ggirGetBout(idxMVPA, params.thrAct_time*(60/ACT.epoch), ...
    'boutcriter', params.boutCrit/100, ...
    'boutClosed', params.boutClosed == 1, ...
    'boutMetric', params.boutMetric, ...
    'ws3', ACT.epoch) == 1;
% ---------------------------------------------------------
% Get the bouts of inactivity
idxInactive = ...
    ACT.metric.acceleration.euclNormMinOne.Data < params.thrAct_lig & ...
    ~idxMVPA;
idxInactive = ggirGetBout(idxInactive, params.thrInact_time*(60/ACT.epoch), ...
    'boutcriter', params.boutCrit/100, ...
    'boutClosed', params.boutClosed == 1, ...
    'boutMetric', params.boutMetric, ...
    'ws3', ACT.epoch) == 1;
% ---------------------------------------------------------
% Get the bouts of light activity
idxLightActivity = ...
    ACT.metric.acceleration.euclNormMinOne.Data >= params.thrAct_lig & ...
    ~idxInactive & sustainedInactive ~= 1;
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
ACT.analysis.annotate.acceleration.Data(ACT.analysis.annotate.acceleration.Data == 1) = 0; % first remove the old annotations
ACT.analysis.annotate.acceleration.Data(ACT.analysis.annotate.acceleration.Data == 2) = 0; 
ACT.analysis.annotate.acceleration.Data(ACT.analysis.annotate.acceleration.Data == 3) = 0; 
ACT.analysis.annotate.acceleration.Data(idxLightActivity)              = 1; % light activity
ACT.analysis.annotate.acceleration.Data(idxMVPA)                       = 2; % moderate activity
ACT.analysis.annotate.acceleration.Data(idxMVPA & idxVigorousActivity) = 3; % vigorous activity
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
ACT.history = char(ACT.history, 'ACT = cic_ggirAnnotation(ACT, params);');

end % EOF