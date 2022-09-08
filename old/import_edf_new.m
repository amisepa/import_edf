%% import_edf()
% Imports and converts European Data Formatted (EDF) data into EEGLAB.
% Compatible with EDF-, EDF+, EDF+C, EDF+D data
%
% This function uses the MATLAB's edfread function introduced in Matlab R2020b
% AND the Signal processing toolbox.
%
% For discontinuous data: the function merges segments into one continuous
% file, and inserts a boundary so that DC offsets are automatically corrected
% by EEGLAB filters (when applied in later processing steps).
%
% Usage:
%   eeglab
%   EEG = import_edf;               %pop-up window mode
%   or
%   EEG = import_edf(filePath);     %command line (filePath must be a character string)
%
% Output:
%   EEG structure in EEGLAB format
%
% Requirements: Matlab R2020b or later AND the Signal processing toolbox
%
% Detailed ressource on the EDF+ format: https://www.edfplus.info/index.html
%
% Cedric Cannard, July 2021, ccannard@pm.me
%
% If you encounter an error, please report it here: https://github.com/amisepa/import_edf/issues

function EEG = import_edf(inputname)

% Check for Matlab version and Signal processing toolbox
matlab_version = erase(version, ".");
matlab_version = str2double(matlab_version(1:3));
if matlab_version < 990 && ~license('test', 'Signal_Toolbox')
    errordlg('You need Matlab 2020b or later AND the Signal Processing Toolbox to use this function. You can try to download edfRead here: https://www.mathworks.com/matlabcentral/fileexchange/31900-edfread; or use EEGLAB''s Biosig toolbox');
    return
end

EEG = eeg_emptyset;

% Get filename and path
if nargin == 0
    [fileName, filePath] = uigetfile2({ '*.edf' }, 'Select .EDF file');
    filePath = fullfile(filePath, fileName);
else
    filePath = inputname;
    if ~ischar(filePath), filePath = char(filePath); end
end

% Import EDF data and annotations
% edfData = edfread(filePath);
[edfData, annot] = edfread(filePath, 'TimeOutputType', 'datetime');
info = edfinfo(filePath);
annot = timetable2table(annot,'ConvertRowTimes',true);

% Timestamps
edfTime = timetable2table(edfData,'ConvertRowTimes',true);
edfTime = datetime(table2array(edfTime(:,1)), 'Format', 'HH:mm:ss:SS');

% Sampling rate
cellSize = size(cell2mat(edfData{1,1}));
timeDiff = diff(edfTime);                       %time diff between each timestamp
commonTime = mode(round(seconds(timeDiff)));
sRate = cellSize(1)/commonTime;
% sRate = info.NumSamples(1);                   %srate from edfread output
% if sRate ~= cellSize(1)
%     error('Discrepancy in sample rates between the 2 methods')
% end
% sRate2 = cellSize(1) / cellIntervals;        %sample rate from data
% if sRate ~= sRate2
%     error('Discrepancy between sample rate stored in file and timestamps')
% end

cprintf('blue', ['Sample rate detected: ' num2str(sRate) ' Hz. \n']);

% Check if data is continuous or not
% if cellIntervals == 1
% %     sRate = info.NumSamples(1);
% cellIntervals = mode(seconds(varTime));
% timeDiff = diff(edfTime);     %variability across samples
% commonTime = mode(round(seconds(timeDiff)));
idx = round(seconds(timeDiff)) > commonTime;
if sum(idx) == 0
    continuous = true;
    disp('Continuous data detected.');
else
    continuous = false;
    disp('Discontinuous data detected!');
    %     sRate = info.NumSamples(1)/cellIntervals;
    %     correctSize = length(edfTime)*cellIntervals;
    %     correctTimes(1) = edfTime(1);
    %     for i = 2:correctSize
    %         correctTimes(i,:) = correctTimes(i-1)+seconds(1);
    %     end
