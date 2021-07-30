function cancel = app_askToUndoStatistics(app)

    sel = uiconfirm(app.CicadaUIFigure, {'Cannot continue without undoing all statistics.', 'Do you want to undo all statistics?'}, 'Question', ...
        'Options',{'No, cancel', 'Yes, undo statistics'},...
        'DefaultOption', 'No, cancel', ...
        'CancelOption', 'No, cancel', ...
        'Icon', 'question');
    switch sel
        case 'No, cancel'
            cancel = true;
        case 'Yes, undo statistics'
            cancel = false;
            % undo stats
            app.ACT = cic_undoStatistics(app.ACT);
            % Set the menu items
            app.Menu.ExportAnalysisMenu.Enable = 'off';
            app.Menu.ExportReportMenu.Enable = 'off';
            % Create the component list
            app.ComponentList = [app.ComponentList, {'Info', 'Menu', 'Stats'}];
    end

end
