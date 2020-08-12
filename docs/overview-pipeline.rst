.. _overview-pipeline-top:

===================
The Cicada Pipeline
===================

**This page outlines the main ways in which the data is processed and analysed. More detailed descriptions of each of these steps are linked in the respective sections.**

**If, at any point, you wonder what I mean with certain terms, check the** :ref:`glossary <overview-terms-top>`.

Why Do We Need Cicada?
======================

Indeed, a good question, because there are already a few good packages available that can process and analyse Actigraphy data (`GGIR`_ for instance). However, there is currently---to my knowledge---no graphical user interfaces (GUIs) available to do so. Secondly, most packages are focussed on analyzing data from one wearable device, while in some research, multiple wearable devices are used simultaneously. Cicada aims to solve both issues by providing a (hopefully intuitive) way of visualizing and analyzing data from various wearable devices.

.. _`GGIR`: https://cran.r-project.org/web/packages/GGIR/index.html

The General Procedures
======================

Importing an Actigraphy recording
---------------------------------

While Cicada can process Raw Data from various wearable devices, it requires an Actigraphy recording as the basis of it all. So, the first thing we need to do is import an Actigraphy recording. *For advanced users, the Raw Data are stored as variables of class* ``timeseries``.

.. note::

    The only Actigraph that is currently supported in Cicada is the 'ActivInsight GeneActiv'. This is because I only had access to data from this device. Please, if you have raw data from another Actigraph, send me a de-identified copy so I can implement an import function for that device. Most appreciated.

.. warning::

    There is currently a bug in Matlab on MacOS where any dialog box to select files and folders appears *behind* the Cicada window. Simply click anywhere in the Cicada window to show the dialogue box. This issue is listed as issue #5 on the Cicada-develop GitHub repository. 

**To import an Actigraphy recording,**

- click ``File`` > ``Import Actigraphy`` > and select your device type of choice.

:ref:`Read more... <file-import-actigraphy-top>`

Importing Data from other Wearable Devices
------------------------------------------

The start and end date of the **Actigraphy recording** is used to crop the imported recording of any other Wearable Device. In other words, the Actigraphy recording is leading. *For advanced users, the Raw Data from other Wearable Devices are stored as* ``timeseries`` *variables in its original form, i.e. sampling rate, which can be different from the Actigraphy recording*.

.. note::

    The only other wearable device that is currently supported in Cicada is an custom-built spectrometer. Again, please send me a de-identified copy of raw data from another device so I can implement an import function. Most appreciated.

**To import Data from a wearable device (other than Actigraphy),**

- click ``File`` > ``Import Other Data`` > and select your device type of choice.

:ref:`Read more... <file-import-other-data-top>`

Now the Cicada gets buzzing
---------------------------

Every time you import Raw Data, the Cicada then calculates predefined Metrics in common Epochs. This accomplishes two things. First, often the Raw Data cannot be readily interpreted, e.g. Acceleration values in 3D, or a raw ECG trace don't mean much, it is the Euclidean norm or the heart-rate that is meaningful. Secondly, Cicada calculates these Metrics in a common timeframe which is dictated by the Epoch length. These various timeseries can then be synchronized and analysed together.

Saving and loading a Dataset
----------------------------

Once an Actigraphy recording is imported, it is stored in a Dataset called ``ACT``. *For advanced users, this is a variable of class* ``struct`` *and contains the fields listed in the section on* :ref:`the 'ACT' data structure <overview-act-structure-top>`. 

**To save (or save-as) the Dataset,**

- click ``File`` > ``Save Dataset (As)``.

**To load an existing Dataset,**

- click ``File`` > ``Load Dataset``.

:ref:`Read more... <file-save-open-dataset-top>`

Changing the display settings
-----------------------------

It is somewhat subjective, but you may want to change the way the Epoched Metrics are displayed in the data analysis tab. You can change 

