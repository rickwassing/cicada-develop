function cancel = app_askToUndoAnalysis(app)

    sel = uiconfirm(app.CicadaUIFigure, {'Cannot continue without undoing all results from the analysis functions.', 'Do you want to undo all analyses?'}, 'Question', ...
        'Options',{'No, cancel', 'Yes, undo analysis'},...
        'DefaultOption', 'No, cancel', ...
        'CancelOption', 'No, cancel', ...
        'Icon', 'question');
    switch sel
        case 'No, cancel'
            cancel = true;
        case 'Yes, undo analysis'
            cancel = false;
            % undo analysis (and any stats if required)
            app.ACT = cic_undoAnalysis(app.ACT);
            % Set the menu items
            app.Menu.ExportAnalysisMenu.Enable = 'off';
            app.Menu.ExportReportMenu.Enable = 'off';
            % Create the component list
            app.ComponentList = [app.ComponentList, {'Info', 'Menu', 'Events', 'Annotation', 'SettingsPanel'}];
    end

end
