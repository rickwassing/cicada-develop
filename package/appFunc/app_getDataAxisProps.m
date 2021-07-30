function [YLim, YScale, Position] = app_getDataAxisProps(app, type)

% Set RowSpans
rowSpans = [1, app.ACT.display.acceleration.rowspan];
for di = 1:length(app.ACT.display.order)
    rowSpans = [rowSpans, app.ACT.display.(app.ACT.display.order{di}).show*app.ACT.display.(app.ACT.display.order{di}).rowspan];
end

% Get the YLim and YScale
switch type
    case 'events'
        idx = 1;
        YLim = [0, 1];
        YScale = 'linear';
    case 'acceleration'
        idx = 2;
        add = ifelse(strcmpi(app.ACT.display.acceleration.view, 'angle'), 360, 0);
        YLim = [app.ACT.display.(type).range(1) + add, app.ACT.display.(type).range(2) + add];
        YScale = ifelse(app.ACT.display.(type).log == 0, 'linear', 'log');
    otherwise
        idx = find(strcmpi(app.ACT.display.order, type)) + 2;
        YLim = [app.ACT.display.(type).range(1), app.ACT.display.(type).range(2)];
        YScale = ifelse(app.ACT.display.(type).log == 0, 'linear', 'log');
end
% Get the Position
unit = (app.DataPanel.Position(4)/app.ACT.display.actogramLength - 22)/sum(rowSpans);
if idx == 1
    y = 1;
    h = 6 + unit * rowSpans(idx);
else
    y = 7 + unit*sum(rowSpans(1:idx-1));
    h = unit * rowSpans(idx);
end
if rowSpans(idx) == 0
    h = 0;
end
Position = [0, y, app.DataPanel.Position(3) - 2, h + 5];

end % EOF
