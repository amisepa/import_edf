    %     EEG.comments(1) = { 'Manufacturer: ' info.TransducerTypes(1) };

    %     %merge data sets
    %     eeg = set_merge(eegA,eegB)
    %
    %     %EEG data and associated variables
    %     EEG.srate = info.NumSamples(1);
    %     edfTime = timetable2table(edfData,'ConvertRowTimes',true);
    %     edfData = table2array(edfData)';
    %     for iChan = 1:size(edfData,1)
    %         sample = 1;
    %         for iCell = 1:size(edfData,2)
    %             eegData(iChan, sample:sample+EEG.srate-1) = single(edfData{iChan,iCell});
    %             sample = sample + length(edfData{iChan,iCell});
    %             edfTime(iCell)
    %         end
    %     end
    %     EEG.data = eegData;
    %     EEG.nbchan = size(EEG.data,1);
    %     EEG.pnts   = size(EEG.data,2);
    %     EEG.xmin = 0;
    %     EEG.trials = 1;
    %     EEG = eeg_checkset(EEG);
    %
    %     % Test timepoints stability
    %     edfTime = datetime(table2array(edfTime(:,1)), 'Format', 'mm:ss:SSS');
    %     varTime = diff(edfTime);                %time space between samples
    %     nSrate = 1./seconds(unique(varTime));
    %     nSrate(isinf(nSrate)) = [];
    %
    %     %For discontinuous data (e.g. EDF+D)
    %     if (max(nSrate)-min(nSrate))/max(nSrate) > 0.01
    %         warning('Sampling rate differs between some samples! Data is either discontinuous (taken care of) or something is wrong with the recording timestamps (NOT taken care of!).');
    %
    %         %Get boundaries between segments of discontinuous data
    %         index(2:length(varTime)+1,:) = varTime ~= mode(varTime);
    %         bound = edfTime(index);
    %
    %         %get gaps between segments and correct latencies
    %         counter = 1;
    %         for t = 2:length(index)
    %             if index(t)
    %                 gap(counter) = seconds(varTime(t-1));
    %                 counter = counter + 1;
    %             end
    %         end
    %
    %         %Events
    %         annotations = timetable2table(annotations,'ConvertRowTimes',true);
    %         for a = 1:size(annotations,1)
    %             ev(a,:).type = table2array(annotations(a,2));
    %             ev(a,:).lat = datetime(table2array(annotations(a,1)), 'Format', 'HH:mm:ss:SSS');
    %
    %             %find their segment
    %             for b = 2:length(bound)
    %                 if ev(a).lat < bound(1)
    %                    ev(a,:).segment = 1;
    %                    ev(a,:).latency = ev(a-1,:).lat - ev(a-1,:).lat;
    %                    continue
    %                 elseif ev(a).lat > bound(b-1) && ev(a).lat < bound(b)
    %                     ev(a,:).segment = b;
    %                     return
    %
    % %                     ev(a,:).latency = ev(a,:).lat - seconds(gap(b+1));
    % %                     continue
    %                 elseif ev(a).lat > bound(b)
    %                     ev(a,:).segment = b+1;
    % %                     ev(a,:).latency = ev(a,:).lat - seconds(gap(b+1));
    %                     continue
    %                 end
    %             end
    %         end
    %
    %
    %         %Correct event latencies
    %         evLat = str2double(erase(string(info.Annotations.Onset), "sec"));   %original event latencies (in sec)
    %         evLat = evLat.*1000;    %convert to milliseconds
    %
    %         %     evLat2 = evLat;
    %         varTime2 = diff(evLat);                %time space between events
    %         ind = maxk(varTime2, length(gap));     %take biggest gaps
    %         indx = varTime2 == ind';
    %         indx = sum(indx,2);
    %         indx = find(indx);      %returns the events for each segment
    %         for i = length(indx):-1:1
    %             for iEv = length(evLat):-1:1
    %                 if iEv > indx(i)
    %                     evLat(iEv) = evLat(iEv) - gap(i);
    %                 end
    %             end
    %         end
    %
    %     end
    %     %Create event structure
    %     event_types = info.Annotations.Annotations;
    %     for iEvent = 1:length(event_types)
    %         EEG.event(iEvent).type = char(event_types(iEvent));
    %         EEG.event(iEvent).latency = evLat(iEvent);
    %         %         EEG.event(iEvent).latency = event_latencies(iEvent) + 1;  %get latencies with T0 = T1
    %     end
    %
    %
    %     %Check
    %     EEG = eeg_checkset(EEG, 'makeur');   % Make EEG.urevent field
    %     EEG = eeg_checkset(EEG, 'eventconsistency');
    %     EEG = eeg_checkset(EEG);
    
    %     evLat2 = evLat;
    %     correctLat = times(index);
    %     for iGap = length(gap):-1:1
    %         for iEv = length(evLat2):-1:1
    %             if evLat2(iEv) > correctLat(iGap)+ sum(gap(1:iGap))
    %                 evLat2(iEv) = evLat2(iEv) - gap(iGap);
    %             end
    %         end
    %     end
    
    
    %recreate continuous time stamps
    %     sample = 1;
    %     for t = 1:length(edfTime)
    % %         if indx(iTime) == mode(indx)
    %         new_eegTime(:,sample:sample+EEG.srate-1) = sample:sample+EEG.srate-1;
    %         sample = new_eegTime(end)+1;
    %     end
    
    
    %         new_eegTime(:,sample:sample+EEG.srate-1) = sample
    %         sample = sample + length(edfData{iChan,iCell});
    %         if mode(indx)
    
    %Testing sampling rate stability and dealing with discontinuous data (e.g. EDF+D)
    %     x = datevec(eegTime);
    %     x = x(:,6);
    %     x = x - x(1)
    %     x = x.*1000
    
    %     indx = seconds(diff(eegTime));
    %     maxk(indx)
    
    
    %EDF format
    
    %Check EEG structure
    EEG = eeg_checkset(EEG);
    
end


