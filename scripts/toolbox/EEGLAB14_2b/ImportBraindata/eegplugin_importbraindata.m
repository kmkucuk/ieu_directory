function eegplugin_importbraindata( fig, try_strings, catch_strings )
% Revision: 2007/06/08

% create menu
importdatamenu = findobj(fig, 'tag', 'import data');
submenu = uimenu(importdatamenu, 'label', 'Import braindata');

cmd = 'ALLEEG = pop_importbraindata(''/eegdaten/dat'', 1, ALLEEG); eeglab redraw';
cmdcont = 'ALLEEG = pop_importbraindatacont(''/eegdaten/dat'', 0, ALLEEG); eeglab redraw';
cmdtrigger = 'ALLEEG = pop_importbraindatatrigger(''/eegdaten/dat'', 0, ALLEEG); eeglab redraw';
% Epoched data import
uimenu(submenu, 'label', 'Import epoched data', 'callback', cmd);
% Continous data import
uimenu(submenu, 'label', 'Import continous data', 'callback', cmdcont);
% Triggered data import
uimenu(submenu, 'label', 'Import triggered data', 'callback', cmdtrigger);
