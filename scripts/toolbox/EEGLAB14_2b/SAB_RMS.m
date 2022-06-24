% RMS

% ablauf:
% vor starten des scripts  tpA=[]; tpB=[]; ins command window; kann nicht im
% script stehen da werte sonst überschrieben werden
% zuerst script mit standard bedingung laufen lassen--> ermittlung
% von 2. maximalwert + zeitpunkt für standard bed.
% dann mit entkoppelter bedingung laufen
% lassen--> ermittlung von 1. und 2. maxwert + zeitpunkt für entkoppelte
% bedingung.
% dann nochmal für standard bed. laufen lassen, weil jetzt erst zeitpunkt 1
% bekannt ist.
% variablen: 

% tpA=[]; tpB=[]; 
file='up042mk1oAa.set';
name=(file(3:5));
A=1:1000;
B=1001:2000;
maxwin= B; % Zeitfenster wählen, innerhalb dessen max gesucht wird; A== -3000 bis -1000; B== -1000 bis 1000;

del_win=500; % Größe des rms Fensters
del_win=floor(del_win/2); % von ms zu datenpunkten
%{
alf_win=600;
gam_win=500;
rmscen_1=-1324;
rmscen_2=-304;

alf_win=ceil(alf_win/2);
gam_win=ceil(gam_win/2);
rmscen_1=ceil((rmscen_1+3000)/2);
rmscen_2=ceil((rmscen_2+3000)/2);
%}

eeglab;
EEG = pop_loadset( 'filename', [file],'filepath',... 
'C:\\Dokumente und Einstellungen\\FSC\\Desktop\\Diplomarbeit\\set Dateien\\oA\\');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DELTA

DELTA = pop_eegfilt( EEG, 0, 4, [], [0]);
DELTA = eeg_checkset( DELTA );

win=maxwin;
rmsvec=[];
for i=1:((DELTA.pnts/2)-del_win);
    cdata=DELTA.data(:,win,:); 
    cdata=cdata(:,i:(i+del_win),:); % rms fenster wird in schritten von jew. einem datenpunkt weiterverschoben
    crms=mean((cdata.^2),2); 
    crms=squeeze(sqrt(crms));
    crms=mean(crms,2);
    rmsvec=[rmsvec, crms];  % matrix mit sämtl. rms werten * elektr. 
end
rmsvecP=rmsvec([4 5 12],:);
rmsvecP=mean(rmsvecP,1); %mittelung über parietal
[val, ind]=max(rmsvecP); %wert und index (=zeitpunkt/2) des maximalwertes

if maxwin==A                % umwandlung von indizes in ms.
    tpA=((ind+(del_win/2))*2)-3000; % notwendig, da die indizes in beiden zeitfenstern bei 1 anfangen
elseif maxwin==B
    tpB=((ind+(del_win/2))*2)-1000;
end


cen1=(tpA+3000)/2;  % umwandeln der zeitpunkte in datenpunkte des gesamtdatensatzes
cen2=(tpB+3000)/2;

%zeitfenster 1
del_1=DELTA.data(:,(cen1-(del_win/2)):(cen1+(del_win/2)),:); %abtragen des rms zeitfensters in beide richtungen
 
del_ss_1=mean((del_1.^2),2);  %  = rms wert basierend auf single sweeps
del_ss_1=squeeze(sqrt(del_ss_1));
del_ss_1=mean(del_ss_1,2);
eval(['delta_ss_1','_', name, ' = del_ss_1']);  % Überprüfen ob del_ss = val

del_mv_1=mean(del_1,3);        %  = rms wert basierend auf mittelwerten    
del_mv_1=mean((del_mv_1.^2),2);
del_mv_1=squeeze(sqrt(del_mv_1));
eval(['delta_mv_1','_', name, ' = del_mv_1']); 

%zeitfenster 2
del_2=DELTA.data(:,(cen2-(del_win/2))):(cen2+(del_win/2))),:);

del_ss_2=mean((del_2.^2),2); 
del_ss_2=squeeze(sqrt(del_ss_2));
del_ss_2=mean(del_ss_2,2);
eval(['delta_ss_2','_', name, ' = del_ss_2']);

del_mv_2=mean(del_2,3);
del_mv_2=mean((del_mv_2.^2),2);
del_mv_2=squeeze(sqrt(del_mv_2));
eval(['delta_mv_2','_', name, ' = del_mv_2']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ALPHA

%{
ALPHA = pop_eegfilt( EEG, 8, 12, [], [0]);
ALPHA = eeg_checkset( ALPHA );
data_alf=(ALPHA.data);

rms_alf=data_alf(:,(rmscen-(alf_win/2)):(rmscen+(alf_win/2)),:);
rms_alf=mean(rms_alf.^2),2; 
rms_alf=squeeze(sqrt(rms_alf));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%GAMMA

GAMMA = pop_eegfilt( EEG, 30, 50, [], [0]);
GAMMA = eeg_checkset( GAMMA );
data_gam=(GAMMA.data);

rms_gam=data_gam(:,(rmscen-(gam_win/2)):(rmscen+(gam_win/2)),:);
rms_gam=mean(rms_gam.^2),2;
rms_gam=squeeze(sqrt(rms_gam));
%}
 
%{
 p4_A=[]; p4_B=[]; p4=[];
 p4_A=rmsvec(5,:);
 p4_B=rmsvec(5,:); 
 eval(['p4_A','_', name, ' = p4_A']); eval(['p4_B','_', name, ' = p4_B'])
 p4=[p4_A_044 p4_B_044];
%}

% save('filename', 'var1', 'var2', ...) saves only the specified workspace 
% variables in filename.mat. Use the * wildcard to save only those 
% variables that match the specified pattern. For example, 
% save('A*') saves all variables that start with A.

 clear del_1 del_2  alf_win  del_win  gam_win  rmscen_1  rmscen_2 ...
  name  file  del_mv_1 del_mv_2 del_ss_1  del_ss_2 cen1  cen2  cdata ...
  crms i maxwin rmsvec rmsvecP  win  ind         



