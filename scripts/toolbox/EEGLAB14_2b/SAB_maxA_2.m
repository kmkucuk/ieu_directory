% dieses Skript hilft zeitbereiche fuer die auswertung festzulegen
% es berechnet entweder fuer RMS-Werte oder fuer maximalAmplituden in
% "grossen" zeitbereichen wo die maximalste antwort fuer festgelegte
% elektroden zu erwarten ist
% Filterung beruht auf FFT
% Zeilen: VP; Spalten: Bedingungen

%% uebergabe der variablen
%clear all; %clc;
anfang = 'up';
vp = { '02' '04' }; %'02' '04''06' '07' '08' '12' '13' '15' '16' '18' '19' '20' '21'
bed = '2';

konvertierung = 'mk1'; % mk1: nach knopf / mk2: nach trigger
ende2 = 'oAa.set';
ende1 = 'oAa2.set';

path ='C:\Dokumente und Einstellungen\FSC\Desktop\Diplomarbeit\set Dateien\oA\';
path_save = 'C:\Dokumente und Einstellungen\FSC\Desktop\Diplomarbeit\set Dateien\oA\';

A = -2250 : -1250;
B = -500 : 400; % in welchem zeitbereich soll die maximale Aktivierung gesucht werden?
maxwin  = B; % Zeitfenster wählen, innerhalb dessen max gesucht wird; A== -3000 bis -1000; B== -1000 bis 1000;
par_kan = [4 5 12]; % welche kanaele um max-fenster festzulegen?
del_win = 500; % Größe des rms Fensters in ms
filter  = [0 4]; % fuer FFT: filtergrenzen (min max)



%% ab hier nichts mehr aendern
eeglab;
tpA_vp = [];  tpA_sweep = [];             %Schöne Schleife
for v = 1: size(vp,2)
    tpA_bed = [];horz = {};
    
        close all;
        
        %%%bitte pruefen!!!!%%%%
        % ich gehe hier davon aus, das wenn es einen file mit
        % 'mk1oAa2.set' am ende gibt dieser der richtige ist und deswegen
        % genommen wird, ansonsten eben normal 'mk1oAa.set';
        try
            file = [anfang,vp{v},bed,konvertierung, ende1]
            EEG = pop_loadset( 'filename', file,'filepath',path);
            
        catch
            file = [anfang,vp{v},bed,konvertierung,ende2]
            EEG = pop_loadset( 'filename', file,'filepath',path);
        end
        

        

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        sf = 500; dt = 1000/sf; % sf = samplingfrequenz
        del_win=ceil(del_win/dt); % von ms zu datenpunkten

        % EEG = pop_rmbase( EEG, [-3000 -2500]);
      
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
       
        
        DELTA = pop_eegfilt( EEG, filter(1), filter(2), [], [0]); %sehr elegant!!
        DELTA = eeg_checkset( DELTA );
        delta_time = (round(DELTA.xmin*1000)):dt:(round(DELTA.xmax*1000)); 

        % zeitbereiche von maxwin aus delta_time raussuchen
        A1 = find(delta_time == maxwin(1)); %finde, bei welchem index delta_time gleich dem Wert von maxwin beim index 1 ist
        A_end = find(delta_time == maxwin(end));
        win = delta_time(A1:A_end);


       
                
                for i = 1: size(DELTA.data,3) % fuer jeden sweep
                    tpA_kan = []; max_kan = []; tpA_kan2=[];
                    figure  % macht abbildungen fuer jeden sweep
                    for j = 1: length(par_kan)
                        mdata=DELTA.data(j,A1:A_end,i)'; % kanal x zeit x sweep


                        %finden von allen maxima/minima in diesem kanal
                        dif = mdata(2:end) - mdata(1:(end-1));
                        forward_diff = [dif;0];
                        backward_diff = [0; dif];

                        % datenpunkt-nr = zeitpunkt aller maxima
                        indmax = find((forward_diff < 0) & (backward_diff > 0));
                        % wo wird der nächste punkt nicht mehr größer UND
                        % wo war der letzte kleiner

                        % datenpunkt-wert = amplitude aller maxima + davon das
                        % groesste
                        peakmax = mdata(indmax); % alle lokalen maxima
                        peakmax = max(peakmax);  % davon das maximum (= ein amplitudenwert)

                        
                        max_zeitpkt = find (peakmax == mdata); %index des maximums innerhalb des gewählten Fensters
                        
                        max_zeitpkt2 = max_zeitpkt + A1 - 1; % index des maximums im gesamtarray der Datenpunkte)
                        tpA_kan2 = [tpA_kan2,delta_time(max_zeitpkt2)];
                        
                        tpA_kan = [tpA_kan,max_zeitpkt]; % indizes der maxima der drei kanäle
                       
                       
                        
                        max_kan = [max_kan, peakmax]; % die drei maxima von par für den aktuellen sweep
                        plot(delta_time, DELTA.data(j,:,i))
                        hold on
                        
                        
                        
                        
                        
                    end %par zeitpunktsuche
                        plot(tpA_kan2, max_kan, 'rx')
                        hold off
                        set(gca,'ydir', 'reverse')
                    
                       tpA = median(tpA_kan); % medianer index    
                       
                       
                       
                       tpA_sweep=[tpA_sweep,tpA]; %mediane indizes aller sweeps   
                        %{
                        max_zeitpkt = max_zeitpkt + A1 - 1; % index des maximums im gesamtarray der Datenpunkte)
                        max_zeitpkt = delta_time(max_zeitpkt);
                        tpA_kan = [tpA_kan,delta_time(max_zeitpkt)]; % umwandlung in ms; zeitpunke der drei kanälen
                        max_kan = [max_kan, peakmax]; % werte der 3 kanäle
                        %}
                       

                end %sweeps
                
                % in welchem zeitbereich wurden die maximas gefunden - um
                % zeitfenster zu bilden
                tpA_min = min(min(tpA_sweep));
                tpA_max = max(max(tpA_sweep));

                disp ('median   min   max');
                [tpA tpA_min tpA_max]
                    
end % vp

    tpA_vp = [tpA_vp, tpA_sweep];
    eval(['TP_', bed, '= tpA_vp']);
    close all;