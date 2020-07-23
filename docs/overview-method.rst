.. _overview-method-top:

=================
The Cicada Method
=================

**This page outlines the main ways in which the data is processed and analysed. More detailed descriptions of each of these steps are linked in the respective sections.**

Why do we need Cicada?
======================

Indeed, a good question, because there are already a few good packages available that can process and analyse actigraphy data (`GGIR`_ for instance). However, there is currently---to my knowledge---no graphical user interfaces (GUIs) available to do so. Secondly, most packages are focussed on analysing data from one wearable device, while in some research, multiple wearable devices are used simultaneously. Cicada solves both issues by providing a (hopefully intuitive) way of visualizing and analysing data from various wearable devices.

.. _`GGIR`: https://cran.r-project.org/web/packages/GGIR/index.html

The general procedures
======================

Importing an actigraphy recording
---------------------------------

While Cicada can process data from various wearable devices, it requires an actigraphy recording as the basis of it all. So, the first thing we need to do is import an actigraphy recording. *For advanced users, the* :abbr:`raw data (The collection of data that are downloaded from the wearable devices` *is stored in a variable of class* ``timeseries``.

.. note::

    The only actigraph that is currently supported in Cicada is the 'ActivInsight GeneActiv'. This is because I only had access to data from this device. Please, if you have raw data from another actigraph, send me a de-identified copy so I can implement an import function for that device. Most appreciated.

**To import an actigraphy recording,**

- click ``File`` > ``Import Actigraphy`` > and select your device type of choice.

:ref:`Read more... <index-top>`.

Importing Data from other wearable devices
------------------------------------------

The start and end date of the **actigraphy recording** is used to crop the imported recording of any other wearable device. In other words, the actigraphy recording is leading. *For advanced users, the (raw) data is stored as a* ``timeseries`` *variable in its original form, i.e. sampling rate, which can be different from the actigraphy recording*.

.. note::

    The only other wearable device that is currently supported in Cicada is an custom-built spectrometer. Again, please send me a de-identified copy of raw data from another device so I can implement an import function. Most appreciated.

**To import Data from a wearable device (other than actigraphy),**

- click ``File`` > ``Import Other Data`` > and select your device type of choice.

:ref:`Read more... <index-top>`.

Now the Cicada gets buzzing
---------------------------

Every time you import Data, the Cicada then calculates predefined Metrics in common Epochs. This accomplishes two things. First, often the raw Data cannot be readily interpreted, e.g. accelaration values in 3-dimensions, or a raw ECG trace don't mean much, it is the Euclidean Norm or the heart-rate that is meaningful. Secondly, Cicada calculates these Metrics in a common timeframe which is dictated by the Epoch length. These various timeseries can then be synchronised and analysed together and the whole is larger than the sum of its parts. What a beauty.

Saving and loading a Dataset
----------------------------

Once an actigraphy recording is imported, it is stored in a Dataset called ``ACT``. *For advanced users, this is a variable of class* ``struct`` *and contains the fields listed in the section* :ref:`the 'ACT' data structure <index-cicada>`. 

**To save (or save-as) the Dataset,**

- click ``File`` > ``Save Dataset (As)``.

**To load an existing Dataset,**

- click ``File`` > ``Load Dataset``.

Editing the Dataset
-------------------

Before we start analysing the Dataset, you may want to edit a few variables in the Dataset or change the recording.

**To edit any information about the study, participant or recording,**

- click ``Edit`` > ``Dataset Info``.

Sometimes, the actigraph starts the recording as soon as it is configured and is then send by post to the participant and back to the institute. In such situations, you may want to select only that part of the recording where the participant actually wore the device.

**To select a part of the Dataset given some start and end date and time,**

- click ``Edit`` > ``Select Data``.

Often, the clock of the actigraph is synchronized with the clock of the computer that configured the device. In some cases, if the computer time is wrong, the recording may be in the wrong time zone. Alternatively, if the recording includes a shift in time due to e.g. daylight-saving regulations or travel, you can select the appropriate part of the data and change the time zone.

**To change the time zone,**

- click ``Edit`` > ``Change Time Zone``.

The default Epoch length that is used to calculate Metrics in a common timeframe is 5 seconds, which is suitable for most use-cases. However, you may have data that could require a different Epoch length.

**To change the Epoch length,**

- click ``Edit`` > ``Change Epoch Length``.

Viewing the various acceleration Metrics
----------------------------------------

The Euclidean Norm is the default Metric to view the acceleration data.