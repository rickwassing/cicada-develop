.. _toc-top:

=================
Table of Contents
=================

.. _toc-overview:

Overview
========
- :ref:`Key Terms <overview-terms-top>`
- :ref:`The Cicada pipeline to process an Actigraphy Dataset <overview-pipeline-top>`
- :ref:`The Cicada interface and how to interact with it <overview-interface-top>`
- :ref:`The Cicada settings files <overview-settings-files-top>`
- :ref:`The Cicada package and structure of its code <overview-package-top>`
- :ref:`The 'ACT' data structure <index-cicada>`

.. _toc-file:

Importing, loading, saving, and exporting
=========================================
- :ref:`Importing an actigraphy recording <file-import-actigraphy-top>`
- :ref:`Saving and loading a Dataset <file-save-open-dataset-top>`
- :ref:`Importing data from other wearable devices <file-import-other-data-top>`
- :ref:`Importing a sleep diary <file-import-sleep-diary-top>`
- :ref:`Exporting statistics <link>`
- :ref:`Exporting a report (future release) <link>`
- :ref:`Exporting Matlab code <link>`

.. _toc-edit:

Edit the Dataset
================
- :ref:`Edit dataset information <link>`
- :ref:`Select part of the recording <link>`
- :ref:`Change time zone <link>`
- :ref:`Change epoch length <link>`

.. _toc-preproc:

Preprocess the Dataset
======================
- :ref:`Automatic calibration of acceleration data using GGIR <link>`
- :ref:`Automatic detection of 'non-wear' time segments in acceleration data <link>`

.. _toc-analysis:

Analyse the Dataset (Annotation and Events)
===========================================

The data can be analysed in two ways. First, you can annotate each epoch of the data. Here, each epoch is assigned a label according to some thresholding method. Secondly, you can define events, which are time segments of the data identified by a label, an onset and duration. When calculating statistics, these annotation and event labels are used to select those epochs for calculating e.g. average acceleration and time spend in those epochs.

Annotation
----------
- :ref:`Annotate acceleration data into ordinal activity levels using GGIR <link>`
- :ref:`Annotate light data into ordinal exposure levels <link>`

Events
------
- :ref:`Use the mouse cursor to create new events <link>`
- :ref:`Define Sleep Windows, explain SW type, and overlap <link>`
- :ref:`Create repeated daily events given a time of day and duration <link>`
- :ref:`Create events that are relative to the onset or offset of other events <link>`
- :ref:`Create 'sleep window' events using GGIR's automatic sleep period detection <link>`

.. _toc-stats:

Calculating Statistics
======================
- :ref:`Calculate statistics <link>`

.. _toc-window:

The Window Menu
===============
- :ref:`Why and when we need to reposition the panels, issue #3 <link>`