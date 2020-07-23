.. _overview-method-top:

=========
Key Terms
=========

- **Wearable devices** are electronic devices that are worn close to and/or on the surface of the skin, where they detect (and sometimes analyse) information concerning body signals (wrist-acceleration, temperature, body position, heart rate, breathing rate, blood pressure, oxymetry) and/or ambient data (light exposure, temperature).
- **Dataset**. A comprehensive collection of various types of data that pertain to a single recording. This includes, but is not limited to, the raw data from e.g. the accelerometer, the derived metrics, statistics and information about the recording. Cicada uses the Matlab class ``struct`` to store the dataset.
- **(Raw) data**. The collection of data that are downloaded from the wearable devices. In most instances, this is raw data, e.g. acceleration in x, y, and z directions from an actiwatch, but it can also be analysed data, e.g. instantaneous heart rate from a wearable ECG device.
- **Sampling rate**. The number of datapoints per unit of time.
- **Epoch**. The length of a timesegment in seconds over which data is synchronized.
- **Epoched metrics**. In order to properly analyse the data from various different types of wearable devices, Cicada needs to synchronize their timeseries that have a common epoch length. In addition, the same raw data can be transformed into various metrics. For example, the acceleration in 'x', 'y', and 'z' directions are used to compute the 'Euclidean Norm' metric, but also to compute the 'Angle' metric.
    - **Euclidean Norm**. The length of the 3-dimensional vector ``[x, y, z]`` given by ``sqrt(x^2 + y^2 + z^2)``, where ``x``, ``y`` and ``z`` are the instantaneous acceleration in g's (9.81 m/s^2).
    - **Angle**. The angle of the accelerometer with respect to the 'z' axis, given by ``atan(z/ sqrt(x^2 + y^2)) / (pi/180)``, where ``x``, ``y`` and ``z`` are median acceleration values in g's (9.81 m/s^2) in moving windows of length ``epoch``.
    - **Counts**. Derived activity counts in arbitrary units from the accelerometry data according to B.H. Te Lindert et al. (2013) Sleep (DOI: 10.5665/sleep.2648).
    - Other derived epoched metrics are simply down- or upsampled values for each epoch in the data.
- **Annotation**. The assignment of a categorical or ordinal value to each epoch of a particular data type based on a thresholding method, e.g. 'low', 'light', 'moderate' and 'vigorous' activity levels for acceleration metrics, or 'dim', 'moderate' and 'bright' exposure levels for light metrics.
- **Events**. Segments that are defined by an onset and duration and identified by a unique label. In addition, the event type identifies the origin of the event, e.g. ``manual`` for user-defined events, or ``GGIR`` for events created by GGIR algorithms.
    - **Reject event**. An event that identifies a segment that should be disregarded in calculating statistics, e.g. time periods where a devices was not worn.
    - **Button events**. An event triggered by a button press on any of the wearable devices by the research participant. Button events have no duration.
    - **Sleep window event**. A time period in which the research participant is in bed (in-bed until rise-time), or a time period in which the research participant *intends* to sleep (lights out until lights on, or eyes closed until eyes open).

        .. note::

            It is virtually impossible to distinguish between 'in-bed' periods and 'intend-to-sleep' periods if the only information available to the researcher is actigraphy. However, when sleep window events are determined by a sleep diary, it is the researchers' choice to define the sleep window as the period in which the research participant reported to be in bed, or the period the participant reported to have the intention to sleep.

    - **Sleep period events**. A time period in which the research participant is asleep, excluding 'wake-after-sleep-onset' events (sleep onset until final awakening).
    - **WASO events**. Short for 'wake after sleep onset'. WASO events are defined as segments during the sleep period in which the acceleration annotation is not 'sustained inactive' (type is ``actigraphy``) or as segments the participant reported to be awake during the night (type is ``sleepDiary``).
    - **Custom events**. Events that are defined by the user.

- **Statistics**. Any variable of interest that is calculated across the entire recording, per day in the recording, per sleep window, or for each unique label in custom events.

Advanced terms
==============

**The next set of terms are not necessary to understand if you just want to use Cicada, but they are useful for anyone who would like to contribute to the code.**

- **Component**. Any Matlab object, e.g. ``ax`` and ``parent`` are components in the line ``ax = uiaxes(parent)``.
- **Property**. Any field of the Component, e.g. ``XLim`` is a property of the UIAxes ``ax``, and can be accessed using the dot-notation ``ax.Position``.
- **Trigger**. Any user interaction with the user interface, e.g. a mouse click or key-stroke.
- **State**. The complete set of values in the dataset.
- **Lifecycle**. The main function that is called after a trigger, which is responsible for calling the sequence of functions to update any relevant Property based on the State.
- **Mount**. The initial creation of a Component.
- **Construct**. The act of mapping the current State to the relevant Properies of a Component.
- **Update (a Component)**. The act of setting the updated Property values of a Component.