end

% Check sample rate stability
% nSrate = 1./seconds(unique(varTime));
% nSrate(isinf(nSrate)) = [];
% if (max(nSrate)-min(nSrate))/max(nSrate) > 0.01
%     warning('Sampling rate unstable! Something serious may have happened during recording.');
% end

% Events/markers
for iEv = 1:size(annot,1)
    EEG.event(iEv,:).type = char(table2array(annot(iEv,2)));
    latency = datenum(datetime(table2array(annot(iEv,1)), 'Format', 'HH:mm:ss:SSS'));
    latency = latency - datenum(datetime(edfTime(1), 'Format', 'HH:mm:ss:SSS'));
%     EEG.event(iEv,:).latency = round(latency*24*60*60*sRate);   %correct latency in ms
    EEG.event(iEv,:).latency = round(latency*24*60*60*1000);   %correct latency in ms
    EEG.event(iEv,:).urevent = iEv;
end

if ~continuous

    % Gaps
    %     index(2:length(varTime)+1,:) = second(varTime) ~= mode(varTime);
    %     bound = find(index);
    gap_idx = find(idx);
    for iGap = 1:length(gap_idx)
        gaps(iGap) = edfTime(gap_idx(iGap)+1) - edfTime(gap_idx(iGap));
    end

    % Data segment bounds in ms
    seg(1,1) = edfTime(1);
    seg(1,2) = edfTime(gap_idx(1));
    count = 2;
    for iSeg = 1:length(gap_idx)
        seg(count,1) = edfTime(gap_idx(iSeg)+1);
        if iSeg ~= length(gap_idx)
            seg(count,2) = edfTime(gap_idx(iSeg+1));
        else
            seg(count,2) = edfTime(end);
        end
        count = count+1;
    end
    seg_ms = datenum(seg) - datenum(datetime(edfTime(1), 'Format', 'HH:mm:ss:SSS'));
%     seg_ms = round(seg_ms*24*60*60*sRate);   %latency in ms
    seg_ms = round(seg_ms*24*60*60*1000);

    %Find which segment each event belongs to
    for iEv = 1:size(annot,1)
        for iSeg = 1:size(seg_ms,1)
            if EEG.event(iEv).latency >= seg_ms(iSeg,1) && EEG.event(iEv).latency <= seg_ms(iSeg,2)
                EEG.event(iEv).seg = iSeg;
            end
        end
    end
    
    ev(iEv,:).type = table2array(annot(iEv,2));
    ev(iEv,:).lat = datetime(table2array(annot(iEv,1)), 'Format', 'HH:mm:ss:SSS');
    for iSeg = 1:length(seg)
        if isbetween(ev(iEv,:).lat, seg(iSeg,1), seg(iSeg,2))
            ev(iEv,:).seg = iSeg;
        end
    end
    
    emptyLat = arrayfun(@(ev) isempty(ev.seg),ev);
    warning(['Removing event with no latency: ' char(ev(emptyLat).type) ])
    ev(emptyLat,:) = [];

    %Remove gaps to correct event latencies
    for iEv = 1:length(ev)
        if ev(iEv).seg > 1          %for segments after 1st gap
            gap = sum(gaps(1:ev(iEv).seg - 1));
            ev(iEv,:).removed_gap = gap;
            ev(iEv,:).correct_lat = ev(iEv,:).lat - gap;
        elseif ev(iEv,:).seg == 1   %segment before 1st gap
            ev(iEv,:).correct_lat = ev(iEv,:).lat;
        end
    end

    %Get event latencies adjusted to time 0 and in ms
    for iEv = 1:length(ev)
        latency = datenum(ev(iEv).correct_lat) - datenum(datetime(edfTime(1), 'Format', 'HH:mm:ss:SSS'));
