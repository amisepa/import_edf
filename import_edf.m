%% import_edf() - Imports European Data Formatted (EDF) data and
% converts it to the EEGLAB format. Compatible with EDF-/EDF+/EDF+C/EDF+D.
%
% For discontinuous data: automatically merge segments into one continuous
% dataset, and inserts a boundary so that EEGLAB filters automatically
% corrects DF offsets at the boundary.
%
% Usage:
%       eeglab
%       EEG = import_edf;               % pop-up window mode
%       EEG = import_edf(filePath);     % command mode: filePath (cell with character string or character string)
%       EEG = import_edf(filePath, 1);  % 2nd input to remove DC drifts (1) or not (0)
%
% Outputs: 
%       EEG - EEGLAB structure with data, channel labels, sample rate, events, etc.
%       com - character string for command line use of the function
%
% Requirements: Matlab R2020b or later AND the Signal processing toolbox
%
% EDF+ ressource: https://www.edfplus.info/index.html
%
% Copyright (C) - July 2021, Cedric Cannard, ccannard@pm.me
%
% 8.7.2022: fix duplicate seconds (e.g., for edf files with 2 s of data in each cell)
% 9.28.2022: fix matlab version check and added option to remove DC drifts

function [EEG, com] = import_edf(inputname, rmdrift)

% set remove drift off if not set by user
if nargin < 2 || isempty(rmdrift)
    rmdrift = 0;
end

% Check for Matlab version and Signal processing toolbox
% tmp = strfind(version,'R');
matver = char(extractBetween(version, '(R20', ')'));
if str2double(matver(1:2)) < 20  && ~license('test', 'Signal_Toolbox')
    errordlg(['You need Matlab 2020b or later AND the Signal Processing Toolbox to use this function. ' ...
        'You can try to download edfRead here: https://www.mathworks.com/matlabcentral/fileexchange/31900-edfread; ' ...
        'or use EEGLAB''s Biosig toolbox']);
end

% Make sure there isn't another edfread funcion in Matlab path that could
% interfere
% tmp = which('edfread');
% if ~strcmp(tmp(end-30:end-2), 'toolbox\signal\signal\edfread')
%     errordlg('You have another edfread function on your computer that may cause errors. Please delete or remove its path.')
% end
searchPaths = strsplit(matlabpath, pathsep); % MATLAB search path
allInstances = {}; 
for i = 1:length(searchPaths)
    currentPath = searchPaths{i};
    possibleFile = fullfile(currentPath, 'edfread.m');
    if exist(possibleFile, 'file') == 2
        allInstances{end + 1} = possibleFile;
    end
end
nPaths = length(allInstances);
if nPaths > 1
    tmp = regexp(fileparts(allInstances),filesep,'split');
    folder = cell(nPaths,1);
    for i = 1:nPaths
        folder(i) = tmp{i}(end);
    end
    toremove = allInstances(~strcmp(folder,'signal'));
    % errordlg('Another edfread function was detected in your MATLAB path and will likely interfere with import_edf. Please remove the path to: %s',toremove{:})
    error('Another edfread function was detected in your MATLAB path and will likely interfere with import_edf. Please remove the path to: %s',toremove{:})
end

% Initialize EEGLAB structure
EEG = eeg_emptyset;

% Filename and path
if nargin == 0
    [fileName, filePath] = uigetfile2({ '*.edf' }, 'Select .EDF file');
    filePath = fullfile(filePath, fileName);
else
    filePath = inputname;
end
if iscell(filePath)
    filePath = char(filePath);
end

% Import EDF data and annotations
disp('Importing EDF data...')
[edfData, annot] = edfread(filePath, 'TimeOutputType', 'datetime');
info = edfinfo(filePath);
annot = timetable2table(annot,'ConvertRowTimes',true);

% Timestamps
edfTime = timetable2table(edfData,'ConvertRowTimes',true);
edfTime = datetime(table2array(edfTime(:,1)), 'Format', 'HH:mm:ss:SSS');
varTime = diff(edfTime);     %variability across samples

