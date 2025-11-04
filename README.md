# import_edf()

Imports European Data Formatted (EDF) data and converts it to the EEGLAB format, including sample rate, timestamps, electrode labels and coordinates, event markers, etc. 

Compatible with EDF-/EDF+/EDF+C/EDF+D data formats. 

Detects unstable sampling rate, among other signal deficiencies, and reports errors. 


## Requirements

- MATLABR2020b or later
- EEGLAB
- MATLAB's Signal Processing Toolbox for the edfread function


## Installation

- Git: Navigate to the local eeglab folder on your computer via your terminal > type `git clone https://github.com/amisepa/import_edf.git` > Launch MATLAB and EEGLAB and you are ready to go!

- Download the repository from the home page > Unzip > Move the folder into your local EEGLAB folder, in the plugins subfolder > Launch MATLAB and EEGLAB and you are good to go!

<img width="1322" height="426" alt="Screenshot 2025-11-04 at 11 19 19 AM" src="https://github.com/user-attachments/assets/df45e83e-a854-417a-9d0d-c93e217e1075" />


GUI mode: 

![](https://github.com/amisepa/import_edf/blob/main/plugin_illustration.png)



Command line usage:

   `eeglab; close;`
   
   `EEG = import_edf;            % import EDF file with pop-up window mode to select the file`
   
   or 
   
   `EEG = import_edf('path to your file');            % import with full file path provided (char string)`

   




## Some additional ressources

Kemp, Bob, Alpo Värri, Agostinho C. Rosa, Kim D. Nielsen, and John Gade. “A Simple Format for Exchange of Digitized Polygraphic Recordings.” Electroencephalography and Clinical Neurophysiology 82, no. 5 (May 1992): 391–93. https://doi.org/10.1016/0013-4694(92)90009-7.

Kemp, Bob, and Jesus Olivan. "European Data Format 'plus' (EDF+), an EDF Alike Standard Format for the Exchange of Physiological Data." Clinical Neurophysiology 114, no. 9 (2003): 1755–1761. https://doi.org/10.1016/S1388-2457(03)00123-8.

On the EDF data format: https://www.edfplus.info/index.html

Copyright (C) 2021 Cedric Cannard
