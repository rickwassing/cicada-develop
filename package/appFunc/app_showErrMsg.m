function app_showErrMsg(app, ME)
% ----------------------------------------
% Close all menu's
delete(app.importSleepDiaryApp);
delete(app.editDatasetInfoApp);
delete(app.selectDataApp);
delete(app.changeTimeZoneApp);
delete(app.changeEpochLengthApp);
delete(app.annotateActivityGGIRApp);
delete(app.annotateLightApp);
delete(app.createEventApp);
delete(app.createDailyEventApp);
delete(app.createRelativeEventApp);
delete(app.editEventApp);
delete(app.selectColorApp);
% ----------------------------------------
% clean the lifecycle
app.Components = {};
app.ComponentList = {};
% ----------------------------------------
% Construct error message
errmsg = {ME.message};
for si = 1:length(ME.stack)
    errmsg = [errmsg; {['Error in ', ME.stack(si).name, ' (line ', num2str(ME.stack(si).line) ,')']}]; %#ok<AGROW>
end
% ----------------------------------------
% Show error message
closeWaitbar()
sel = uiconfirm(app.CicadaUIFigure, errmsg, 'Error. Well, that is embarrassing...', ...
    'Options',{'Ok'},...
    'DefaultOption', 'Ok', ...
    'Icon', 'error'); %#ok<NASGU>
end