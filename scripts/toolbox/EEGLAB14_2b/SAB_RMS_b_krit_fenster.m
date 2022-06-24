% dieses Skript hilft zeitbereiche fuer die auswertung festzulegen
% es berechnet entweder fuer RMS-Werte oder fuer maximalAmplituden in
% "grossen" zeitbereichen wo die maximalste antwort fuer festgelegte
% elektroden zu erwarten ist
% Filterung beruht auf FFT
% Zeilen: VP; Spalten: Bedingungen

%% uebergabe der variablen
%clear all; %clc;
anfang = 'up';
vp = {'02' '04' '06' '07' '08' '12' '13' '15' '16' '18' '19' '20' '21'}; % 
bed = {'2'};
konvertierung = 'mk1'; % mk1: nach knopf / mk2: nach trigger
ende2 = 'oAa.set';
ende1 = 'oAa2.set';

path ='C:\Dokumente und Einstellungen\FSC\Desktop\Diplomarbeit\set Dateien\oA\';
path_save = 'C:\Dokumente und Einstellungen\FSC\Desktop\Diplomarbeit\set Dateien\oA\';

A = -2500 : -1000;
B = -750 : 400; % in welchem zeitbereich soll die maximale Aktivierung gesucht werden?
maxwin  = B; % Zeitfenster w‰hlen, innerhalb dessen max gesucht wird; A== -3000 bis -1000; B== -1000 bis 1000;
par_kan = [4 5 12]; % welche kanaele um max-fenster festzulegen?
del_win = 500; % Grˆﬂe des rms Fensters in ms
filter  = [0 4]; % fuer FFT: filtergrenzen (min max)

todo = 'rms'; %'rms' oder 'maxA'

%% ab hier nichts mehr aendern
eeglab;
tpA_vp = [];              %Schˆne Schleife
for v = 1: size(vp,2)
    tpA_bed = [];horz = {};
    for b = 1:size(bed,2)
        close all;
        
        %%%bitte pruefen!!!!%%%%
        % ich gehe hier davon aus, das wenn es einen file mit
        % 'mk1oAa2.set' am ende gibt dieser der richtige ist und deswegen
        % genommen wird, ansonsten eben normal 'mk1oAa.set';
        try
            file = [anfang,vp{v},bed{b},konvertierung, ende1]
            EEG = pop_loadset( 'filename', file,'filepath',path);
            
        catch
            file = [anfang,vp{v},bed{b},konvertierung,ende2]
            EEG = pop_loadset( 'filename', file,'filepath',path);
        end
        

        

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        sf = 500; dt = 1000/sf; % sf = samplingfrequenz
        del_win=ceil(del_win/dt); % von ms zu datenpunkten
