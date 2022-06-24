% RMS #2

% Ausgangsvariablen: TP_A und TP_B jeweils von einer Bedingung

%% uebergabe der variablen
%clear all; %clc;
anfang = 'up';
vp = {'16'}; %'02' '04' '07' '08' '12' '13' '15' '16' '18' '19' '20' '21'
bed ='4';
bed2 = 1 ; 
konvertierung = 'mk1'; % mk1: nach knopf / mk2: nach trigger
ende2 = 'oAa.set';
ende1 = 'oAa2.set';

path ='C:\Dokumente und Einstellungen\FSC\Desktop\Diplomarbeit\set Dateien\oA\';
path_save = 'C:\Dokumente und Einstellungen\FSC\Desktop\Diplomarbeit\set Dateien\oA\';

del_win = 500; % Größe des rms Fensters in ms
filter  = [0 4]; % fuer FFT: filtergrenzen (min max)

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

del_ss_1_vp=[];del_ss_2_vp=[];del_mv_1_vp=[];del_mv_2_vp=[];

eeglab;           
for v = 1: size(vp,2);
        close all;
        
        %%%bitte pruefen!!!!%%%%
        % ich gehe hier davon aus, das wenn es einen file mit
        % 'mk1oAa2.set' am ende gibt dieser der richtige ist und deswegen
        % genommen wird, ansonsten eben normal 'mk1oAa.set';
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
        
        nobase=EEG.data;  sdat=[];
        for s = 1:size(EEG.data,3);
            csweep=[];
            for c=1:size(EEG.data,1);
                cbase=EEG.data(c,:,s);
                cbase=mean(squeeze(cbase));
                cchan=EEG.data(c,:,s)-cbase;
                csweep=[csweep;cchan];
            end
            sdat=cat(3,sdat,csweep);
        end
        EEG.data=sdat
       

        DELTA = pop_eegfilt( EEG, filter(1), filter(2), [], [0]); 
        DELTA = eeg_checkset( DELTA );
        %delta_time = (round(DELTA.xmin*1000)):dt:(round(DELTA.xmax*1000));         
     
        %Definieren der Zeitfenster
        tp_A=TP_A(v,bed2);
        tp_A=round((tp_A+3000)/dt);
        anf_A=ceil(tp_A-del_win/2);
        end_A=ceil(tp_A+del_win/2);        
        
        tp_B=TP_B(v,bed2);
        tp_B=round((tp_B+3000)/dt);
        anf_B=ceil(tp_B-del_win/2);
        end_B=ceil(tp_B+del_win/2);
        
        %RMS für Zeitfenster 1
        del_1=DELTA.data(:,anf_A:end_A,:); 
 
        del_ss_1=mean((del_1.^2),2);  %  = rms wert basierend auf single sweeps
        del_ss_1=squeeze(sqrt(del_ss_1));
        del_ss_1=mean(del_ss_1,2);
     
        del_mv_1=mean(del_1,3);        %  = rms wert basierend auf mittelwerten    
        del_mv_1=mean((del_mv_1.^2),2);
        del_mv_1=squeeze(sqrt(del_mv_1));      
        
        %RMS für Zeitfenster 2
        del_2=DELTA.data(:,anf_B:end_B,:);

        del_ss_2=mean((del_2.^2),2); 
        del_ss_2=squeeze(sqrt(del_ss_2));
        del_ss_2=mean(del_ss_2,2);

        del_mv_2=mean(del_2,3);
        del_mv_2=mean((del_mv_2.^2),2);
        del_mv_2=squeeze(sqrt(del_mv_2));

        %Zusammenfügen der Werte
        del_ss_1_vp=[del_ss_1_vp, del_ss_1];     
        del_ss_2_vp=[del_ss_2_vp, del_ss_2];
        del_mv_1_vp=[del_mv_1_vp, del_mv_1];        
        del_mv_2_vp=[del_mv_2_vp, del_mv_2];


end


del_ss_1_vp=del_ss_1_vp';
eval(['del_ss_A_', bed, ' = del_ss_1_vp']);
del_ss_2_vp=del_ss_2_vp';
eval(['del_ss_B_', bed, ' = del_ss_2_vp']);
del_mv_1_vp=del_mv_1_vp';
eval(['del_mv_A_', bed, ' = del_mv_1_vp']);
del_mv_2_vp=del_mv_2_vp';
eval(['del_mv_B_', bed, ' = del_mv_2_vp']);


%{

%Erstellen des Formats: VPN * (Abwechselnd Elektrode TP_A, Elektrode TP_B)
del_ss=[]; del_mv=[];

for i=1:16;
    css_1=del_ss_1_vp(:,i);
    css_2=del_ss_2_vp(:,i);
    cmv_1=del_mv_1_vp(:,i);
    cmv_2=del_mv_2_vp(:,i);
    
    del_ss=[del_ss,css_1,css_2];
    del_mv=[del_mv,cmv_1,cmv_2];
end
    
    



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


% save('filename', 'var1', 'var2', ...) saves only the specified workspace 
% variables in filename.mat. Use the * wildcard to save only those 
% variables that match the specified pattern. For example, 
% save('A*') saves all variables that start with A.
%}
%}

 clear anf_A anf_B  anfang   TP_A   TP_B  bed  bed2 cmv_1 cmv_2  css_1  css_2 ...         
       del_1  del_2 del_mv  del_mv_1  del_mv_1_vp  del_mv_2 del_mv_2_vp del_ss...
       del_ss_1 del_ss_1_vp del_ss_2 del_ss_2_vp  del_win dt end_A...
       end_B ende1 ende2 file filter i konvertierung path path_save sf tp_A tp_B v vp                                  
