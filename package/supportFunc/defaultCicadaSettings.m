function Settings = defaultCicadaSettings()

Settings = struct();
% -----
Settings.importSettings = struct();
Settings.importSettings.sleepDiary = char(0);
% -----
Settings.display = struct();
Settings.display.actogramStartClock = '15:00';
Settings.display.actogramEndClock = '15:00';
Settings.display.actogramWidth = 'single';
Settings.display.actogramLength = 7;
% -----
Settings.display.acceleration = struct();
Settings.display.acceleration.rowspan = 2;
Settings.display.acceleration.log = 0;
Settings.display.acceleration.range = [0; 1];
Settings.display.acceleration.view = 'euclNorm';
% -----
Settings.display.acceleration.counts = struct();
Settings.display.acceleration.counts.log = 0;
Settings.display.acceleration.counts.range = [0; 1000];
% -----
Settings.display.acceleration.euclNorm = struct();
Settings.display.acceleration.euclNorm.log = 0;
Settings.display.acceleration.euclNorm.range = [0; 1];
% -----
Settings.display.acceleration.angle = struct();
Settings.display.acceleration.angle.log = 0;
Settings.display.acceleration.angle.range = [-120; 120];
% -----
Settings.analysis = struct();
Settings.analysis.epochLength = 5;
% -----
Settings.XTickSize = [12; 13; 16];

end