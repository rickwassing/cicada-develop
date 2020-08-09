.. _statistics-top:

===================
Generate Statistics
===================

**This page provides the complete and in-depth outline of the generated statistics and the way they are calculated.**

We're almost done. So far, the following steps have been completed,

1. imported Raw Data or opened an existing Dataset, 
2. entered all relevant information about the Dataset, 
3. possibly cropped the Dataset and/or change the time zone,
4. preprocessed the Data to recalibrate or to indicate Reject segments,
5. Cicada calculated Metrics in a common timeframe,
6. each and every Epoch was Annotated,
7. Sleep Window Events were created based on manual scoring, a sleep diary or the GGIR algorithm,
8. and possibly created Custom Events (daily or relative) for time segments of interest.

The final step before we can export the results is to generate statistics. Cicada will calculate a predefined set of statistics averaged across the entire recording, for each day, for each Sleep Window, and for each Custom Event.

**To generate Statistics,**

- click ``Statistics`` > ``Generate Statistics``.

The results are shown in the respective Statistics tabs.

Average Stats
-------------

.. figure:: images/statistics-1.png
    :width: 944px
    :align: center

    **The average Statistics tab shows a subset of results averaged across the entire recording.**

In the top-left panel, you can see that the recording spanned across 7 days, that the analysis window is 15:00 to 15:00 the next day, and there are no Rejected segments, i.e. time is 0 minutes.

In the top-right panel, the inter-daily stability and intra-daily variability are shown. Intra-daily variability "quantifies the frequency and extent of transitions between periods of rest and activity" with higher values indicating more frequent or more extensive rest-activity transitions, whereas inter-daily stability "quantifies rhythm's synchronization to zeitgeber's 24h day–night [...] cycle" with higher values indicating stronger synchronization to the 24h rhythm (Gonçalves et al. 2014).

The Euclidean Norm, averaged across all days using a 5h moving window, is shown in the bottom-left panel titled "Average Day Acceleration". The graph shows clear distinction between activity during the night and daytime, with a peak in average activity in the morning. The onset and activity level in the 5h of *most* (M5; dark-red up-triagles) and *least* (L5; blue down-triangles) average activity are shown as well. Furthermore, on an average day, the participant spent 5m in moderate-to-vigorous activity, and at these times the mean activity level was 153 milli-g.

The next two-panels shows a similar graph but now for light and temerature Metrics averaged across all days using a 30m moving window. On the average day, the light exposure was strongest at 9:48 am with 4323 lux, etc.

.. note::

    **Reference:** Gonçalves, Bruno SB, et al. "Nonparametric methods in actigraphy: An update." Sleep Science 7.3 (2014): 158-164.

Average Sleep panel
^^^^^^^^^^^^^^^^^^^

.. figure:: images/statistics-2.png
    :width: 926px
    :align: center

    **If Cicada has access to at least one Sleep Window, the 'Average Sleep' is shown.**

The 'Average Sleep' panel shows all sleep Statistics averaged across all identified Sleep Windows and Sleep Periods of type ``actigraphy``. If Cicada also has access to Sleep Events of type ``sleepDiary``, it will show both sets of sleep Statistics for comparison. This allows inference of discrepancies between subjective and objective sleep Statistics.

In this example, there are 6 Sleep Windows, none of which cross 12:00 pm. Next, the clock diagram shows the average Sleep Window, Sleep Period and WASO events, of both types ``actigraphy`` and ``sleepDiary``. Please recall that the Sleep Windows are shown in purple, and Sleep Periods in blue, but to improve contrast for visualization, the ``sleepDiary`` Sleep Window is shown in orange, and its Sleep Period in teal. Finally, all average sleep Statistics are listed. See below for a description of how these Statistics are calculated.

.. note::

    - If no diary is imported, then Cicada only generates sleep Statistics for ``actigraphy`` sleep Events
    - If no Acceleration Annotation is available, then Cicada cannot define Actigraphy Sleep Period Events, and neither generate the sleep Statistics that depend on this Sleep Period
    - If the diary misses information on the Sleep Period or WASO, then Cicada cannot generate the sleep diary Statistics that depend on these Events, e.g. Sleep Time cannot be calculated without WASO
    - If Sleep Period and/or Sleep Time is available for both types ``actigraphy`` *and* ``sleepDiary``, then a mismatch score is calulated where a positive value indicates overestimation, and a negative value indicates underestimation
    - If at least one of the the Actigraphy Sleep Windows does not overlap with any of the diary Sleep Windows, or if there is a diffent number of Actigraphy and diary Sleep Windows, then Cicada cannot generate comparative average sleep Statistics, and only Actigraphy average sleep Statistics are generated

Daily Stats
-----------

.. figure:: images/statistics-3.png
    :width: 941px
    :align: center

    **The daily Statistics tab shows statistics for each day.**

