.. _index-top:

.. figure:: docs/images/index-cicada-logo.png
  :width: 125px
  :align: center

======
Cicada
======

Cicada is an open source software for analyzing actigraphy and data from other wearable devices.

.. _index-version:

Version 0.10.7 (beta)
---------------------

.. warning::

  Cicada is still in development and currently ONLY works in Matlab R2019b. Anything may change at any time and the software should not be considered stable.

.. _index-authors:

Authors
-------

-   **Rick Wassing**, rick.wassing@sydney.edu.au, Woolcock Institute of Medical Research, The University of Sydney, Australia

.. _index-help:

Your help is more than welcome!
-------------------------------

I am a neuroscientist, foremost, and not a professional software developer. Although I have ample experience in Matlab and other coding-languages, and I have coded Cicada to the best of my abilities, it could still be improved with your help. I would be very grateful for anyone who'd like to contribute to Cicada.

.. _index-license:

License
-------

|License| This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License_.

.. |License| image:: https://i.creativecommons.org/l/by-sa/4.0/80x15.png
.. _License: http://creativecommons.org/licenses/by-sa/4.0/

.. _index-acknowledgments:

Acknowledgments
---------------

In building Cicada, I have translated and adopted functionality from other open-source projects.
I would kindly thank:

-   Vincent T. van Hees and colleagues for their pioneering work on GGIR, an R-package to process actigraphy data. `Visit the GGIR CRAN repository`_.
-   Maxim Osipov, Bart Te Lindert, and German Gómez-Herrero for their work on the `Actant Activity Analysis Toolbox`_ and GeneActiv .bin file import functions.

.. _`Visit the GGIR CRAN repository`: https://cran.r-project.org/web/packages/GGIR/index.html
.. _`Actant Activity Analysis Toolbox`: https://github.com/btlindert/actant-1

.. _index-gettingStarted:

===============
Getting Started
===============

.. _index-dependencies:

Dependencies
------------

The standalone desktop application does not require a paid Matlab license or any other software.

.. toctree::
  :maxdepth: 1
  :caption: Run Cicada standalone

  docs/installation-standalone-macos.rst
  docs/installation-standalone-mswin.rst

Run Cicada in Matlab
--------------------

1. You're required to have Matlab R2019b.
2. Download the code  `as a .zip file <https://github.com/rickwassing/cicada-develop/archive/master.zip>`_ or `clone the Cicada-develop GitHub repository <https://github.com/rickwassing/cicada-develop>`_. 
3. Open Matlab and navigate to the path where the Cicada directory is located (or add the Cicada directory to the Matlab Search Path).
4. Call the Cicada application in the Command Window:

.. code-block:: matlab

  >> cicada

**To get started, follow the instruction in the Overview section**

.. toctree::
  :maxdepth: 2
  :caption: Overview

  docs/overview-terms.rst
  docs/overview-interface.rst
  docs/overview-pipeline.rst
  docs/overview-settings-files.rst
  docs/overview-act-structure.rst
  docs/overview-package.rst
  
.. figure:: https://www.fortnightly.com/sites/default/files/FEA2-Extra.jpg
    :width: 95px
    :align: center

**Want more?** Read all about it in the specialized sections listed below or in the side menu.

.. toctree::
  :maxdepth: 2
  :caption: Import, open, save, export

  docs/file-import-actigraphy.rst
  docs/file-save-open-dataset.rst
  docs/file-import-other-data.rst
  docs/file-import-sleep-diary.rst

.. toctree::
  :maxdepth: 2
  :caption: Edit the Dataset

  docs/edit-dataset-info.rst
  docs/edit-select-data.rst
  docs/edit-change-time-zone.rst
  docs/edit-change-epoch-length.rst

.. toctree::
  :maxdepth: 2
  :caption: Preprocess the Dataset

  docs/preproc-calibration.rst
  docs/preproc-non-wear-detection.rst

.. toctree::
  :maxdepth: 2
  :caption: Analyse the Dataset

  docs/analysis-annotate-acceleration-ggir.rst
  docs/analysis-annotate-light.rst
  docs/analysis-sleep.rst
  docs/analysis-daily-events.rst
  docs/analysis-relative-events.rst

.. toctree::
  :maxdepth: 2
  :caption: Generate, Export Statistics

  docs/statistics.rst