1. the relative height of each of the axes, 
2. the number of panels that are shown in one view without scrolling, 
3. the length of the actogram, 
4. the start and end clock times of the analysis window, 
5. the range of the vertical axes, 
6. whether the vertical axes are in linear or logarithmic scale, 
7. to show or hide certain axes or adjust their order, 
8. set the color of the plotted timeseries, and 
9. to show and hide individual timeseries or adjust their order.

:ref:`Read more... <overview-interface-settings-panel>`

Editing the Dataset
-------------------

Before we start analyzing the Dataset, you may want to add, edit or remove a few things in the Dataset. For example, you can specify the study name, the condition and session number, crop the Dataset in time, change the time zone, or specify a different Epoch length.

**To edit any information about the study, participant or recording,**

- click ``Edit`` > ``Dataset Info``.

:ref:`Read more... <edit-dataset-info-top>`

Sometimes, the actigraph recording is started as soon as it is configured, and the device is then send by post to the participant and back to the institute. In such situations, you may want to select only that part of the recording where the participant actually wore the device.

**To select a part of the Dataset given some start and end date and time,**

- click ``Edit`` > ``Select Data``.

:ref:`Read more... <edit-select-data-top>`

Often, the clock of the actigraph is synchronized with the clock of the computer that configured the device. In some cases, if the computer time is wrong, the recording may be in the wrong time zone. Alternatively, if the recording includes a shift in time due to e.g. daylight-saving regulations or travel, you can select the appropriate part of the Dataset and change the time zone.

**To change the time zone,**

- click ``Edit`` > ``Change Time Zone``.

:ref:`Read more... <edit-change-time-zone-top>`

The default Epoch length that is used to calculate Metrics in a common timeframe is 5 seconds, which is suitable for most use-cases. However, your study may use devices that require a different Epoch length.

**To change the Epoch length,**

- click ``Edit`` > ``Change Epoch Length``.

:ref:`Read more... <edit-change-epoch-length-top>`

Viewing the various Acceleration Metrics
----------------------------------------

The Euclidean Norm is the default Metric to displayed in the actogram. However, you can also display the Angle or the Activity Counts. The Angle shows the angle of the Accelerometer with respect to the 'z' direction, and Activity Counts are indirectly derived from the Raw Accelerometry Data to match the traditional actigraphic count recordings obtained using the Actiwatch (used to be Mini Mitter, Respironics Inc., nowadays Philips Healthcare).

**To change the display,**

- click ``View`` > and select your Metric of choice.

.. note::

    It is somewhat subjective, but the Angle may be the best Metric to view when manually creating Sleep Window Events. When we step into bed, we transition from an upright position to a horizontal position and subsequently have very little changes in the angle of the accelerometer (except for when we toss-and-turn). This behavior is most visible by looking at the Angle of the accelerometer.

Preprocessing the Dataset
-------------------------

Ok, so far we have completed the information about the study and the participant, and we have cropped the Dataset to the part that we're interested in. *However, we are still not quite ready to analyse the Metrics*. Next, we need to make sure that the Epoched Metrics are suitable for Analysis. For example, we might need to calibrate the Raw Data and recalculate the Epoched Metrics, or we might need to create Reject Events to indicate which sections of the Epoched Metrics should be disregarded in the Analysis.

**To calibrate the Raw Data,**

- click ``Preprocess`` > ``GGIR Automatic Calibration``.

:ref:`Read more... <preproc-calibration-top>`

.. note::

    For ActivInsight GeneActiv devices, the calibration 'offset' and 'gains' are stored in each device, and these values are used to calibrate the Raw Data when it is imported into Cicada. However, temperature may have an impact on the acceleration sensor chip used in GeneActiv devices, and therefore, you may want to re-calibrate the data.

Reject Events can be defined manually, or Cicada can automatically detect them by using an adaption of GGIR's automatic non-wear detection algorithm (`DOI: 10.1371/journal.pone.0061691 <http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0061691>`_).

