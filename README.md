# import_edf()

Imports European Data Formatted (EDF) data and converts it to the EEGLAB format

Compatible with EDF-/EDF+/EDF+C/EDF+D data

REQUIREMENTS: This function uses the Matlab's edfread function from Matlab R2020b or later AND the Signal processing toolbox
and is implemented in EEGLAB.

GUI mode: 

![](https://github.com/amisepa/import_edf/blob/main/plugin_illustration.png)

Command line usage:

   eeglab; close; EEG = import_edf;            % import EDF file with pop-up window mode to select the file
   
   or 
   
   EEG = import_edf('path to your file');      % import with full file path provided (char string)

Output: EEG structure in EEGLAB format


References for Matlab's edfRead function:
[1] Kemp, Bob, Alpo Värri, Agostinho C. Rosa, Kim D. Nielsen, and John Gade. “A Simple Format for Exchange of Digitized Polygraphic Recordings.” Electroencephalography and Clinical Neurophysiology 82, no. 5 (May 1992): 391–93. https://doi.org/10.1016/0013-4694(92)90009-7.
[2] Kemp, Bob, and Jesus Olivan. "European Data Format 'plus' (EDF+), an EDF Alike Standard Format for the Exchange of Physiological Data." Clinical Neurophysiology 114, no. 9 (2003): 1755–1761. https://doi.org/10.1016/S1388-2457(03)00123-8.

More on EDF: https://www.edfplus.info/index.html

Copyright (C) 2021 Cedric Cannard, ccannard@protonmail.com
