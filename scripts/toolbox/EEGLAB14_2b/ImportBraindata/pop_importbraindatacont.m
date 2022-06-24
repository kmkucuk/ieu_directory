function ALLEEG = pop_importbraindatacont(datadir,waitbar, ALLEEG)


% set original directory
startdir = pwd;
% go to data directory
cd(datadir)
%% select files for import
[filename, pathname] = uigetfile( ...
    {'*.spo', 'Spontaneous braindata files (*.spo)'; ...
    '*.*', 'All files (*.*)' }, ...
    'Pick a braindata file', 'Multiselect', 'on');
filename = cellstr(filename);

%%
for i = 1:size(filename,2)
    file = [pathname, filename{i}(1:end-4)];
    [d,p] = importbraindata_raw(file,waitbar);

    d = makecontdata(d);


%% eeglab parameters
    % calculate sampling frequency ( p.dwz is the 'Digitalisierungsrate' in
    % mirco seconds )
    sf = 10^6/p.dwz;
    % epoch lenght
    xmin = -p.dwz*p.trigger/1000000;
    % collect channel information
    channels = cellstr(p.text_channel);
    channels(cellfun(@isempty ,channels)) = {'empty'};
    chanlocs = struct('labels', channels(1:p.number_of_channels));



%% create the eeglab data set
    EEGOUT = pop_importdata('data',d, ...
        'dataformat', 'array', ...
        'nbchan', p.number_of_channels,...
        'srate', sf, ...
        'setname', [filename{i}(1:end-4),' continous']);

    % write channel information into data set
    try
        chan = pop_chanedit( chanlocs , 'lookup', [matlabroot '/toolbox/eeglab6.01b/plugins/dipfit2.1/standard_BESA/standard-10-5-cap385.elp']);
    catch
        chan = pop_chanedit( chanlocs );
        disp('COULD NOT FIND CHANNEL LOCATION FILE ON DISK. PLEASE ADJUST THE PATH!')
    end
    EEGOUT.chanlocs = chan;



%% store the created data set into the global data set
    ALLEEG= eeg_store(ALLEEG, EEGOUT);

end

% get back into original directory
cd(startdir)

function D = makecontdata(d)
for i = 1:size(d,3)
    tmp = (d(:,:,i))';
    tmp = tmp(:);
    D(:,i) = tmp;
end
D = D';