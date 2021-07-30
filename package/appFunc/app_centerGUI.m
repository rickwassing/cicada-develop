function app_centerGUI(MainApp, ChildApp, ChildFigure)
% ---------------------------------------------------------
% Position the new app in the center of the Cicada app
pos = MainApp.CicadaUIFigure.Position;
h = ChildFigure.Position(3);
w = ChildFigure.Position(4);
x = (pos(3)-h)/2+pos(1);
y = (pos(4)-w)/2+pos(2);
ChildFigure.Position = [x y h w];
ChildFigure.Resize = 'off';
drawnow;            
end
