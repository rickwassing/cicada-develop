.. _overview-act-structure-top:

===================
The 'ACT' Structure
===================

This section provides a detailed overview of all the fields in the ``ACT`` Dataset which is a Matlab variable of class ``struct``. 

- **ACT.filename**, and **ACT.filepath** [string] specifies the filename and path.
- **ACT.version** [string] specifies the Cicada version
- **ACT.info** [struct] contains all variables related to the device, subject and study
    - **info.device** [string] device name
    - **info.serial** [string] device serial number
    - **info.institute** [string] institute name
    - **info.study** [string] study name
    - **info.researcher** [string] researcher's name
    - **info.subject** [string] subject identifier
    - **info.group** [string] group name this subject is assigned to, e.g. 'controls'
    - **info.condition** [string] study condition this subject is assigned to, e.g. 'placebo'
    - **info.session** [string] session name or number this recording belongs to, e.g. 'baseline'
    - **info.dob** [string] participant's date of birth
    - **info.sex** [string] participant's sex
    - **info.height** [double] participant's height in centimeters
    - **info.weight** [double] participant's weight in kilograms
    - **info.handedness** [string] participant's handedness
    - **info.deviceLoc** [string] location where the actigraphy device was worn
    - **info.phenotype** [struct] contains any additional variables from psychometric or clinical surveys
- **ACT.pnts** [int] number of data points in Raw actigraphy Data
- **ACT.srate** [int] sampling frequency of Raw actigraphy Data
- **ACT.xmin** [datenum] start date of the recording
- **ACT.xmax** [datenum] end date of the recording
- **ACT.startdate** [datenum] start date of the data analysis windows
- **ACT.enddate** [datenum] start date of the data analysis windows
- **ACT.ndays** [int] number of whole analysis windows
- **ACT.times** [double] timeseries vector contains datenum values for each sample
- **ACT.timezone** [string] time zone
- **ACT.epoch** [int] epoch length in seconds used to transform Raw Data into Metrics
- **ACT.data** [struct] contains all Raw Data
    - **data.acceleration.x** [double] Accelerometry in x-axis
    - **data.acceleration.y** [double] Accelerometry in y-axis
    - **data.acceleration.z** [double] Accelerometry in z-axis
    - **data.(measurement).(datatype)** [double] e.g. ``data.temperature.wrist``, to store temperature data obtained from the wrist; or ``data.light.wideSpec``, to store wide-spectrum light exposure
- **ACT.metric** [struct] contains all (derived) Metrics, in common Epochs of length ``ACT.epoch``
    - **metric.acceleration.euclNormMinOne** [timeseries] Euclidean normal of the vector ``[x, y, z]`` minus 1 to account for static gravity
    - **metric.acceleration.bpFiltEuclNorm** [timeseries] Euclidean normal bandpass filtered between 0.2 and 15 Hz using a 4th order Butterworth filter
    - **metric.acceleration.angle_z** [timeseries] angle of the Accelerometry device in the z-axis, given by ``atan(z / sqrt(x^2 + y^2)) / (pi/180)``, where ``x``, ``y`` and ``z`` are median acceleration values obtained in moving windows of length ``ACT.epoch``
- **ACT.analysis** [struct] contains all Annotation and Events
    - **analysis.annotate** [struct] contains all Annotatation timeseries
        - **annotate.acceleration** [timeseries] contains Annotation of 'acceleration' Metrics
        - **annotate.(measurement)** [timeseries] e.g. ``analysis.annotate.light`` contains Annotation of 'light' Metrics
    - **analysis.events** [table] contains all events
        - **events.id** [int] unique identifier
        - **events.onset** [datenum] onset of event
        - **events.duration** [double] duration of event in days
        - **events.label** [cell] event label
        - **events.type** [cell] event type
    - **analysis.settings** [struct] contains all parameter values used in the analysis
- **ACT.stats** [struct] contains all output from statistics
    - **stats.average** [struct] contains all average statistics
        - **average.all** [table] contains average statistics across all days
        - **average.week** [table] contains average statistics across weekdays
        - **average.weekend** [table] contains average statistics across weekend days
    - **stats.daily** [table] contains daily statistics
    - **stats.sleep** [struct] contains statistics for Sleep Window and Sleep Period Events
        - **sleep.actigraphy** [table] contains statistics for Sleep/Nap Window and Sleep/Nap Period Events of type ``actigraphy``
        - **sleep.sleepDiary** [table] contains statistics for Sleep Window and Sleep Period Events of type ``sleepDiary``
    - **stats.custom** [struct] contains statistics for Custom Events
        - **custom.(label)** [table] contains statistics for Custom Events identified by ``label``
- **ACT.display** [struct] contains all display settings
- **ACT.etc** [struct] 'etcetera' contains all other non-essential variables
- **ACT.saved** [bool] indicates whether file is saved or not
- **ACT.pipe** [cell] keeps track of pipeline stages, ``load``, ``preproc``, ``analysis`` and ``statistics``
- **ACT.history** [char] stores all steps executed by the user interface as Matlab code to reproduce the exact same data processing