**To automatically detect non-wear segments as Reject Events,**

- click ``Preprocess`` > ``GGIR Non-Wear Detection``.

:ref:`Read more... <preproc-non-wear-detection-top>`

**To manually create Reject Events,**

:ref:`follow the instructions in the section on how to create events <overview-interface-create-events>`.

**To edit or delete Reject Events,**

:ref:`follow the instructions in the section on how to edit events <overview-interface-edit-events>`.

Analyzing the Dataset
---------------------

Now we can start to Annotate the Epoched Metrics and create Events. These two types of Analyses will define segments of the Dataset which are selected to calculate Statistics for. 

Annotation
^^^^^^^^^^

Cicada uses an algorithm adapted from GGIR's ``identify_level.R`` function to annotate the Acceleration Metrics. There are 4 different algorithms that work slightly different, but in general the 'activity threshold' (e.g. 0.10 g for 'moderate' activity) is used to identify Epochs in which the Acceleration Metric 'Euclidean Norm' is above 0.10 g. The parameters 'activity time' (e.g. 10 minutes) and 'bout criterion' (e.g. 80%) are then used to only keep those segments in which 80% of the Epochs within a 10 minute window are above 0.10 g. The entire segment is then labelled as 'moderate' activity. This is repeated for all activity levels. Any Epoch that has not met any of the criteria is labelled as 'low' activity. This way, each and every Epoch has an Annotation label.

**To Annotate Acceleration Metrics with GGIR,**

- click ``Analyse`` > ``Annotate Epochs`` > ``Annotate Acceleration (GGIR)``.

:ref:`Read more... <analysis-annotate-acceleration-ggir-top>`

In addition to Annotating Acceleration Metrics, we can Annotate light Metics. Each and every epoch is checked between 2 thresholds, if it is lower than ``100`` lux, it is labeled as ``dim``, if it is between ``100`` and ``1000`` lux, is it labeled as ``moderate``, and if it is greater than or equal to ``1000`` lux, it is labeled ``bright``.

**To Annotate light Metrics,**

- click ``Analyse`` > ``Annotate Epochs`` > ``Annotate Light``.

:ref:`Read more... <analysis-annotate-light-top>`

.. _overview-pipeline-sleep-window-events:

Sleep Window Events
^^^^^^^^^^^^^^^^^^^

An important part of analyzing the Dataset is to define Sleep Window Events. They can be created manually, imported from a sleep diary, or we can define Sleep Window Events by using an algorithm. Please refer to :ref:`the section on sleep analysis <analysis-sleep-top>` for in-depth instructions (highly recommended). Otherwise, use the quick instructions in the following sections to create Sleep Window Events.

**To manually create Sleep Window Events,**

:ref:`follow the instructions in the section on how to create manual events <overview-interface-create-events>`.

**To import a sleep diary,**

:ref:`follow the instructions in the section on importing sleep diaries <file-import-sleep-diary-top>`.

**To create Sleep Window Events using GGIR's sleep detection algorithm,**

- click ``Analyse`` > ``Events`` > ``GGIR Sleep Detection``.

.. note::

    The GGIR sleep detection algorithm is designed to detect Sleep Windows by identifying the largest segment in the *analysis window* in which the median absolute deviation of the angle is below 15 times its 10th percentile. The analysis window is defined by the actogram start and end clock times shown in the settings panel. Cicada uses an empirically derived default analysis window of '15:00' until '15:00' the next day. It is highly unlikely, under normal circumstances, that a Sleep Window begins before 15:00 and ends after 15:00. *However, depending on your sample, e.g. shift-workers, youth or sleep disorders, you may want to adjust this analysis window*.

Custom Events
^^^^^^^^^^^^^

