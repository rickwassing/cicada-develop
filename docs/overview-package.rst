.. _overview-package-top:

=======================
The 'Package' Directory
=======================

- **package/appFunc** contains all functions that start with ``app_``. They construct the graphical user interface by mounting each component or updating its properties upon events and changes in the data.
- **package/cicadaFunc** contains all stand-alone functions that start with ``cic_`` and either manipulate the data directly or call sub-functions to do so.
- **package/mountFunc** contains all functions that start with ``mount_``, which are used to draw graphical objects such as, ``plot()``, ``patch()`` and ``barh()``, or other components such as ``uiaxes()`` and ``uipanel``.
- **package/supportFunc** contains all other functions that are used by the aforementioned functions.
- **package/guis** contains all graphical user interfaces that are called from the menu bar.
- **package/images** contains all images and colormaps.