%         EEG.event(iEv,:).latency = round(latency*24*60*60*sRate);   %latency in ms
        EEG.event(iEv,:).latency = round(latency*24*60*60*1000);   %latency in ms
        EEG.event(iEv,:).type = char(ev(iEv).type);
        EEG.event(iEv,:).urevent = iEv;
    end
end

EEG = eeg_checkset(EEG);

%EEG data
disp('importing data...')
edfData = table2array(edfData)';
eegData = [];
% sample = 1;
for iChan = 1:size(edfData,1)
    for iCell = 1:size(edfData,2)

        if iCell == 1
            eegData(iChan, 1:1+cellSize(1)-1) = edfData{iChan,iCell};
        else
            idx = ((iCell-1) * cellSize(1))+1 : iCell*cellSize(1);
            eegData(iChan, idx) = edfData{iChan,iCell};
        end
%         sample = sample+cellSize(1);
    end
end
%         if commonTime == 1 && cellSize(1) == sRate && cellSize(2) == 1
%             eegData(iChan, sample:sample+sRate-1)  = edfData{iChan,iCell};
%             sample = sample + sRate;
%         end
        %         if cellIntervals == 1     %data with correct sample rate at import
        %             eegData(iChan, sample:sample+sRate-1) = cellData;
        %             % sample = sample + length(edfData{iChan,iCell});
        %             sample = sample + sRate;
%         else  %for data with incorrect sample rate at import (e.g. RKS05 test file)
%             for iSec = 1:cellIntervals
%                 eegData(iChan, sample:sample+sRate-1) = cellData(iSec:iSec+sRate-1);
%                 % eegData(iChan, sample:sample+sRate-1) = cellData(((iSec-1)sRate+1):(iSecsRate));
%                 sample = sample + sRate;
%             end
%         end
%     end
% end

if size(eegData,2)/sRate/commonTime ~= info.NumDataRecords
    error('Discrepancy in file length!')
end

%EEGLAB structure
if exist('fileName','var')
    EEG.setname = fileName(1:end-4);
else
    EEG.setname = char(info.Reserved);
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
EEG.times = (EEG.times ./ commonTime);

%Channel labels
chanLabels = erase(upper(info.SignalLabels ),".");
if ~ischar(chanLabels)
    for iChan = 1:length(chanLabels)
        EEG.chanlocs(iChan).labels = char(chanLabels(iChan));
    end
end
EEG = eeg_checkset(EEG);

pop_eegplot(EEG,1,1,1);

%Add boundaries between segments so that EEGLAB filters can
%automatically correct DC offsets
if ~continuous

    %index empty events
    for iEv = 1:length(ev)
        if isempty(ev(iEv).seg)
            rm_ev(iEv) = true;
        else
            rm_ev(iEv) = false;
        end
    end
    ev(rm_ev) = [];
    EEG = pop_editeventvals(EEG,'delete', find(rm_ev));

    for iEv = 1:length(ev)
        if isempty(ev(iEv).removed_gap)
            ev(iEv).removed_gap = duration('00:00:00');
        end
    end
    count = 1;
    for iEv = 2:length(ev)
        if ev(iEv).removed_gap ~= ev(iEv-1).removed_gap
            dc_offset(count,1) = EEG.event(iEv,:).latency-2;
            dc_offset(count,2) = EEG.event(iEv,:).latency-1;
            count = count+1;
        end
    end
    %         EEG = pop_select(EEG, 'nopoint', dc_offset);  %add boundary at DC offset
    EEG = eeg_eegrej(EEG, dc_offset);
    EEG = eeg_checkset(EEG);
end

%% Remove DC drift
disp('Removing DC drift');
for iChan = 1:EEG.nbchan
    ft = fft(EEG.data(iChan,:));
    ft(1) = 0;  %zero out the DC component
    EEG.data(iChan,:) = ifft(ft); % Inverse transform back to time domain.
    meanVal = mean(real(EEG.data(iChan,:))); % check: mean should now be close to zero.
end

end
