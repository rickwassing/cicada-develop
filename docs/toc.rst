.. _toc-top:

=================
Table of Contents
=================

.. _toc-overview:

Overview
========
- :ref:`The Cicada method<overview-method-top>`
    - defines key terms and outlines the ways in which the data is processed and analysed
- :ref:`The Cicada interface <overview-interface-top>`
    - explains the Cicada user-interface and how to interact with it
- :ref:`The Cicada package <overview-package-top>`
    - describes how the code is structured in the 'package' directory
- :ref:`The Cicada settings files <index-cicada>`
    - shows how the Cicada .json settings files are used and what information is stored in these settings files
- :ref:`The 'ACT' data structure <index-cicada>`
    - explains how the dataset is structured in the 'ACT' data structure

.. _toc-file:

The File Menu
=============
- :ref:`Importing an accelerometry recording<link>`
- :ref:`Saving and loading a workspace<link>`
- :ref:`Importing data from other wearable devices<link>`
- :ref:`Importing a sleep diary<link>`
- :ref:`Exporting statistics<link>`
- :ref:`Exporting a report (future release)<link>`
- :ref:`Exporting Matlab code<link>`

.. _toc-edit:

The Edit Menu
=============
- :ref:`Edit dataset information<link>`
- :ref:`Select part of the recording<link>`
- :ref:`Change time zone<link>`
- :ref:`Change epoch length<link>`

.. _toc-preproc:

The Preprocess Menu
===================
- :ref:`Automatic calibration of acceleration data using GGIR<link>`
- :ref:`Automatic detection of 'non-wear' time segments in acceleration data<link>`

.. _toc-analysis:

The Analysis Menu
=================

The data can be analysed in two ways. First, you can annotate each epoch of the data. Here, each epoch is assigned a label according to some thresholding method. Secondly, you can define events, which are time segments of the data identified by a label, an onset and duration. When calculating statistics, these annotation and event labels are used to select those epochs for calculating e.g. average acceleration and time spend in those epochs.

Annotation
----------
- :ref:`Annotate acceleration data into ordinal activity levels using GGIR<link>`
- :ref:`Annotate light data into ordinal exposure levels<link>`

Events
------
- :ref:`Use the mouse cursor to create new events<link>`
- :ref:`Create repeated daily events given a time of day and duration<link>`
- :ref:`Create events that are relative to the onset or offset of other events<link>`
- :ref:`Create 'sleep window' events using GGIR's automatic sleep period detection<link>`

.. _toc-stats:

The Statistics Menu
===================
- :ref:`Generate output statistics<link>`

.. _toc-window:

The Window Menu
===============
- :ref:`Why and when we need to reposition the panels, issue #3<link>`