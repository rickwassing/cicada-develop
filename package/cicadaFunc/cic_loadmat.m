function ACT = cic_loadmat(fullpath)
% ---------------------------------------------------------
% Load the ACT structure from file
load(fullpath, 'ACT');
% ---------------------------------------------------------
% If the ACT structure did not exist in the file, return empty
if exist('ACT', 'var') == 0
    ACT = [];
    % ---------------------------------------------------------
else % The ACT structure exists
    % Extract filename and path
    [fpath, fname] = fileparts(fullpath);
    ACT.filename = fname;
    ACT.filepath = fpath;
    ACT.version  = cic_version();
    % ---------------------------------------------------------
    % Write history
    ACT.history = char(ACT.history, '% ---------------------------------------------------------');
    ACT.history = char(ACT.history, '% Load ACT structure from .mat file');
    ACT.history = char(ACT.history, sprintf('ACT = cic_loadmat(''%s'');', fullpath));
end

end % EOF
