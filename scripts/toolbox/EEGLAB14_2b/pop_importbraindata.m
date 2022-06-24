function ALLEEG = pop_importbraindata(datadir,waitbar,ALLEEG)
% pop_importbraindata() - import data from a braindata file into EEGLAB
%
%   This function imports a braindata file by Peter Ganten's
%   importbraindata function and renders it compatible to EEGLAB. File
%   and sweeplist selection are graphical. pop_importbraindata
%   automatically imports the following parameters from braindata
%
%           - the data
%           - sampling rate
%           - epoch length
%           - channel locations (only if available in braindata)
%           - sweep numbers
%
%   It is called by the eeglab plugin 'Import braindata/Import epoched
%   data').
%
% Usage:
%   >> [ALLEEG, EEG] = pop_importbraindata(datadir, waitbar, ALLEEG, EEG);
%
% Revision: 2007/06/08
%

%%
% set original directory
startdir = pwd;
% go to data directory
cd(datadir)

%% select files for import
[filename, pathname] = uigetfile( ...
    {'*.spo;*.evo;','All braindata files (*.spo, *.evo)'; ...
    '*.spo', 'Spontaneous braindata files (*.spo)'; ...
    '*.evo', 'Evoked braindata files (*.evo)'; ...
    '*.*', 'All files (*.*)' }, ...
    'Pick a braindata file', 'Multiselect', 'on');
filename = cellstr(filename);

% begin of loop for all selected files
for i = 1:size(filename,2)
    file = [pathname, filename{i}(1:end-4)];

%% import the data
    try
        [d,p] = importbraindata(file,waitbar);
        exist_swpl = 1;
    catch
        disp('No sweeplist found. Trying to import raw data.')
        [d,p] = importbraindata_raw(file);
        exist_swpl = 0;
    end

%% sweeplist operations
    if exist_swpl == 1
        nsweeplists = size(p.sweeplist,1);
        swpl_description = strvcat(cellstr(p.descr_sweep_list));

        % choose sweeplist prompt
        prompt = {strvcat([num2str(nsweeplists),' sweeplists found:'],...
            ' ', ...
            swpl_description, ...
            ' ', ...
            'Choose your sweeplist:' )};
        name = 'Input for import of braindata file';
        numlines = 1;
        defaultanswer = {'1'};
        sweeplistnr = str2double(inputdlg(prompt,name,numlines,defaultanswer));
        sweeps = p.sweeplist(sweeplistnr,p.sweeplist(sweeplistnr,:)>0);

        % reduce the data
        if ~isempty(sweeps)
            d = d(sweeps,:,:);
        end
    end

    % permute the data for eeglab ( channels x data points x epochs )
    d = permute(d, [3 2 1]);

%% eeglab parameters

    % calculate sampling frequency ( p.dwz is the 'Digitalisierungsrate' in
    % mirco seconds )
    sf = 10^6/p.dwz;
    % epoch lenght
    xmin = -p.dwz*p.trigger/1000000;
    % collect channel information
    channels = cellstr(p.text_channel);
    try for k = 1:p.number_of_channels
            if isempty(channels{k})
                channels(k) = {[ num2str(k) '_empty' ]};
            end
        end
    catch
        channels(cellfun(@isempty ,channels)) = {'empty'};
    end
    chanlocs = struct('labels', channels(1:p.number_of_channels));

%% create the eeglab data set
    EEGOUT = pop_importdata('data',d, ...
        'dataformat', 'array', ...
        'nbchan', p.number_of_channels,...
        'srate', sf, ...
        'pnts', p.points_in_sweep, ...
        'xmin', xmin, ...
        'setname', [filename{i}(1:end-4),' ', p.sweepdesc{sweeplistnr}]);

    % write channel information into data set
    try 
        chan = pop_chanedit( chanlocs , 'lookup',  '/eegdaten/matlab-toolbox/toolbox/eeglab/plugins/dipfit2.2/standard_BESA/standard-10-5-cap385.elp');
    catch
        chan = pop_chanedit( chanlocs );
        disp('COULD NOT FIND CHANNEL LOCATION FILE ON DISK. PLEASE ADJUST THE PATH!')
    end
    EEGOUT.chanlocs = chan;

    % create event structur
    dummy = cell(1,size(d,3));
    trigger = dummy;
    trigger(:) = {'trigger'};                               % trigger
    % set the latency to 0. maybe somtime...
    % latency = num2cell(dp2ms([1:size(d,3)].*512,500));
    epoch = num2cell(1:size(d,3));                          % epochs
    % sweeps
    sweep = num2cell(sweeps);
    if isempty(sweep)
        sweep = num2cell(1:size(d,3));
    end

    % write event structure into data set
    EEGOUT.event = struct('type', trigger, ...
        'epoch', epoch, 'braindatasweep', sweep);

    comments = { 'Imported with pop_importbraindata.', ...
        'Original file:', ...
        file, ...
        ['Orignal sweeplist: ' num2str(sweeplistnr)]};
    EEGOUT.comments = cellstr(comments);
%% store the created data set into the global data set
    ALLEEG = eeg_store(ALLEEG, EEGOUT);

end  % end of loop for all selected files

% get back into original directory
cd(startdir)
