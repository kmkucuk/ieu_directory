% ERSP 


anfang = 'up';
vp = {'02' }; %'04' '07' '08' '12' '13' '15' '16' '18' '19' '20' '21'
bed ='4';
konvertierung = 'mk1'; % mk1: nach knopf / mk2: nach trigger
ende2 = 'oAa.set';
ende1 = 'oAa2.set';
del_win = 300; % Größe des Fensters, innerhalb dessen die mittlere ERSP ermittelt wird; in ms 

path ='C:\Dokumente und Einstellungen\FSC\Desktop\Diplomarbeit\set Dateien\oA\';
path_save = 'C:\Dokumente und Einstellungen\FSC\Desktop\Diplomarbeit\ERSP';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

del_ss_1_vp=[];del_ss_2_vp=[];del_mv_1_vp=[];del_mv_2_vp=[];
TP_vp=[];
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
        name=file(3:5);
        sf = 500; dt = 1000/sf; % sf = samplingfrequenz
        del_win=ceil(del_win/10); % von ms zu datenpunkten
    for c=1:size(par_kan);
    kan=par_kan(c);
    figure;
    [pow,itc,powbase,times,freqs] = pop_newtimef( ...    
    EEG, 1, kan, [-3000  998], [0] , ...
    'type', 'phasecoher',...
    'topovec', 5, ...
    'elocs', EEG.chanlocs, ...
    'chaninfo', EEG.chaninfo, ...
    'title', file, ...
    ...%'alpha', 0.05,...
    'padratio', 8, ...
    'timesout', [348.5], ...
    'plotphase','off', ...
    'baseline', [-3000 998], ...
    'freqs', [1 4]);
    %'plotitc','off'
       
    delta_time = round(times); 


    
    
    
    
    
    
    
    
    


        %Definieren der Zeitfenster
        tp_A=TP_A(v,1);
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