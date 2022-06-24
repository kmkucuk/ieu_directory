%RT

file='up045mk1oAa.set';
name=(file(3:5));

eeglab;
EEG = pop_loadset( 'filename', [file],'filepath',... 
'C:\\Dokumente und Einstellungen\\FSC\\Desktop\\Diplomarbeit\\set Dateien\\oA\\');

knopf=squeeze(EEG.data(14,:,:));
[valk indk]=max(diff(knopf));

trig=squeeze(EEG.data(13,:,:));
[valt indt]=max(diff(trig));

RT=mean(2*(indk-indt));


% eval .... 




