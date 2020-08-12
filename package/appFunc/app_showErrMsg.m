function app_showErrMsg(app, ME)
% ----------------------------------------
% Construct error message
errmsg = {ME.message};
for si = 1:length(ME.stack)
    errmsg = [errmsg; {['Error in ', ME.stack(si).name, ' (line ', num2str(ME.stack(si).line) ,')']}];
end
% ----------------------------------------
% Show error message
closeWaitbar()
sel = uiconfirm(app.CicadaUIFigure, errmsg, 'Error. Well, that is embarrassing...', ...
    'Options',{'Ok'},...
    'DefaultOption', 'Ok', ...
    'Icon', 'error');
end