function [Position, Title, UserData, StartDate, EndDate] = app_getDataPanelProps(app, day)

switch app.ACT.display.actogramWidth
    case 'single'
        add = 0;
    case 'double'
        add = 1;
end
StartDate = app.ACT.startdate+(day-1);
EndDate = app.ACT.enddate-(app.ACT.ndays-day) + add;

% Set UserData
UserData.Day = day;
UserData.StartDate = StartDate;
UserData.EndDate = EndDate;

% Set position
h = app.ACT.ndays*(app.DataPanel.Position(4)/app.ACT.display.actogramLength);
Position = [1, ...
    h - day*(h/app.ACT.ndays), ...
    app.DataPanel.Position(3) - 4, ...
    h/app.ACT.ndays];

% Set title
Title = [...
    datestr(app.ACT.startdate+(day-1), 'ddd dd/mm/yyyy') ' - ', ...
    datestr(app.ACT.enddate-(app.ACT.ndays-day) + add, 'ddd dd/mm/yyyy')];

end