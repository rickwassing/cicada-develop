======
Cicada
======

This repository contains the source files for Cicada, an open source software for analysing actigraphy and data from other wearable devices.

Verion 0.1.2 (beta)
===================

Cicada is still in initial development. **Anything may change at any time and the software should not be considered stable.**

Authors
=======

-   **Rick Wassing**, rick.wassing@sydney.edu.au, Woolcock Institute of Medical Research, The University of Sydney, Australia

Your help is more than welcome!
===============================

I am a neuroscientist, foremost, and not a software developer. Although I have ample experience in Matlab and other coding-languages, and I have coded Cicada to the best of my abilities, it may not be the most efficient way the software could have been written. I would be very grateful for anyone who'd like to contribute to Cicada.

License
=======

|License| This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License_.

.. |License| image:: https://i.creativecommons.org/l/by-sa/4.0/80x15.png
.. _License: http://creativecommons.org/licenses/by-sa/4.0/

Acknowledgments
===============

In building Cicada, I have translated and adopted functionality from other open-source projects.
I would kindly thank:

-   Vincent T. van Hees and colleagues for their pioneering work on GGIR, an R-package to process accelerometry data. `Visit the GGIR CRAN repository`_.
-   Maxim Osipov, Bart Te Lindert, and German Gómez-Herrero for their work on the `Actant Activity Analysis Toolbox`_ and GeneActiv .bin file import functions.

.. _`Visit the GGIR CRAN repository`: https://cran.r-project.org/web/packages/GGIR/index.html
.. _`Actant Activity Analysis Toolbox`: https://github.com/btlindert/actant-1

===============
Getting Started
===============

Dependencies
============

You can download the standalone desktop application which does not require a Matlab license or any other software. However, if you want to contribute or adapt the code, a Matlab license is required.

Usage
=====

Cicada as a standalone application
----------------------------------

Download the application installer from the Cicada GitHub repository, 
- for MS Windows (here) or 
- for MacOS (here). 

[Describe installation process].

Cicada develop source code
--------------------------

- Download the .Zip or clone the Cicada-develop GitHub repository (here). 
- Open Matlab and navigate to the path where the Cicada directory is located (or add the Cicada directory to the Matlab Search Path).
- Call the Cicada application in the Command Window:

.. code-block:: matlab

  >> Cicada