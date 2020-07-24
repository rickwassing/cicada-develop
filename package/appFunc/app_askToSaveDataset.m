function result = app_askToSaveDatset(app, event)

% Initialize result to be true
result = true;

% If ACT is empty and is not saved alread, ask to save the file
if ~isempty(app.ACT)
    if ~app.ACT.saved && isfield(app.ACT, 'filename')
        % Ask to save the file, don't save, or cancel the process
        message = {'Save the dataset to' app.ACT.filename 'before closing?'};
        title   = 'Save Dataset';
        sel = uiconfirm(app.CicadaUIFigure, message, title, ...
            'Options',{'Cancel', 'Don''t save', 'Save'},...
            'DefaultOption', 'Cancel', ...
            'CancelOption', 'Cancel', ...
            'Icon', 'question');
        
        % If the user pressed 'Cancel' or 'Esc', return false to stop the current process
        switch sel
            case 'Cancel'
                result = false;
            case 'Save'
                app.SaveDatasetMenu.MenuSelectedFcn(app, event);
                if ~app.ACT.saved % Something went wrong while saving
                    result = false;
                end
        end
    end
end
end