% Sampling rate and timestamps
sPerCell = mode(seconds(varTime));
if sPerCell == 1
    sRate = info.NumSamples(1);
else
    sRate = info.NumSamples(1)/sPerCell;
end

% Detect if data are discontinuous
idx = varTime > seconds(sPerCell+1);
if sum(idx) > 0
    warning([num2str(sum(idx)+1) ' discontinuous segments were detected. Merging segments into one continuous one.' ...
        'Boundaries are inserted between segments to correct DC offsets with eeglab  filters (automatic).'])
else
    % Check sample rate stability
    nSrate = 1./seconds(unique(varTime));
    nSrate(isinf(nSrate)) = [];
    if (max(nSrate)-min(nSrate))/max(nSrate) > 0.01
        warning('Sampling rate unstable! This can be a serious problem!');
    end
end

% Markers latency and name
if size(annot,1) > 0
    for iEv = 1:size(annot,1)
        EEG.event(iEv,:).type = char(table2array(annot(iEv,2)));
        latency = datetime(table2array(annot(iEv,1)), 'Format', 'HH:mm:ss:SSS') - edfTime(1);
        latency = floor(seconds(latency)*sRate); % convert to samples
        if latency == 0, latency = 1; end
        EEG.event(iEv,:).latency = latency;     
        EEG.event(iEv,:).urevent = iEv;
    end
end

% EEG data
edfData = table2array(edfData)';
eegData = [];
for iChan = 1:size(edfData,1)
    sample = 1;
    for iCell = 1:size(edfData,2)
        cellData = edfData{iChan,iCell};
        if sPerCell == 1     %data with correct sample rate at import
            eegData(iChan, sample:sample+sRate-1) = cellData;
            sample = sample + sRate;
        else
            % data with incorrect sample rate at import (e.g. RKS05 or RKS09)
            for iSec = 1:sPerCell
                if iSec == 1
                    eegData(iChan, sample:sample+sRate-1) = cellData(iSec:iSec*sRate);
                    sample = sample + sRate;
                else
                    eegData(iChan, sample:sample+sRate-1) = cellData(((iSec-1)*sRate)+1 : (iSec)*sRate);
                    sample = sample + sRate;
                end
            end
        end
    end
end

% EEGLAB structure
if exist('fileName','var')
    EEG.setname = fileName(1:end-4);
else
    EEG.setname = 'EEG data';
end
EEG.srate = sRate;
EEG.data = eegData;
EEG.nbchan = size(EEG.data,1);
EEG.pnts   = size(EEG.data,2);
EEG.xmin = 0;
EEG.trials = 1;
EEG.format = char(info.Reserved);
EEG.recording = char(info.Recording);
EEG.unit = char(info.PhysicalDimensions);
EEG = eeg_checkset(EEG);

% Channel labels
chanLabels = erase(upper(info.SignalLabels ),".");
if ~ischar(chanLabels)
    for iChan = 1:length(chanLabels)
        EEG.chanlocs(iChan).labels = char(chanLabels(iChan));
    end
end
EEG = eeg_checkset(EEG);

% Demean signal to remove DC offset 
if rmdrift
    disp('De-meaning signal to remove DC offset...');
    % for iChan = 1:EEG.nbchan
    %     ft = fft(EEG.data(iChan,:));
    %     ft(1) = 0;      %zero out the DC component
    %     EEG.data(iChan,:) = ifft(ft); % Inverse transform back to time domain.
    %     if abs(mean(real(EEG.data(iChan,:)))) > .0005
    %         warning('Data mean should be close to 0, DC drift removal must have failed.')
    %     end
    % end
    EEG.data = bsxfun(@minus, EEG.data, trimmean(EEG.data,20,2));
end

% Final check
EEG = eeg_checkset(EEG);

% History string
com = sprintf('EEG = import_edf(''%s'', %d)', filePath, rmdrift);