The Euclidean Norm Metric is shown for each day in the recording on the left in the daily Statistics tab. In addition, the *most* (M5; dark-red up-triagles) and *least* (L5; blue down-triangles) activity periods are indicated along with the time of their onset. Furthermore, moderate-to-vigorous activity segments are indicated with red bars below the data traces. Left-click within the axes on any of the data traces to show all Statistics for that day in the right panel. See below for a description of how these Statistics are calculated.

Sleep Stats
-----------

.. figure:: images/statistics-4.png
    :width: 932px
    :align: center

    **If Cicada has access to at least one Sleep Window, the 'Sleep Stats' tab is shown.**

Sleep Statistics for each Sleep Window is shown in the sleep Statistics tab. The ``actigraphy`` Sleep Windows, Periods and WASO events are shown in the top panel. Next, a detailed overview of all sleep Statistics for each Sleep Window is shown in a separate panel. Again, if Cicada also has access to Sleep Events of type ``sleepDiary``, it will show both sets of sleep Statistics for comparison.

Custom Stats
------------

.. figure:: images/statistics-5.png
    :width: 943px
    :align: center

    **Statistics for each unique Custom Event label.**

For each set of Custom Events with the same label, Cicada calculates the average Acceleration (Euclidean Norm), and average Metrics from other available data types across all Events using 5m moving windows (top panels), which are then used to find the maximum (dark-red up-triagles) and minimum (blue down-triangles) values and their onset relative to the start of the Events (delay). This example shows relative Events referenced to 3h and 30m before the onset of each Sleep Window with a duration of 3h, i.e. 'presleep activity'. Whereas the average Acceleration and temperature does not seem to have a particular trend, the average light Metric shows that, on average, the particant was exposed 93 lux of light about 2h 30m before the onset of the Sleep Window, and to very low levels of light up to 1h 30m before the onset of the Sleep Window. Finally, the bottom panel shows all Statistics for each Custom Event in the set.

===================
Export Statistics
===================

Before showing how to export the Statistics, lets define them first.

Definition of average Statistics
--------------------------------

- **hoursReject**. Total duration of all Reject Events.
- **interDailyStability**. The frequency and extent of transitions between periods of rest and activity.
- **intraDailyVariability**. rhythm's synchronization to zeitgeber's 24h day–night cycle
- **avEuclNorm**. The grand-average of the Euclidean Norm.
- **maxEuclNormMovWin5h**. 
- **clockOnsetMaxEuclNormMovWin5h**.
- **minEuclNormMovWin5h**.
- **clockOnsetMinEuclNormMovWin5h**.
- **hoursModVigAct**.
- **avEuclNormModVigAct**.
- **avLightWidespec**.
- **minLightWidespecMovWin30m**.
- **clockOnsetMinLightWidespecMovWin30m**.
- **maxLightWidespecMovWin30m**.
- **clockOnsetMaxLightWidespecMovWin30m**.
- **avTemperatureWrist**.
- **minTemperatureWristMovWin30m**.
- **clockOnsetMinTemperatureWristMovWin30m**.
- **maxTemperatureWristMovWin30m**.
- **clockOnsetMaxTemperatureWristMovWin30m**.
- **slpCount-**.
- **slpAcrossNoon**.
- **avClockLightsOutAct**.
- **avClockLightsOnAct**.
- **avClockSlpOnsetAct**.
- **avClockFinAwakeAct**.
- **avSlpOnsetLatAct**.
- **avAwakeningAct**.
- **avWakeAfterSlpOnsetAct**.
- **avTotSlpTimeAct**.
- **avSlpPeriodAct**.
- **avSlpWindowAct**.
- **avSlpEffSlpTimeAct**.
- **avSlpEffSlpPeriodAct**.
- **avAwakePerHourAct**.
- **avClockLightsOutDiary**.
- **avClockLightsOnDiary**.
- **avClockSlpOnsetDiary**.
- **avClockFinAwakeDiary**.
- **avSlpOnsetLatDiary**.
- **avAwakeningDiary**.
- **avWakeAfterSlpOnsetDiary**.
- **avTotSlpTimeDiary**.
- **avSlpPeriodDiary**.
- **avSlpWindowDiary**.
- **avSlpEffSlpTimeDiary**.
- **avSlpEffSlpPeriodDiary**.
- **avAwakePerHourDiary**.
- **avSleepTimeMismatch**.
- **avSleepPeriodMismatch**.


- ``Lights Out`` and ``Lights On`` determine the ``Sleep Window``
- ``SOL`` indicates the sleep onset latency and determines sleep onset
- Sleep onset and ``FA`` (Final Awakening) determine the ``Sleep Period``
- ``WASO`` indicates time awake within the ``Sleep Period``
- ``Sleep Time`` (Total Sleep Time) is calculated as ``Sleep Period`` - ``WASO``
- Sleep efficiency ``SE`` is calculated as 100 x ``Sleep Time`` / ``Sleep Window``, and as 100 x ``Sleep Period`` / ``Sleep Window``.