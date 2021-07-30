function YData = app_getCursorYData(app, axType)

if strcmpi(axType, 'events')
    YData = [0, 1];
else
    if strcmpi(app.ACT.display.acceleration.view, 'angle')
        add = 360;
    else
        add = 0;
    end
    YData = [app.ACT.display.acceleration.range(1) + add, app.ACT.display.acceleration.range(2) + add];
end
