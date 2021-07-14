% pop_importedfevents() - imports EDF+ events recorded with the BCI2000 system
%
% Usage:
%   >> events = pop_importedfevents();  %pop-up window mode to select EDF file
%   >> events = pop_importedfevents(file_path_and_name);
%
% Optional inputs:
%   filename  - path and name of .edf file containing the events
%
% Outputs:
%   Events in EEGLAB structure format
%
% If you have Matlab R2020b or later AND the Signal processing toolbox,
% this function uses Matlab's edfread function.
% If you have Matlab R2020a or earlier, this funciton uses mexSLOAD.mex file from https://pub.ist.ac.at/~schloegl/src/mexbiosig/
%
% Author: Cedric Cannard, 2021
%
% Copyright (C) 2021 Cedric Cannard, ccannard@protonmail.com
% Copyright (C) 2012-2017,2020 by Alois Schloegl <alois.schloegl@gmail.com>
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.

function events = pop_importedfevents(inputname)

%Get filename and path
if nargin == 0
    [fileName, filePath] = uigetfile2({ '*.edf' }, 'Select EDF+ file - pop_musedirect()');
    fileName = fullfile(filePath, fileName);
else
    fileName = inputname;
end

%Get Matlab version to choose appropriate method
matlab_version = erase(version, ".");
matlab_version = str2double(matlab_version(1:3));

%For matlab > 2020a AND Signal processing toolbox
if matlab_version >= 980 && license('test', 'Signal_Toolbox')
    disp('Matlab version > 2020a: importing EDF+ events using Signal processing toolbox.');
    
    info = edfinfo(fileName);
    event_types = info.Annotations.Annotations;
    event_latencies = str2double(erase(string(info.Annotations.Onset), "sec")).*info.NumSamples(1);
    for iEvent = 1:length(event_types)
        events(iEvent).type = char(event_types(iEvent));
        events(iEvent).latency = event_latencies(iEvent) + 1;  %get latencies with T0 = T1
        events(iEvent).urevent = iEvent;
    end
    
    %For Matlab <= 2020a or no Signal processing toolbox with Matlab > 2020a
else
    disp('Matlab version <= 2020a: importing EDF+ events using the biosig toolbox.');
    
    [s,HDR] = mexSLOAD(fileName);
    event_types = HDR.EVENT.TYP;
    
    for iEvent = 1:length(event_types)
        if event_types(iEvent) == 1
            events(iEvent).type = 'T0';
        elseif event_types(iEvent) == 2
            events(iEvent).type = 'T2';
        elseif event_types(iEvent) == 3
            events(iEvent).type = 'T1';
        elseif event_types(iEvent) == 4
            events(iEvent).type = 'T3';
        elseif event_types(iEvent) == 5
            events(iEvent).type = 'T4';
        elseif event_types(iEvent) == 6
            events(iEvent).type = 'T5';
        end
        
        events(iEvent).latency = HDR.EVENT.POS(iEvent);
        events(iEvent).urevent = iEvent;
        
    end
end
end
