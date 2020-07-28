.. _preproc-calibration-top:

=====================================================
Automatic Calibration of Acceleration Data Using GGIR
=====================================================

Cicada has implemented an algorithm adapted from the GGIR package to automatically calibrate acceleration data.

.. note::

    **Reference:** Van Hees VT, Fang Z, et al. Auto-calibration of accelerometer data for free-living physical activity assessment using local gravity and temperature: an evaluation on four continents. J Appl Physiol 2014.

First, the algorithm aims to find data segments where there is (almost) no change in movement, i.e. where the standard deviation in the ``x``, ``y``, and ``z`` component of acceleration is less than ``sdCriterion = 0.013``. Then, the algorithm assumes that the mean acceleration for these stationary segments must be 1 g. Finaly, the algorithm iteratively finds the new ``offset`` and ``gain`` factors for each acceleration direction such that its deviation from 1 g is minimized.

Please refer to the section 'Autocalibration method' with the methods section of the reference paper above for full details on this algorithm.

**To autocalibrate the acceleration data using GGIR,**

- click ``Preprocess`` > ``GGIR Automatic Calibration``.

.. figure:: images/edit-change-epoch-length-1.png
    :width: 232px
    :align: center

    Scroll throught the list of 'New Epoch Lengths' and select the appropriate one. Click 'Change', or 'Cancel' to abort.