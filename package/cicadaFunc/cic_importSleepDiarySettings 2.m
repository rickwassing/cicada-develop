function [ACT, importSettings, err, msg] = cic_importSleepDiarySettings(ACT, fullpath)

if exist(fullpath, 'file') == 0
    % ---------------------------------------------------------
    % File could not be found, so create default import settings
    importSettings.format.date = 'dd/mm/yyyy';
    importSettings.format.lightsOut = 'HH:MM';
    importSettings.format.sleepLatency = 'minutes';
    importSettings.format.awakenings = 'integer';
    importSettings.format.waso = 'minutes';
    importSettings.format.finAwake = 'HH:MM';
    importSettings.format.lightsOn = 'HH:MM';
    importSettings.idx.date = [];
    importSettings.idx.lightsOut = [];
    importSettings.idx.sleepLatency = [];
    importSettings.idx.awakenings = [];
    importSettings.idx.waso = [];
    importSettings.idx.finAwake = [];
    importSettings.idx.lightsOn = [];
    err = true;
    msg = 'Import settings JSON file could not be found. Check the path to ''sleepDiary'' in the Cicada Settings .JSON file. Default import settings will be used.';
else
    % ---------------------------------------------------------
    % Read the JSON file
    importSettings = jsondecode(fileread(fullpath));
    if ~isfield(importSettings, 'format') || ~isfield(importSettings, 'idx')
        err = true;
        msg = 'Selected JSON file does not contain the required fields ''format'' and ''idx''.';
        if isfield(ACT.analysis.settings, 'importSleepDiarySettings')
            importSettings = ACT.analysis.settings.importSleepDiarySettings;
        else
            importSettings = struct();
        end
        return
    else
        err = false;
        msg = '';
    end
end
if ~isfield(importSettings.format, 'sleepLatency')
    importSettings.format.sleepLatency = 'minutes';
end
if ~isfield(importSettings.format, 'waso')
    importSettings.format.waso = 'minutes';
end
if ~isfield(importSettings.format, 'awakenings')
    importSettings.format.waso = 'integer';
end
ACT.analysis.settings.importSleepDiarySettings = importSettings;
% ---------------------------------------------------------
% Write history
ACT.history = char(ACT.history, '% -----');
ACT.history = char(ACT.history, '% Load the sleep diary import settings from .JSON file');
ACT.history = char(ACT.history, sprintf('[ACT, importSettings, err, msg] = cic_importSleepDiarySettings(ACT, ''%s'');', fullpath));
ACT.history = char(ACT.history, 'if err; error(msg); end');

end % EOF
