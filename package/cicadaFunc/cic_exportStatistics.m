function ACT = cic_exportStatistics(ACT, fullpath)

REC = table;

% Check if all information exists, otherwise fill in default values
if isempty(ACT.info.study); ACT.info.study = 'not specified'; end
if isempty(ACT.info.researcher); ACT.info.researcher = 'not specified'; end
if isempty(ACT.info.subject); ACT.info.subject = 'not specified'; end
if isempty(ACT.info.group); ACT.info.group = 'not specified'; end
if isempty(ACT.info.condition); ACT.info.condition = 'not specified'; end
if isempty(ACT.info.session); ACT.info.session = 'not specified'; end
if isempty(ACT.info.dob); ACT.info.dob = 'not specified'; end
if isempty(ACT.info.sex); ACT.info.sex = 'not specified'; end
if isempty(ACT.info.height); ACT.info.height = nan; end
if isempty(ACT.info.weight); ACT.info.weight = nan; end
if isempty(ACT.info.handedness); ACT.info.handedness = 'not specified'; end
if isempty(ACT.info.device); ACT.info.device = 'not specified'; end
if isempty(ACT.info.deviceLoc); ACT.info.deviceLoc = 'not specified'; end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXPORT VARIABLES ABOUT THE ENTIRE RECORDING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INFORMATION
REC.cicadaVersion = cic_version();
REC.matlabVersion = version();
REC.filename = ACT.filename;
REC.study = ACT.info.study;
REC.researcher = ACT.info.researcher;
REC.subject = ACT.info.subject;
REC.group = ACT.info.group;
REC.condition = ACT.info.condition;
REC.session = ACT.info.session;
REC.dob = ACT.info.dob;
REC.sex = ACT.info.sex;
REC.height = ACT.info.height;
REC.weight = ACT.info.weight;
REC.bmi = ACT.info.weight / (ACT.info.height/100)^2;
REC.handedness = ACT.info.handedness;
REC.device = ACT.info.device;
REC.deviceLoc = ACT.info.deviceLoc;

% ABOUT THE RECORDING
REC.samplingRate = ACT.srate;
REC.epochLength = ACT.epoch;
REC.recStartDate = datestr(ACT.xmin, 'dd/mm/yyyy HH:MM');
REC.recEndDate = datestr(ACT.xmax, 'dd/mm/yyyy HH:MM');

% ABOUT THE ANNOTATION ANALYSIS
if isfield(ACT.analysis, 'settings') && isfield(ACT.analysis, 'annotate')
    if isfield(ACT.analysis.annotate, 'acceleration')
        REC.annotAccBoutCrit      = ACT.analysis.settings.boutCrit;
        REC.annotAccBoutClosed    = ACT.analysis.settings.boutClosed;
        REC.annotAccBoutMetric    = ACT.analysis.settings.boutMetric;
        REC.annotAccThrInactAngle = ACT.analysis.settings.inactAngle;
        REC.annotAccThrInactTime  = ACT.analysis.settings.inactTime;
        REC.annotAccThrActTime    = ACT.analysis.settings.actTime;
        REC.annotAccThrActLig     = ACT.analysis.settings.actLight;
        REC.annotAccThrActMod     = ACT.analysis.settings.actModerate;
        REC.annotAccThrActVig     = ACT.analysis.settings.actVigorous;
    end
    if isfield(ACT.analysis.annotate, 'light')
        REC.annotLightMetric    = ACT.analysis.settings.lightMetric;
        REC.annotLightThrMod    = ACT.analysis.settings.lightThreshold(1);
        REC.annotLightThrBright = ACT.analysis.settings.lightThreshold(2);
    end
end

% Write the average stats from all days
T = ACT.stats.average.all;
T = [repmat(REC, size(T, 1), 1), T];
writetable(T, [fullpath, '_average-all.csv']);

% Write the average stats from week days
T = ACT.stats.average.week;
T = [repmat(REC, size(T, 1), 1), T];
writetable(T, [fullpath, '_average-week.csv']);

% Write the average stats from weekend days
T = ACT.stats.average.weekend;
T = [repmat(REC, size(T, 1), 1), T];
writetable(T, [fullpath, '_average-weekend.csv']);

% Write the daily stats
T = ACT.stats.daily;
T = [repmat(REC, size(T, 1), 1), T];
writetable(T, [fullpath, '_daily.csv']);

% Write sleep stats if available
if isfield(ACT.stats, 'sleep')
    if isfield(ACT.stats.sleep, 'actigraphy')
        T = ACT.stats.sleep.actigraphy;
        T = [repmat(REC, size(T, 1), 1), T];
        writetable(T, [fullpath, '_sleep-actigraphy.csv']);
    end
    if isfield(ACT.stats.sleep, 'sleepDiary')
        T = ACT.stats.sleep.sleepDiary;
        T = [repmat(REC, size(T, 1), 1), T];
        writetable(T, [fullpath, '_sleep-sleepdiary.csv']);
    end
end
if isfield(ACT.stats, 'custom')
    fnames = fieldnames(ACT.stats.custom);
    for fi = 1:length(fnames)
        T = ACT.stats.custom.(fnames{fi});
        T = [repmat(REC, size(T, 1), 1), T];
        writetable(T, [fullpath, '_custom-' strrep(lower(fnames{fi}), ' ', '') '.csv']);
    end
end

% ---------------------------------------------------------
% Write history 
ACT.history = char(ACT.history, '% ---------------------------------------------------------');
ACT.history = char(ACT.history, '% Export statistics to .CSV files');
ACT.history = char(ACT.history, sprintf('ACT = cic_exportStatistics(ACT, ''%s'');', fullpath));

end % EOF
