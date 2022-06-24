function RMS = RMS_all_loaded_datasets()
global DATA PARA
Windows = inputdlg('Time windows in ms for RMS:', 'Time window', 1);
Channel = str2double(inputdlg('Select channel:', 'Channel', 1));
if isempty(Windows)
    return
end
Windows = cellstr(Windows{:});

pathname = uigetdir('','Select target directory');

files = fieldnames(DATA);
nFiles = length(files);

for k = 1:nFiles
    d = DATA.(files{k});
    p = PARA.(files{k});
    Window = str2num(Windows{1}); %#ok<ST2NM>
    limits = fix(ms2dp(Window,p.srate) + p.trigger); 
    limits(limits==0) = 1;
    data = d(Channel,limits(1):limits(2),:);
    %     RMS(i,:,:) = sqrt(mean(data.^2,2));
    rms = double(squeeze(sqrt(mean(data.^2,2))));
    if exist('RMS','var')
        RMS = [RMS; rms]; %#ok<AGROW>
    else
        RMS = rms;
    end
end
filename = ['/RMS_', num2str(nFiles), 'datasets_' , num2str(Window(1)),'to',num2str(Window(2)), 'ms_channel', num2str(Channel), '.txt'];

fid = fopen([pathname filename], 'wt');
fprintf(fid, '%g \n', RMS);
fclose(fid)

