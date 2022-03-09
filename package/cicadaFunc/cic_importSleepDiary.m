function [ACT, rawSleepDiary] = cic_importSleepDiary(ACT, fullpath)
% ---------------------------------------------------------
% Load the import options for this file
opts = detectImportOptions(fullpath);

switch class(opts)
    case 'matlab.io.text.DelimitedTextImportOptions'
        opts = detectImportOptions(fullpath, 'DurationType', 'text', 'DatetimeType', 'text');
    case 'matlab.io.spreadsheet.SpreadsheetImportOptions'
        opts.VariableTypes(ismember(opts.VariableTypes, {'duration', 'datetime'})) = {'char'};
end
% ---------------------------------------------------------
% Load the data
rawSleepDiary = readtable(fullpath, opts);
ACT.etc.rawSleepDiary = rawSleepDiary;
% ---------------------------------------------------------
% Write history
ACT.history = char(ACT.history, '% -----');
ACT.history = char(ACT.history, '% Import raw sleep diary data from tabular text file or spreadsheet (.TXT, .CSV, .XLS, .XLSX, etc.)');
ACT.history = char(ACT.history, sprintf('[ACT, rawSleepDiary] = cic_importSleepDiary(ACT, ''%s'');', fullpath));

end % EOF