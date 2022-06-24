% RMS #2

% Ausgangsvariablen: TP_A und TP_B jeweils von einer Bedingung

%% uebergabe der variablen
%clear all; %clc;
anfang = 'up';
vp = {'16' };% '04' '07' '08' '12' '13' '15' '16' '18' '19' '20' '21'
bed ='4';
konvertierung = 'mk1'; % mk1: nach knopf / mk2: nach trigger
ende2 = 'oAa.set';
ende1 = 'oAa2.set';

path ='C:\Dokumente und Einstellungen\FSC\Desktop\Diplomarbeit\set Dateien\oA\';
path_save = 'C:\Dokumente und Einstellungen\FSC\Desktop\Diplomarbeit\set Dateien\oA\';

del_win = 500; % Größe des rms Fensters in ms
filter  = [0 4]; % fuer FFT: filtergrenzen (min max)

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
eeglab;           
for v = 1: size(vp,2);
        close all;
        
        try
            file = [anfang,vp{v},bed,konvertierung, ende1];
            EEG = pop_loadset( 'filename', file,'filepath',path);
            
        catch
            file = [anfang,vp{v},bed,konvertierung,ende2];
            EEG = pop_loadset( 'filename', file,'filepath',path);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        sf = 500; dt = 1000/sf; % sf = samplingfrequenz
        del_win=ceil(del_win/dt); % von ms zu datenpunkten

        DELTA = pop_eegfilt( EEG, filter(1), filter(2), [], [0]); 
        DELTA = eeg_checkset( DELTA );

        name=file(3:5);       
        
        delvec=[];
                for i= 1: DELTA.pnts - del_win;
                    
                      cdata=DELTA.data; 
                      cdata=cdata(:,i:(i+del_win),:); % rms fenster wird in schritten von jew. einem datenpunkt weiterverschoben
                      crms=mean((cdata.^2),2); 
                      crms=squeeze(sqrt(crms));
                      crms=mean(crms,2);
                      delvec=[delvec, crms];  % vektor mit sämtl. rms werten 
                end
    delpow_P4=delvec(5,:); %WICHTIG: Richtige Elektrode f. Alpha decrease wählen!!!
    delpow_P4=mean(delpow_P4,1);       

    delpow_Fz=delvec(11,:); %WICHTIG: Richtige Elektrode f. Alpha decrease wählen!!!
    delpow_Fz=mean(delpow_Fz,1);

    t = linspace((-3000+del_win), (1000-del_win), (DELTA.pnts-del_win));
    figure; plot (t,delpow_P4); title([name,'delP4']); saveas(gcf,[name,'_del_P4'],'fig');
    figure; plot (t, delpow_Fz); title([name,'delFz']); saveas(gcf,[name,'_del_Fz'],'fig');

    eval(['delpow_P4','_', name, ' = delpow_P4']);
    eval([' delpow_Fz','_', name, ' =  delpow_Fz']);
                                     
                    
end
                    
                    
                 

%{
% power_3

file='up215mk1oAa.set';
name=(file(3:5));

alfwin=400;
gamwin=300;

eeglab;
EEG = pop_loadset( 'filename', [file],'filepath',... 
'C:\\Dokumente und Einstellungen\\FSC\\Desktop\\Diplomarbeit\\set Dateien\\oA\\');





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ALPHA RMS

ALPHA = pop_eegfilt( EEG, 8, 12, [], [0]);
ALPHA = eeg_checkset( ALPHA );

alfvec=[];
for i=1:(ALPHA.pnts-alfwin/2); 
    cdata=ALPHA.data; 
    cdata=cdata(:,i:(i+alfwin/2),:); % rms fenster wird in schritten von jew. einem datenpunkt weiterverschoben
    crms=mean((cdata.^2),2); 
    crms=squeeze(sqrt(crms));
    crms=mean(crms,2);
    alfvec=[alfvec, crms];  % vektor mit sämtl. rms werten 
end
alfpow_P4=alfvec(5,:); %WICHTIG: Richtige Elektrode f. Alpha decrease wählen!!!
alfpow_P4=mean(alfpow_P4,1);       

alfpow_O2=alfvec(7,:); %WICHTIG: Richtige Elektrode f. Alpha decrease wählen!!!
alfpow_O2=mean(alfpow_O2,1);

t = linspace((-3000+alfwin/2), (1000-alfwin/2), (ALPHA.pnts-alfwin/2));
figure; plot (t,alfpow_P4); title([name,'alfP4']); saveas(gcf,[name,'_alf_P4'],'fig');
figure; plot (t,alfpow_O2); title([name,'alf_O2']); saveas(gcf,[name,'_alf_O2'],'fig');

eval(['alfpow_P4','_', name, ' = alfpow_P4']);
eval(['alfpow_O2','_', name, ' = alfpow_O2']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%GAMMA RMS

GAMMA = pop_eegfilt( EEG, 28, 48, [], [0]);
GAMMA = eeg_checkset( GAMMA );

gamvec=[];
for i=1:(GAMMA.pnts-gamwin/2);
    cdata=GAMMA.data; 
    cdata=cdata(:,i:(i+gamwin/2),:); % rms fenster wird in schritten von jew. einem datenpunkt weiterverschoben
    crms=mean((cdata.^2),2); 
    crms=squeeze(sqrt(crms));
    crms=mean(crms,2);
    gamvec=[gamvec, crms];  % vektor mit sämtl. rms werten 
end
gampow_Cz=gamvec(1,:); %WICHTIG: Richtige Elektrode f. Alpha decrease wählen!!!
gampow_Cz=mean(gampow_Cz,1);       
gampow_Fz=gamvec(1,:); %WICHTIG: Richtige Elektrode f. Alpha decrease wählen!!!
gampow_Fz=mean(gampow_Fz,1); 

t = linspace((-3000+gamwin/2), (1000-gamwin/2), (GAMMA.pnts-gamwin/2));
figure; plot (t, gampow_Cz); title([name,'gamCz']); saveas(gcf,[name,'_gam_Cz'],'fig');
figure; plot (t, gampow_Fz); title([name,'gamFz']); saveas(gcf,[name,'_gam_Fz'],'fig');


eval(['gampow_Cz','_', name, ' = gampow_Cz']);
eval(['gampow_Fz','_', name, ' = gampow_Fz']);
 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear del_1 del_2  alf_win  del_win  gam_win  rmscen_1  rmscen_2 ...
    file  del_mv_1 del_mv_2 del_ss_1  del_ss_2 cen1  cen2  cdata ...
  crms i maxwin rmsvec rmsvecP  win  ind   alfvec  alfwin  gamvec  gamwin...
alfpow  gampow  alfpow_O2  alfpow_P4  gampow_Cz gampow_Fz  name   t            

%}