%{
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
  %}      
        
        DELTA = pop_eegfilt( EEG, filter(1), filter(2), [], [0]); %sehr elegant!!
        DELTA = eeg_checkset( DELTA );
        delta_time = (round(DELTA.xmin*1000)):dt:(round(DELTA.xmax*1000)); 

        % zeitbereiche von maxwin aus delta_time raussuchen
        A1 = find(delta_time == maxwin(1)); %finde, bei welchem index delta_time gleich dem Wert von maxwin beim index 1 ist
        A_end = find(delta_time == maxwin(end));
        win = delta_time(A1:A_end);


        switch todo
            case 'rms'

                % berechnung der delta-RMS-werte fuer jeden einzelsweep fuer parietale
                % kanaele in zeitfenster win
                rmsvec=[];
                for i= 1: length(win) - del_win;
                    cdata=DELTA.data(:,A1-1+i: A1-1+i+del_win,:); % -1 damit man bei A1 anfaengt, denn es wird ja immer mindestens +1 dazugerechnet (i)
                    cdata=cdata(par_kan,:,:); % kanal x zeit x sweep

                    crms=sqrt(mean((cdata.^2),2)); % RMS-Wert fuer jeden einzelsweep
                    crms=squeeze(crms); % kanal x sweep
                    crms=mean(crms,2); % mittel ueber einzelsweeps
                    rmsvec=[rmsvec, crms];  % vektor mit s‰mtl. rms werten
                end

                rmsvecP=mean(rmsvec,1); % mittelung ¸ber kanaele (parietal)
                [val, ind]=max(rmsvecP) % wert und index des maximalwertes innerhalb des untersuchten array
                
                
                
                
                % aus dem index den datenpunkt in den gesamten datenarray heraussuchen UND
                % umrechnen von ind: ind bezieht sich auf zeitfenster von ind bis ind +
                % del_win --> der zeitpunkt ist daher besser als die mitte dieses zeitfensters
                % beschrieben

                ind = ind + round(del_win/2) % datenpunkt der mitte des rms-zeitfensters
                ind = A1 + ind -1 % datenpunkt im gesamten array
                tpA = delta_time(ind)  % zeitpunkt in ms dem val entspricht

            case 'maxA'
                tpA_sweep = [];
                for i = 1: size(DELTA.data,3) % fuer jeden sweep
                    tpA_kan = []; max_kan = [];
                    %figure  % macht abbildungen fuer jeden sweep
                    for j = 1: length(par_kan)
                        mdata=DELTA.data(j,A1:A_end,i)'; % kanal x zeit x sweep


                        %finden von allen maxima/minima in diesem kanal
                        dif = mdata(2:end) - mdata(1:(end-1));
                        forward_diff = [dif;0];
                        backward_diff = [0; dif];

                        % datenpunkt-nr = zeitpunkt aller maxima
                        indmax = find((forward_diff < 0) & (backward_diff > 0));

                        % datenpunkt-wert = amplitude aller maxima + davon das
                        % groesste
                        peakmax = mdata(indmax);
                        peakmax = max(peakmax);

                        % datenpunkt des peakmax im gesamten sweep
                        max_zeitpkt = find (peakmax == mdata);
                        max_zeitpkt = max_zeitpkt + A1 - 1;
                        tpA_kan = [tpA_kan,delta_time(max_zeitpkt)];
                        max_kan = [max_kan, peakmax];

                        %plot(delta_time, DELTA.data(j,:,i))
                        %hold on

                    end

                    %plot(tpA_kan, max_kan, 'rx')
                    %hold off
                    %set(gca,'ydir', 'reverse')

                    tpA_sweep = cat(1,tpA_sweep, tpA_kan);
                end

                % zu welchen zeitpunkt, wenn man mit diesem einen zeitbereich
                % bildet, trifft man mit groesster sicherheit auf die maximalsten
                % positiven auspraegungen?
                % median statt mean: den datenpunkt gibt es wirkich + meistens gibt
                % es "haeufungen" mit maximal einem ausreiﬂer, d.h. median trifft
                % das ganz gut
                tpA = median(median(tpA_sweep));

                % in welchem zeitbereich wurden die maximas gefunden - um
                % zeitfenster zu bilden
                tpA_min = min(min(tpA_sweep));
                tpA_max = max(max(tpA_sweep));

                disp ('median   min   max');
                [tpA tpA_min tpA_max]
        end % switch
        
        
        tpA_bed = cat(2,tpA_bed, tpA);

    end % b = bed
  
    tpA_vp = cat(1,tpA_vp, tpA_bed);
    

end % v = vp


%% absichern als mat-datei
%Benennung
kanal = [];
for i = 1:length(par_kan)
k = num2str(par_kan(i)); 
kanal = [kanal,'_',k]
end
anfang = num2str(A(1)); ende = num2str(A(end)); f_anfang = num2str(filter(1)); f_ende = num2str(filter(end));
datei = sprintf('%s', 'kritfenster_', todo, '_zf_','A' , '_fil_', f_anfang, '_', f_ende, '_chan', kanal)
dateiname = [path_save, datei];


%sichern
save(dateiname,'tpA_vp','bed','vp')
