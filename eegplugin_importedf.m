% eegplugin_importedf() - EEGLAB plugin to import
% 
% Usage: eegplugin_importedf(fig, trystrs, catchstrs);
%
% Inputs:
%   fig        - [integer]  EEGLAB figure
%   trystrs    - [struct] "try" strings for menu callbacks.
%   catchstrs  - [struct] "catch" strings for menu callbacks.
%
% Copyright (C) - Cedric Cannard, August 2022
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function vers = eegplugin_importedf(fig, trystrs, catchstrs)

if nargin < 3
    error('eegplugin_importedf requires 3 arguments');
end

% plugin version
vers = 'import_edf1.3';

% path
if ~exist('import_edf.m','file')
    addpath(genpath(fileparts(which('import_edf.m'))));
end

% Find menu
menui = findobj(fig, 'tag', 'import data');

% Menu callbacks
comcnt = [trystrs.no_check '[EEG, LASTCOM] = import_edf();'  catchstrs.new_non_empty];

% Create menus
uimenu(menui, 'label', 'From EDF/EDF+ files (using MATLAB edfread)', 'separator', 'on', 'callback', comcnt);

end
