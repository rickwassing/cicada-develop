.. _preproc-non-wear-detection-top:

===================================================
Automatic Detection of Non-Wear Segments Using GGIR
===================================================

Cicada has implemented an algorithm adapted from the GGIR package to automatically detect non-wear segments.

.. note::

    **Reference:** Van Hees VT, Gorzelniak L, et al. Separating movement and gravity components in an acceleration signal and implications for the assessment of human daily physical activity. PLoS One. 2013 Apr 23;8(4) e61691.

The algorithm uses a 60 minute window that slides across the data in steps of 15 minutes. For each iteration, a window is marked as 'non-wear' if the standard deviation AND the range of the raw acceleration data is less than their respective thresholds for at least two out of the three directions ('x', 'y', and 'z').

**To automatically detect non-wear segments,**

- click ``Preprocess`` > ``GGIR Non-Wear Detection``.