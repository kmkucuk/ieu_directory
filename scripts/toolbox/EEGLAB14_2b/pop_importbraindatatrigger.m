function ALLEEG = pop_importbraindatatrigger(datadir, waitbar, ALLEEG)
% Revision: 2007/06/08

[filename, pathname] = uigetfile( ...
    {'*.spo;*.evo;','All braindata files (*.spo, *.evo)'; ...
    '*.spo', 'Spontaneous braindata files (*.spo)'; ...
    '*.evo', 'Evoked braindata files (*.evo)'; ...
    '*.*', 'All files (*.*)' }, ...
    'Pick a braindata file', 'Multiselect', 'on');
filename = cellstr(filename);


%%
for i = 1:size(filename,2)
    file = [pathname, filename{i}(1:end-4)];
    try 
        [d,p] = importbraindata_raw(file);
    catch
        error(['Could not import', file])
        continue
    end

    d = makecontdata(d);


    %% eeglab parameters
    % calculate sampling frequency ( p.dwz is the 'Digitalisierungsrate' in
    % mirco seconds )
    sf = 10^6/p.dwz;
        
    % collect channel information
    channels = cellstr(p.text_channel);
    channels(cellfun(@isempty ,channels)) = {'empty'};
    chanlocs = struct('labels', channels(1:p.number_of_channels));
    
    %% create the eeglab data set
    EEGOUT = pop_importdata('data',d, ...
        'dataformat', 'array', ...
        'nbchan', p.number_of_channels,...
        'srate', sf, ...
        'setname', [filename{i}(1:end-4),' cont triggered']);

    % write channel information into data set
    chan = pop_chanedit( chanlocs );
    EEGOUT.chanlocs = chan;
    
    e_triggernr = cell(1,10);
    e_type = cell(1,10);
    e_triggersweeps = cell(1,10);
    e_latency = cell(1,10);
    
    for j = 1:size(p.triggerdesc,1)
        clear triggersweeps latency triggernr type
        
        triggersweeps = double(nonzeros(p.triggerlist(j,:)));
        type(1:size(triggersweeps,1)) = p.triggerdesc(j);
        triggernr(1:size(triggersweeps,1)) = j;
        latency = dp2ms(p.trigger,sf) + ...
        (triggersweeps-1)*p.points_in_sweep;
            
        e_triggernr{j} = triggernr;
        e_type{j} = type;
        e_triggersweeps{j} = triggersweeps;
        e_latency{j} = latency;
    end
    latency = num2cell(cat(1, e_latency{:}));
    type = cat(2, e_type{:});
    triggernr = num2cell(cat(2, e_triggernr{:}));
    
        
    EEGOUT.event = struct('type', type, ...
        'latency', latency', 'triggernr', triggernr);
    
    %% store the created data set into the global data set
    ALLEEG = eeg_store(ALLEEG, EEGOUT);

end

% get back into original directory
% cd(startdir)

function D = makecontdata(d)
    for i = 1:size(d,3)
        tmp = (d(:,:,i))';
        tmp = tmp(:);
        D(:,i) = tmp;
    end
    D = D';
