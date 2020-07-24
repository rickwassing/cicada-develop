# Cicada

This repository contains the source files for Cicada, an open source software for analysing actigraphy and data from other wearable devices.

## Versioning

We use [semantic versioning](http://semver.org/). Current verion is 0.1.2. Cicada is still in initial development. Anything may change at any time and the software should not be considered stable.

## Authors

-   **Rick Wassing**, rick.wassing@sydney.edu.au, Woolcock Institute of Medical Research, The University of Sydney, Australia

> ### Your help is more than welcome!
>
> I am a neuroscientist, foremost, and not a software developer. Although I have ample experience in Matlab and other coding-languages, and I have coded Cicada to the best of my abilities, it may not be the most efficient way the software could have been written. I would be very grateful for anyone who'd like to contribute to Cicada.

## License

![Creative Commons License](https://i.creativecommons.org/l/by-sa/4.0/80x15.png) This work is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/).

## Acknowledgments

In building Cicada, I have translated and adopted functionality from other open-source projects.
I would kindly thank:

-   Vincent T. van Hees and colleagues for their pioneering work on GGIR, an R-package to process accelerometry data. [Visit the GGIR CRAN repository](https://cran.r-project.org/web/packages/GGIR/index.html).
-   Maxim Osipov, Bart Te Lindert, and German Gómez-Herrero for their work on the [Actant Activity Analysis Toolbox](https://github.com/btlindert/actant-1) and GeneActiv .bin file import functions.

## Getting Started

Cicada is written in Matlab R2019b. I invite anyone to clone the repository and contribute to the project. If you just want to use the software, you don't need Matlab, just download the compiled executables Cicada.exe (Windows) or Cicada.app (MacOs)from the this [Cicada repository].

The data from actigraphy and/or other wearable devices are stored in a structure, named `ACT`. This structure is highly similar to that of the [`EEG` structure](https://sccn.ucsd.edu/wiki/A05:_Data_Structures) used in [EEGLAB](https://sccn.ucsd.edu/eeglab/index.php).

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
    -   **data.(measurement).(datatype)** [double] e.g. `data.temperature.wrist`, to store temperature data obtained from the wrist; or `data.light.w`, to store broad-spectrum light exposure
-   **ACT.analysis.events** [table] contains all events
    -   **events.id** [int] unique identifier
    -   **events.onset** [datenum] onset of event
    -   **events.duration** [double] duration of event in days
    -   **events.label** [cell] event label
    -   **events.type** [cell] event type
-   **ACT.metric** [struct] contains all metric
    -   **metric.acceleration.euclNormMinOne** [timeseries] Euclidean normal of the vector [x, y, z] minus 1 to account for static gravity, averaged in epochs of length `ACT.epoch`
    -   **metric.acceleration.bpFiltEuclNorm** [timeseries] Euclidean norm bandpass filtered between 0.2 and 15 Hz using a 4th order Butterworth filter, averaged in epochs of length `ACT.epoch`
    -   **metric.acceleration.angle_z** [timeseries] angle of the accelerometry device in the z-axis, given by
        -   `atan(z / sqrt(x^2 + y^2)) / (pi/180)`,
        -   where 'x', 'y' and 'z' are median acceleration values obtained in moving windows of length `ACT.epoch`
-   **ACT.analysis** [struct] contains all output from analysis steps
-   **ACT.stats** [struct] contains all output from statistics
-   **ACT.display** [struct] contains all display settings
-   **ACT.etc** [struct] 'etcetera' contains all other non-essential variables
-   **ACT.saved** [bool] indicates whether file is saved or not
-   **ACT.pipe** [cell] keeps track of pipeline stages, 'load', 'preproc', 'analysis' and 'statistics'
-   **ACT.history** [char] stores all steps executed by the user interface as Matlab code to reproduce the exact same data processing

### Functions

-   **package/appFunc** contains all functions that start with `app_`. They construct the graphical user interface by mounting each component or updating its properties upon events and changes in the data.
-   **package/cicadaFunc** contains all stand-alone functions that start with `cic_` and either manipulate the data directly or call sub-functions to do so. This organization is highly similar to the `pop_*` functions in EEGLAB.
-   **package/mountFunc** contains all functions that start with `mount_`, which are used to draw graphical objects such as, `plot()`, `patch()` and `barh()`, or other components such as `uiaxes()` and `uipanel`.
-   **package/supportFunc** contains all other functions that are used by the aforementioned functions.

### Settings files

-   **settings/CicadaSettings.json** specifies the default settings for displaying the data, epoch length, and importing sleep diary data.
-   **settings/\*SleepDiary.json** specifies the format and column number (index) of the date and time used to encode the sleep diary data. Multiple .json files can be specified, loaded, edited and saved in order to import sleep diaries with different formatting.

### Cicada User Inferface Management

The Cicada user interface is comprised of various 'Components', e.g. `uipannel`, `uiaxes`, or `plot` objects (note that the terms 'Component' and 'Object' can be used interchangably, but here I refer to them as Components). Each Component has properties, e.g. `Position`, `XLim`, or `XData`, and their values are dicated by the data in the `ACT` structure. For example, the user can change the analysis window through the Cicada GUI and this will trigger the event function to update the `ACT.startdate` and `ACT.enddate` value. At the end of each event, the `lifecycle()` function is called, which is based on the lifecycle method of [React, a JavaScript library for building user inferfaces](https://reactjs.org). The `lifecycle()` function is comprised of the following sequence of sub-functions:

> ### Again, your help is more than welcome!
>
> If you are familiar with the React lifecycle method, or if you have a more appropriate approach for updating the user interface, and you'd like to contribute please contact me.

-   **mapStateToProps(app)** Maps the current state of the `ACT` data structure to 'mount', i.e. create, Components if they don't exist yet, or to create a copy of the relevant Component properties with updated values. Importantly, these properties are not updated here but later in the lifecycle. This construction of Components is processed by the `app_construct*` functions which contain the sub-functions `shouldComponentMount()`, `mountComponent()` and `constructComponent()` (see below). For optimization purposes, only those Components that are a member of the component-groups in `app.ComponentList` are mapped.
-   **app_construct\*(app, ~)** This set of functions is organized by Component groups. For example, `app_constructDataPanel()` is responsible for constructing all the components in the main panel in the Data Analysis tab. For each of the required Components, the function `shouldComponentMount()` is called, which checks if the Component, identified by its `Tag` property, already exists or not. If not, the Component properties are constructed in a cell array called `props`, and the function `mountComponent()` is called. If the Component exists, the relevant properties are constructed and the function `constructComponent()` is called.
-   **shouldComponentMount(app, Parent, Tag)** Uses the build-in Matlab function `findobj()` to find a Component identified by its unique Tag among the Children of the Parent Component. If the `findobj()` function returns empty, the Component does not exist yet, and should be mounted, otherwise it should be constructed.
-   **mountComponent(app, mountFnc, Parent, Properties)** Uses the build-in Matlab function `eval()` to call the mount function, specified as a string in `mountFnc`. The mounting of Components is processed by the `mount_*` functions which take in the arguments `app`, `Parent`, and `Properties`.
-   **constructComponent(app, Tag, Parent, Properties)** Creates `app.Components` which is a cell array of size N-by-2 where the fist column contains the handle to the Component, and the second column contains the relevant properties and their updated values.
-   **shouldComponentUpdate(app, Component, NewProps)** Once the `app.Components` cell array is constructed for all relevant Component groups, a for-loop runs through all N elements. For each, `shouldComponentUpdate()` checks if the current Component property values are equal to the updated property values in `app.Components`. Only if at least one property is different, the Component is updated by the function `updateComponent()`.
-   **updateComponent(app, Component, NewProps)** Updates the property values of the Component.
-   **unmountComponents(app)** Finally, `unmountComponents()` checks for each Component in the relevant Component groups if the data in the `ACT` structure still requires a particular Component to exist. For example, if the user deletes an event, the graphical Component should be removed as well. The unmounting of Components is processed by `unmountComponent()`.
-   **unmountComponent(app, Component)** Uses the build-in Matlab function `delete()` to unmount a Component.

### Menu items and their call-alone functions

**File > Open Dataset**

```matlab

ACT = cic_loadmat(fullpath);
[ACT, err, msg] = cic_checkDataset(ACT);
ACT = cic_calcEpochedMetrics(ACT, epoch); % Epoch length in seconds
ACT = cic_getDays(ACT, analysisWinStart, analysisWinEnd); % e.g. '15:00', '15:00'

```

**File > Save Dataset (As)**

```matlab

ACT = cic_savemat(ACT, fullpath);

```

**File > Import Data > Import GeneActiv (.bin)**

```matlab

ACT = cic_importGeneActivBin(fullpath);
ACT = cic_calcEpochedMetrics(ACT, epoch); % Epoch length in seconds
ACT = cic_getDays(ACT, analysisWinStart, analysisWinEnd); % e.g. '15:00', '15:00'

```

**File > Import Events > Import Sleep Diary**

```matlab

[ACT, rawSleepDiary] = cic_importSleepDiary(ACT, fullpath); % Path to tabular text file or spreadsheet
[ACT, importSettings, err, msg] = cic_importSleepDiarySettings(ACT, fullpath); % Path to .JSON settings file
[ACT, err, msg] = cic_parseSleepDiary(ACT, rawSleepDiary, importSettings);
ACT = cic_diarySleepEvents(ACT); % Generate events in 'ACT.analysis.events' from sleep diary
ACT = cic_actigraphySleepEvents(ACT); % Genererate sleep period and waso events if annotation is available

```

**File > Export > Statistics**

```matlab

ACT = cic_exportStatistics(ACT, fullpath); % Write the statistics in 'ACT.stats' to .CSV files

```

**File > Export > Report**

```matlab

% Sorry, this part of Cicada has not been developed yet.

```

**File > Export > Matlab Code**

```matlab

ACT = cic_writeHistory(ACT, fullpath); % Write history to .m Matlab script

```

**Edit > Dataset Info**

```matlab

ACT = cic_editInformation(ACT, newInfo); % Structure with any number, name and type of fields

```

**Edit > Select Data**

```matlab

ACT = cic_selectDatasetUsingTime(ACT, startDate, endDate); % Start and end date [datenum] to crop the dataset to
ACT = cic_getDays(ACT, analysisWinStart, analysisWinEnd); % e.g. '15:00', '15:00'

```

**Edit > Change Time Zone**

```matlab

ACT = cic_changeTimeZone(ACT, newTimeZone) % New time zone [string]
ACT = cic_getDays(ACT, analysisWinStart, analysisWinEnd); % e.g. '15:00', '15:00'

```

**Edit > Change Epoch Length**

```matlab

ACT = cic_calcEpochedMetrics(ACT, epoch); % New epoch length in seconds

```

**Preprocess > GGIR Automatic Calibration**

```matlab

ACT = cic_ggirAutomaticCalibration(ACT);
ACT = cic_calcEpochedMetrics(ACT, epoch); % Epoch length in seconds

```

**Preprocess > GGIR Non-Wear Detection**

```matlab

[ACT, err] = cic_ggirDetectNonWear(ACT);

```

**Analysis > Annotate Epochs > GGIR Annotation**

```matlab

ACT = cic_ggirAnnotation(ACT, params); % Parameters used in algorithm [struct]
ACT = cic_actigraphySleepEvents(ACT); % Genererate sleep period and waso events if sleep windows are available

```

**Analysis > Events > Create Daily Events**

```matlab

ACT = cic_createDailyEvent(ACT, onset, duration, label); % Onset [string] in 'HH:MM', duration in hours, label [string]

```

**Analysis > Events > Create Relative Events**

```matlab

ACT = cic_createRelativeEvent(ACT, ...
ref, ... % [string] either 'onset' or 'offset'
refLabel, ... % [string] label of reference events
refType, ... % [string] type of reference events
delay, ... % [double] delay of new events, value can be negative or positive
duration, ... % [double] duration of new events
newLabel); % [string] label of new events

```

**Analysis > Events > GGIR Sleep Detection**

```matlab

ACT = cic_ggirSleepPeriodDetection(ACT);
ACT = cic_actigraphySleepEvents(ACT); % Genererate sleep period and waso events if annotation is available

```

**Statistics > Generate Statistics**

```matlab

ACT = cic_statistics(ACT); % Calculate average, daily and sleep statistics
ACT = cic_statistics(ACT, 'customEvent', eventLabel); % Calculate statistics for custom events

```

Thank you for reading this far! Have a nice day.

Rick
