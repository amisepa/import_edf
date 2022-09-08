
clear; close all; clc
folder = 'C:\Users\IONSLAB\Desktop\import_EDF_bug';
cd(folder)
eeglab; close;
filePaths = dir;
filePaths = {filePaths(3:end).name};

%file 2 (continuous with 1 s cells)
disp(['Importing:  ' char(filePaths(2))])
EEG = import_edf(filePaths(2));
pop_eegplot(EEG,1,1,1);
EEG.srate
s = seconds([EEG.event.latency] / EEG.srate)'

%file 3 (continuous with 1 s cells)
disp(['Importing:  ' char(filePaths(3))])
EEG = import_edf(filePaths(3));
pop_eegplot(EEG,1,1,1);
EEG.srate
s = seconds([EEG.event.latency] / EEG.srate)'

%file 1 (continuous with 2 s cells)
disp(['Importing:  ' char(filePaths(1))])
EEG = import_edf(filePaths(1));
% EEG.data = bsxfun(@minus, EEG.data, mean(EEG.data,2));  %remove mean
pop_eegplot(EEG,1,1,1);
EEG.srate
s = seconds([EEG.event.latency] / EEG.srate)';
s.Format = 'mm:ss'

%file 4 (EDF+C, discontinuous with 2 s cells)
disp(['Importing:  ' char(filePaths(4))])
EEG = import_edf(filePaths(4));
pop_eegplot(EEG,1,1,1);
EEG.srate
s = seconds([EEG.event.latency] / EEG.srate)';
s.Format = 'mm:ss'

%file 7 (discontinuous with 1 s cells)
disp(['Importing:  ' char(filePaths(7))])
EEG = import_edf(filePaths(7));
pop_eegplot(EEG,1,1,1);
EEG.srate
s = seconds([EEG.event.latency] / EEG.srate)'
s.Format = 'mm:ss'

%% Biosig toolbox

EEG = pop_biosig('C:\Users\IONSLAB\Desktop\import_EDF_bug\RKS54.EDF');
