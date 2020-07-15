# Cicada

This repository contains the source files for Cicada, an open source software for analysing actigraphy and data from other wearable devices.

## Versioning

We use [semantic versioning](http://semver.org/). Current verion is 0.1.2. Cicada is still in initial development. Anything may change at any time and the software should not be considered stable.

## Authors

-   **Rick Wassing**, Woolcock Institute of Medical Research, The University of Sydney, Australia - _Initial work_

## License

This project is licensed under the MIT License - see the [LICENSE.md](https://github.com/rickwassing/cicada-develop/blob/master/docs/LICENSE) file for details

## Acknowledgments

In building Cicada, I have translated and adopted functionality from other open-source projects.
I would kindly thank:

-   Vincent T. van Hees and colleagues for their pioneering work on GGIR, an R-package to process accelerometry data. [Visit the GGIR CRAN repository](https://cran.r-project.org/web/packages/GGIR/index.html).
-   Maxim Osipov, Bart Te Lindert, and German Gómez-Herrero for their work on the [Actant Activity Analysis Toolbox](https://github.com/btlindert/actant-1) and GeneActiv .bin file import functions.

## Getting Started

Cicada is written in Matlab R2019b. I invite anyone to clone the repository and contribute to the project. If you just want to use the software, you don't need Matlab, just download the compiled executables Cicada.exe (Windows) or Cicada.app (MacOs)from the this [Cicada repository].

The data from actigraphy and/or other wearable devices are stored in a structure, named 'ACT'. This structure is highly similar to that of the ['EEG' structure](https://sccn.ucsd.edu/wiki/A05:_Data_Structures) used in [EEGLAB](https://sccn.ucsd.edu/eeglab/index.php).

### 'ACT' data structure

-   **ACT.filename**, and **ACT.filepath** [string] specifies the filename and path.
-   **ACT.version** [string] specifies the Cicada version
-   **ACT.info** [struct] contains all variables related to the device, subject and study
    -   **info.device** [string] device name
    -   **info.serial** [string] device serial number
    -   **info.institute** [string] institute name
    -   **info.study** [string] study name
    -   **info.researcher** [string] researcher's name
    -   **info.subject** [string] subject identifier
    -   **info.group** [string] group name this subject is assigned to, e.g. 'controls'
    -   **info.condition** [string] study condition this subject is assigned to, e.g. 'placebo'
    -   **info.session** [string] session name or number this recording belongs to, e.g. 'baseline'
    -   **info.dob** [string] participant's date of birth
    -   **info.sex** [string] participant's sex
    -   **info.height** [double] participant's height in centimeters
    -   **info.weight** [double] participant's weight in kilograms
    -   **info.handedness** [string] participant's handedness
    -   **info.deviceLoc** [string] location where the accelerometry device was worn
    -   **info.phenotype** [struct] contains any additional variables from psychometric or clinical surveys
-   **ACT.pnts** [int] number of data points in raw accelerometry data
-   **ACT.srate** [int] sampling frequency of raw accelerometry data
-   **ACT.xmin** [datenum] start date of the recording
-   **ACT.xmax** [datenum] end date of the recording
-   **ACT.startdate** [datenum] start date of the data analysis windows
-   **ACT.enddate** [datenum] start date of the data analysis windows
-   **ACT.ndays** [int] number of whole analysis windows
-   **ACT.times** [double] timeseries vector contains datenum values for each sample
-   **ACT.timezone** [string] time zone
-   **ACT.epoch** [int] epoch length in seconds used to transform raw data into metrics
-   **ACT.data** [struct] contains all raw data
    -   **data.acceleration.x** [double] accelerometry in x-axis
    -   **data.acceleration.y** [double] accelerometry in y-axis
    -   **data.acceleration.z** [double] accelerometry in z-axis
    -   **data.(measurement).(datatype)** [double] e.g. 'data.temperature.wrist', to store temperature data obtained from the wrist; or 'data.light.w', to store broad-spectrum light exposure
-   **ACT.events** [table] contains all events
    -   **events.id** [int] unique identifier
    -   **events.onset** [datenum] onset of event
    -   **events.duration** [double] duration of event in days
    -   **events.label** [cell] event label
    -   **events.type** [cell] event type
-   **ACT.metric** [struct] contains all metric
    -   **metric.acceleration.euclNormMinOne** [timeseries] Euclidean normal of the vector [x, y, z] minus 1 to account for static gravity, averaged in epochs of length 'ACT.epoch'
    -   **metric.acceleration.bpFiltEuclNorm** [timeseries] Euclidean norm bandpass filtered between 0.2 and 15 Hz using a 4th order Butterworth filter, averaged in epochs of length 'ACT.epoch'
    -   **metric.acceleration.angle_z** [timeseries] angle of the accelerometry device in the z-axis, given by 'atan(z / sqrt(x^2 + y^2)) / (pi/180)' where 'x', 'y' and 'z' are median acceleration values obtained in moving windows of length 'ACT.epoch'
-   **ACT.analysis** [struct] contains all output from analysis steps
-   **ACT.stats** [struct] contains all output from statistics
-   **ACT.display** [struct] contains all display settings
-   **ACT.etc** [struct] 'etcetera' contains all other non-essential variables
-   **ACT.saved** [bool] indicates whether file is saved or not
-   **ACT.pipe** [cell] keeps track of pipeline stages, 'load', 'preproc', 'analysis' and 'statistics'
-   **ACT.history** [char] stores all steps executed by the user interface as Matlab code to reproduce the exact same data processing

### Functions

-   **package/appFunc** contains all functions that start with 'app\_'. They contruct the graphical user interface by updating each component's properties upon events and changes in the data.
-   **package/cicadaFunc** contains all high-level functions that start with 'cic*' and either manipulate the data directly or call sub-functions to do so. This organization is highly similar to the 'pop*' functions in EEGLAB.
-   **package/mountFunc** contains all functions that start with 'mount\_', which are used to draw graphical objects such as, 'plot()', 'patch()' and 'barh', or other components such as 'uiaxes()' and 'uipanel'.
-   **package/supportFunc** contains all other functions that are used by the aforementioned functions.

### Settings files

-   **settings/CicadaSettings.json** specifies the default settings for displaying the data, epoch length, and importing sleep diary data.
-   **settings/xSleepDiary.json** specifies the format and column number (index) of the date and time used to encode the sleep diary data. Multiple .json files can be specified, loaded, edited and saved in order to load sleep diaries with different formatting.

### Menu items and their call-alone functions

**File > Open WorkSpace**

```
ACT = cic_loadmat(fullpath);
[ACT, err, msg] = cic_checkDataset(ACT);
ACT = cic_calcEpochedMetrics(ACT, epoch); % Epoch length in seconds
ACT = cic_getDays(ACT, analysisWinStart, analysisWinEnd); % e.g. '15:00', '15:00'
```

**File > Save WorkSpace (As)**

```
ACT = cic_savemat(ACT, fullpath);
```

**File > Import Data > Import GeneActiv (.bin)**

```
ACT = cic_importGeneActivBin(fullpath);
ACT = cic_calcEpochedMetrics(ACT, epoch); % Epoch length in seconds
ACT = cic_getDays(ACT, analysisWinStart, analysisWinEnd); % e.g. '15:00', '15:00'
```

**File > Import Events > Import Sleep Diary**

```
[ACT, rawSleepDiary] = cic_importSleepDiary(ACT, fullpath); % Path to tabular text file or spreadsheet
[ACT, importSettings, err, msg] = cic_importSleepDiarySettings(ACT, fullpath); % Path to .JSON settings file
[ACT, err, msg] = cic_parseSleepDiary(ACT, rawSleepDiary, importSettings);
ACT = cic_diarySleepEvents(ACT); % Generate events in 'ACT.events' from sleep diary
ACT = cic_actigraphySleepEvents(ACT); % Genererate sleep period and waso events if annotation is available
```

**File > Export > Statistics**

```
ACT = cic_exportStatistics(ACT, fullpath); % Write the statistics in 'ACT.stats' to .CSV files
```

**File > Export > Report**

```
% Sorry, this part of Cicada has not been developed yet.
```

**File > Export > Matlab Code**

```
ACT = cic_writeHistory(ACT, fullpath); % Write history to .m Matlab script
```

**Edit > Dataset Info**

```
ACT = cic_editInformation(ACT, newInfo); % Structure with any number, name and type of fields
```

**Edit > Select Data**

```
ACT = cic_selectDatasetUsingTime(ACT, startDate, endDate); % Start and end date [datenum] to crop the dataset to
ACT = cic_getDays(ACT, analysisWinStart, analysisWinEnd); % e.g. '15:00', '15:00'
```

**Edit > Change Time Zone**

```
ACT = cic_changeTimeZone(ACT, newTimeZone) % New time zone [string]
ACT = cic_getDays(ACT, analysisWinStart, analysisWinEnd); % e.g. '15:00', '15:00'
```

**Edit > Change Epoch Length**

```
ACT = cic_calcEpochedMetrics(ACT, epoch); % New epoch length in seconds
```

**Preprocess > GGIR Automatic Calibration**

```
ACT = cic_ggirAutomaticCalibration(ACT);
ACT = cic_calcEpochedMetrics(ACT, epoch); % Epoch length in seconds
```

**Preprocess > GGIR Non-Wear Detection**

```
[ACT, err] = cic_ggirDetectNonWear(ACT);
```

**Analysis > Annotate Epochs > GGIR Annotation**

```
ACT = cic_ggirAnnotation(ACT, params); % Parameters used in algorithm [struct]
ACT = cic_actigraphySleepEvents(ACT); % Genererate sleep period and waso events if sleep windows are available
```

**Analysis > Events > Create Daily Events**

```
ACT = cic_createDailyEvent(ACT, onset, duration, label); % Onset [string] in 'HH:MM', duration in hours, label [string]
```

**Analysis > Events > Create Relative Events**

```
ACT = cic_createRelativeEvent(ACT, ...
    ref, ...      % [string] either 'onset' or 'offset'
    refLabel, ... % [string] label of reference events
    refType, ...  % [string] type of reference events
    delay, ...    % [double] delay of new events, value can be negative or positive
    duration, ... % [double] duration of new events
    newLabel);    % [string] label of new events
```

**Analysis > Events > GGIR Sleep Detection**

```
ACT = cic_ggirSleepPeriodDetection(ACT);
ACT = cic_actigraphySleepEvents(ACT); % Genererate sleep period and waso events if annotation is available
```

**Statistics > Generate Statistics**

```
ACT = cic_statistics(ACT); % Calculate average, daily and sleep statistics
ACT = cic_statistics(ACT, 'customEvent', eventLabel); % Calculate statistics for custom events
```
