function [ACT, importSettings, err, msg] = cic_importSleepDiarySettings(ACT, fullpath)
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
ACT.analysis.settings.importSleepDiarySettings = importSettings;
% ---------------------------------------------------------
% Write history
ACT.history = char(ACT.history, '% -----');
ACT.history = char(ACT.history, '% Load the sleep diary import settings from .JSON file');
ACT.history = char(ACT.history, sprintf('[ACT, importSettings, err, msg] = cic_importSleepDiarySettings(ACT, ''%s'');', fullpath));
ACT.history = char(ACT.history, 'if err; error(msg); end');

end % EOF
