.. _analysis-annotate-acceleration-ggir-top:

================================
Annotate Acceleration Using GGIR
================================

Cicada uses an algorithm adapted from GGIR's ``identify_level.R`` function to annotate the Acceleration Metrics. First, the user has to specify a set of parameters. The 'activity treshold' (e.g. 0.10 g for 'moderate' activity) is used to identify Epochs in which the Acceleration Metric 'Euclidean Norm' is above 0.10 g. The parameters 'activity time' (e.g. 10 minutes) and 'bout criterion' (e.g. 80%) are then used to only keep those segments in which 80% of the Epochs within a 10 minute window are above 0.10 g. The entire segment is then labelled as 'moderate' activity. This is repeated for all activity levels. Any Epoch that has not met any of the criteria is labelled as 'low' activity. This way, each and every Epoch has an Annotation label.

**To Annotate Acceleration Metrics with GGIR,**

- click ``Analyse`` > ``Annotate Epochs`` > ``Annotate Acceleration (GGIR)``.

.. figure:: images/analysis-annotate-acceleration-ggir-1.png
    :width: 368px
    :align: center

    Accelerometry Annotation Using GGIR.

1. Sustained inactivity Epochs are defined as segments of at least ``5`` minutes in length where the consecutive change in the ``Angle`` Metric is less than ``5`` degrees. Adapt these two parameters for more or less stringent criteria.
2. 'Low', 'Light', 'Moderate' and 'Vigorous' activity Epochs are defined as segments of at least ``10`` minutes in length where the ``Euclidean Norm`` Metric is below or above the respective thresholds for at leasts ``80`` % of the segment. The 'Closed Bout' checkbox only applies for 'Bout Metric' ``1`` (see below), if selected then the time spent below the treshold within a segment are included in the segment duration, if unselected, then the time spent below the threshold is not counted towards the duration of the segment.

.. note::

    **Bout Metrics**
    1. The algorithm searches for ``10`` minute segments in which at leasts ``80`` % of the epochs are above the threshold, and assigns that activity-level label to the entire segment.
    2. The algorithm searches for groups of epochs with a total minimum length of ``10`` minutes in which at least ``80`` % of the epochs are above the threshold.