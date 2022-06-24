% ERSP Zeitpunkt

%% uebergabe der variablen
%clear all; %clc;
anfang = 'up';
vp = {'02' }; %'04' '07' '08' '12' '13' '15' '16' '18' '19' '20' '21'
bed ='4';
%bed2 = 1 ; 
konvertierung = 'mk1'; % mk1: nach knopf / mk2: nach trigger
ende2 = 'oAa.set';
ende1 = 'oAa2.set';

A = -2504 : -1007; %-2504 : -1007    
B = -755 : 400; %  -755 : 400 in welchem zeitbereich soll die maximale Aktivierung gesucht werden?
maxwin  = A; % Zeitfenster wählen, innerhalb dessen max gesucht wird; 
par_kan = [4 5 12]; % welche kanaele um max-fenster festzulegen?
del_win = 300; % Größe des Fensters, innerhalb dessen die mittlere ERSP ermittelt wird; in ms 
% filter  = [0 4]; % fuer FFT: filtergrenzen (min max)

path ='C:\Dokumente und Einstellungen\FSC\Desktop\Diplomarbeit\set Dateien\oA\';
path_save = 'C:\Dokumente und Einstellungen\FSC\Desktop\Diplomarbeit\ERSP';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% del_ss_1_vp=[];del_ss_2_vp=[];del_mv_1_vp=[];del_mv_2_vp=[];
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
        %sf = 500; dt = 1000/sf; % sf = samplingfrequenz
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
        % zeitbereiche von maxwin aus delta_time raussuchen
        A1 = find(delta_time == maxwin(1)); %finde, bei welchem index delta_time gleich dem Wert von maxwin beim index 1 ist
        A_end = find(delta_time == maxwin(end));
        win = delta_time(A1:A_end);

                % berechnung der ERSP fuer jeden einzelsweep fuer parietale
                % kanaele in zeitfenster win
                erspvec=[];
                for i= 1: (length(win) - del_win);
                    cdata=pow(:,A1-1+i: A1-1+i+del_win); % -1 damit man bei A1 anfaengt, denn es wird ja immer mindestens +1 dazugerechnet (i)
                    %cdata=cdata(par_kan,:,:); % kanal x zeit x sweep
                    cdata=mean(mean(cdata));
                    cdata=squeeze(cdata);
                    erspvec=[erspvec, cdata];  % vektor mit sämtl. ersp werten
                end
                  
                 erspvecP=(erspvecP;erspvec); % mittelung über kanaele (parietal)
                 erspvecP=mean(erspvecP);
                 [val, ind]=max(erspvecP) % wert und index des maximalwertes innerhalb des untersuchten array
    end
                

                ind = ind + round(del_win/2) % datenpunkt der mitte des rms-zeitfensters
                ind2 = A1 + ind -1 % datenpunkt im gesamten array
                TP = delta_time(ind2)  % zeitpunkt in ms dem val entspricht
                TP_vp=[TP_vp;TP];
                eval(['TP_ersp_', bed, ' = TP_vp']);

    

end 

    
 