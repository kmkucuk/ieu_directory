function repaireventstructure()
global EEG
continuedlg = questdlg('Warning: This action will reset the event structure of your current EEGlab set! Do you know what you are doing? ', ...
    'Continue?', ...
    'Yes', 'No', 'Yes');

switch continuedlg
    case 'Yes'
    case 'No'
        return
end
epochs = num2cell(1:EEG.trials);
dummy = cell(1,EEG.trials);
trigger = dummy;
trigger(:) = {'trigger'};                               % trigger

% write event structure into data set
EEG.event = struct('type', trigger, ...
    'epoch', epochs);

eeglab redraw