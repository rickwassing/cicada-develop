function ACT = newDataset()

ACT = struct();

ACT.filepath  = '';
ACT.filename  = '';
ACT.version   = cic_version();
ACT.info      = struct();
ACT.pnts      = zeros(0);
ACT.srate     = zeros(0);
ACT.xmin      = zeros(0);
ACT.xmax      = zeros(0);
ACT.startdate = zeros(0);
ACT.enddate   = zeros(0);
ACT.ndays     = zeros(0);
ACT.times     = zeros(0);
ACT.timezone  = '';
ACT.epoch     = zeros(0);
ACT.data      = struct();
ACT.events    = table();
ACT.metric    = struct();
ACT.analysis  = struct();
ACT.stats     = struct();
ACT.display   = struct();
ACT.etc       = struct();
ACT.saved     = true;
ACT.pipe      = '';
ACT.history   = '';

ACT.info.device     = '';
ACT.info.serial     = '';
ACT.info.institute  = '';
ACT.info.study      = '';
ACT.info.researcher = '';
ACT.info.subject    = '';
ACT.info.group      = '';
ACT.info.condition  = '';
ACT.info.session    = '';
ACT.info.dob        = '';
ACT.info.sex        = '';
ACT.info.height     = zeros(0);
ACT.info.weight     = zeros(0);
ACT.info.handedness = '';
ACT.info.deviceLoc  = '';
ACT.info.phenotype  = struct();

% Do not assume any data specs
% ACT.data.acceleration.x = zeros(0);
% ACT.data.acceleration.y = zeros(0);
% ACT.data.acceleration.z = zeros(0);
% ACT.data.light          = struct();
% ACT.data.temperature    = struct();
% ACT.data.bodyposition   = struct();
% ACT.data.heart          = struct();
% ACT.data.breathing      = struct();
% ACT.data.blood          = struct();

ACT.events.id       = zeros(0);
ACT.events.onset    = zeros(0);
ACT.events.duration = zeros(0);
ACT.events.label    = zeros(0);
ACT.events.type     = zeros(0);

ACT.analysis.settings = struct();
ACT.analysis.annotate.acceleration = timeseries();

end