In addition to creating Custom Events manually, which is described in the section on :ref:`creating events <overview-interface-create-events>`, Cicada has two more ways to create Custom Events. In some use-cases, you may want to analyse the same part of the day, for all of the days in the recording. For example, your study might have instructed participants to exercise, every morning between 10:00 am and 11:30 am. To create Statistics for specifically these time segments, we can define 'Daily Events' with the 'onset' at ``10:00``, 'duration' ``1h 30m`` and 'label' ``Morning Exercise``.

**To Create Daily Events,**

- click ``Analyse`` > ``Events`` > ``Create Daily Events``.

:ref:`Read more... <analysis-daily-events-top>`

Secondly, you may want to study segments that are before, during or after existing Events. For example, you may be interested in the activity levels prior to sleep. To calculate Statistics on the 3 hours prior to each Sleep Window Event, we can define 'Relative Events' with the 'reference Event label' ``sleepWindow``, the 'reference Event type' ``actigraphy``, relative to the ``onset``, with a 'delay' of ``-3h 0m``, a 'duration' of ``3h 0m`` and 'label' ``Presleep Activity``.

**To Create Relative Events,**

- click ``Analyse`` > ``Events`` > ``Create Relative Events``.

:ref:`Read more... <analysis-relative-events-top>`

Calculating Statistics
----------------------

Once we're done with Annotating the Dataset and creating all the Events that define segments of interest, we can calculate Statistics. The Statistics are calculated as averages across the entire Dataset, for each day in the Dataset (midnight-to-midnight), for each Sleep Window Event, and for each Custom Event. The Epoch Annotation's are used to calculate the time spent in each level of Annotation, e.g. time spent in 'light' activity, or time with 'bright' light exposure. Not only does Cicada calculate average Metrics for these segments, for some Metrics it will also calculate the clock onset of the maximal and minimal value. 

It is highly recommended to read the a :ref:`comprehensive overview of all Statistics and a description of how they are calculated <statistics-top>`. Otherwise use this quick step, **to generate the Statistics, **

- click ``Statistics`` > ``Generate Statistics``.

Exporting Statistics
--------------------

All Statistics can be exported to comma-separated-value (.CSV) files which can then be used in your favorite statistical analysis software for further (group) analysis.

**To export Statistics,**

- click ``File`` > ``Export`` > ``Statistics``.
- Specify the location and filename to save the Dataset to.
- Click 'Save' to save, or 'Cancel' to abort.

.. note::

    The Statistics are saved as a comma-separated-values (.CSV) files, one for each category of Statistics. The filename you specified using the browse window will be appended with the following name-value pairs. Average Statistics will be saved to ``[fname]_average-all.csv``, ``[fname]_average-week.csv`` and ``[fname]_average-weekend.csv``. Daily Statistics will be saved to ``[fname]_daily.csv``. Sleep Statistics to ``[fname]_sleep-actigraphy.csv`` and ``[fname]_average-sleepdiary.csv`` if available. Custom Statistics to ``[fname]_custom-[customEventLabel].csv``.

Exporting Report
----------------

This part of Cicada is not developed yet, sorry.

Exporting Matlab code
---------------------

Cicada automatically logs all the steps that we have performed within the software as Matlab code in ``ACT.history``. You can export this code to a Matlab '.m' file, which in turn, you can open as a script in the Matlab Editor. First of all, this allows you to exactly reproduce all the steps that we just did within Cicada. Secondly, by adapting the script in some clever ways, you can batch process all your other Actigraphy recordings. So, you can first process 1 Actigraphy recording in Cicada, export the script, adapt the script, and run all other Actigraphy recordings automatically. You probably still need to manually go through all the exported Statistics to make sure all is well and proper. You can then quickly edit those processed Datasets in Cicada that require some manual work.

**To export the Matlab code,**

- click ``File`` > ``Export`` > ``Matlab Code``.
- Specify the location and filename to save the code to.
- Click 'Save' to save, or 'Cancel' to abort.
    
Fantastic, have some cake before you continue
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. figure:: images/cake-is-a-lie.png
    :width: 95px
    :align: left