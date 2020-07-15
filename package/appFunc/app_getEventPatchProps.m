function [Visible, PickableParts, Color, UserData] = app_getEventPatchProps(app, day, event)

% Set Color and Visibility
switch event.label{:}
    case 'sleepWindow'
        Color = app.SleepWindowButton.BackgroundColor;
        Visible = ifelse(strcmp(event.type{:}, app.ACT.analysis.settings.sleepWindowType), 'on', 'off');
    case 'sleepPeriod'
        Color = app.SleepPeriodButton.BackgroundColor;
        Visible = ifelse(strcmp(event.type{:}, 'actigraphy'), 'on', 'off');
    case 'waso'
        Color = [94, 146, 243]/255;
        Visible = ifelse(strcmp(event.type{:}, 'actigraphy'), 'on', 'off');
    case 'reject'
        Color = app.ExclusionButton.BackgroundColor;
        Visible = 'on';
    case 'button'
        Color = app.ButtonPressButton.BackgroundColor;
        Visible = 'on';
    otherwise
        Color = [0.39, 0.70, 0.73];
        Visible = 'on';
end

% Set UserData
UserData.type = 'event';
UserData.input = 'editEvent';
UserData.eventLabel = event.label{:};
UserData.eventType = event.type{:};
UserData.id = event.id;
UserData.day = day;

% Set ButtonDownFunction and Pickable Parts
switch event.type{:}
    case {'manual', 'customEvent'}
        PickableParts = 'visible';
    otherwise
        PickableParts = 'none';
end
if strcmpi(event.label{:}, 'reject')
    PickableParts = 'visible';
end

end