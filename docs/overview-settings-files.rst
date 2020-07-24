.. _overview-settings-files-top:

=========================
The Cicada Settings Files
=========================

Each time Cicada starts, it loads the settings file in ``./settings/CicadaSettings.json``, which specifies default values. It is stored in JavaScript Object Notation (JSON), which may sound quite something, but is actually quite easy read and write for both humans and computers. Basically, is is a collection of 'name' and 'value' pairs. 

Default Import Settings
=======================

Some Raw Data that can be imported into Cicada require some guidance on how Cicada should read the file that contains the Raw Data. For instance, a sleep diary can have many different formats, and Cicada is not smart enought to know all of them by heart. The individual import settings are stored in separate JSON settings files (see below). The location of the file **that should be used by default** is stored in the main Cicada Settings file in an 'object' called 'importSettings'. 

.. code-block:: json

    "importSettings": {}

The location of the default import settings files are stored as 'name' and 'value' pairs. In the example below, Cicada will use the import settings in ``mySleepDiary.json`` to import a sleep diary.

.. code-block:: json

    "importSettings": {
        "sleepDiary": "./Cicada/settings/mySleepDiary.json"
    }

.. note::

    Currently, Cicada can only import Raw Data from ActivInsights GeneActiv .bin files, custom-build spectrometer output in .csv files, and sleep diaries in any tabular text file (.txt, .csv) or spreadsheet (.xls, .xlsx). From this list, Cicada only needs guidance for importing sleep diaries. The list of import settings files will grow as we develop more import functions.

Default Display Settings
========================

The way Cicada displays the accelerometry Metrics can be changed within the Settings Panel, but instead of changing these settings each time, you can specify their default values in the 'object' called 'display'.

In the example below, 

- the actogram start and end clock are set to ``15:00``, 
- the actogram with is a ``single`` day, 
- the number of panels shown in one view without scrolling is ``7``, 
- the relative height (rowspan) of the acceleration Metric axes is ``2``, 
- the accleration data is ``not`` shown on a logarithmic scale, 
- the range is ``0`` to ``1``, 
- the default view is ``euclNorm``. 
- In case you select ``Counts`` as the metric to display, 

    - its range is ``0`` to ``1000`` and is ``not`` shown on a logarithmic scale. 

- In case you select ``euclNorm`` as the metric to display, 

    - its range is ``0`` to ``1`` g and is ``not`` shown on a logarithmic scale. 

- In case you select ``angle`` as the metric to display, 

    - its range is ``-120`` to ``120`` degrees and is ``not`` shown on a logarithmic scale.

.. code-block:: json

    "display": {
            "actogramStartClock": "15:00",
            "actogramEndClock": "15:00",
            "actogramWidth": "single",
            "actogramLength": 7,
            "acceleration": {
                "rowspan": 2,
                "log": 0,
                "range": [0, 1],
                "view": "euclNorm",
                "counts": {
                    "log": 0,
                    "range": [0, 1000]
                },
                "euclNorm": {
                    "log": 0,
                    "range": [0, 1]
                },
                "angle": {
                    "log": 0,
                    "range": [-120, 120]
                }
            }
        }

Default Epoch Length
====================

The only default value that is currently specified in the Cicada Settings file is the Epoch length. In this example Cicada will use a ``5`` second Epoch length.

.. code-block:: json

	"analysis": {
		"epochLength": 5
	}

But here is more you say?
^^^^^^^^^^^^^^^^^^^^^^^^^

Don't worry about the default ``XTickSize``. It's just one of those quirks.


=================================
Sleep Diary Import Settings Files
=================================

.. note::

    This section outlines in detail how the sleep diary import settings are defined. However, when you import a sleep diary in Cicada, you can load, edit and save the import settings to .json files automatically.

Cicada can import 7 predefined variables from a sleep diary, 

1. ``date`` [datestring]
2. ``lightsOut``[datestring]
3. ``sleepLatency``in minutes [integer]
4. ``awakenings``, [integer]
5. ``waso`` in minutes [integer]
6. ``finAwake`` [datestring]
7. ``lightsOn`` [datestring]

.. note::

    - The Sleep Window Events are defined as ``lightsOut`` to ``lightsOn``.
    - The Sleep Period Events are defined as ``lightsOut`` + ``sleepLatency`` to ``finAwake``.
    - The WASO Events are defined by the combination of ``awakenings`` and ``waso``, such that each of the *N* = ``awakenings``, WASO Events have a duration of ``waso`` / ``awakenings`` minutes.

As described above, the different import settings that guide Cicada in the way Raw Data files should be imported are stored in separate JSON files. The import settings file that Cicada should use by default is stored in the Cicada Settings file. This way, the user can define multiple import settings files, for instance for the various types of sleep diaries the research group may use. 

Let's assume we have a tabular Raw Data file that contains the following column headers and data formatting,

1. **Date**, specified as dd/mm/yy, e.g. '16/05/20'
2. **Notes**, specified as text, e.g. 'Watched TV in bed'
3. **Bed time**, specified as 'HH:MM' 24h clock time, e.g. '22:30'
4. **Eyes closed**, specified as 'HH:MM' 24h clock time, e.g. '22:45'
5. **Sleep onset latency**, specified in minutes
6. **Final awakening**, specified as 'HH:MM' 24h clock time, e.g. '7:30'
7. **Eyes open**, specified as 'HH:MM' 24h clock time, e.g. '7:45'
8. **Rise time**, specified as 'HH:MM' 24h clock time, e.g. '8:00'
9. **Sleep quality**, specified as ordinal values between 1-5

The sleep diary import settings file must specify how the Raw Data maps to the expected 7 predefined variables. In the example below, you can see how the format in which the Raw Data is stored is specfied in ``"format": {}``, and how the available columns in the Raw Data is mapped to the 7 variables in ``"idx": {}``. Here you can see that the researcher decided to use 'bed time' and 'rise time' to define the Sleep Windows (``lightsOut`` and ``lightsOn`` are column 3 and 8 respectively). Also, you can see that the Raw Data did not contain any information about the number of awakenings or WASO (their value is ``null``).

.. code-block:: json

    {
        "format": {
            "date": "dd/mm/yy",
            "lightsOut": "HH:MM",
            "finAwake": "HH:MM",
            "lightsOn": "HH:MM"
        },
        "idx": {
            "date": 1,
            "lightsOut": 3,
            "sleepLatency": 5,
            "awakenings": null,
            "waso": null,
            "finAwake": 6,
            "lightsOn": 8
        }
    }

.. warning::

    The ``date``, ``lightsOut``, and ``lightsOn`` variables are required, i.e. you cannot import a sleep diary if this information is not available.