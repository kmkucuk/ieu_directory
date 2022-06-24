%ausgangsvariablen TP_bed_A und TP_bed_B; bed = 2_4 | 3_5
%% uebergabe der variablen
%clear all; %clc;
anfang = 'up';
vp = { '04' }; %'02' '06' '07' '08' '12' '13' '15' '16' '18' '19' '20' '21'
bed = {'5'};
konvertierung = 'mk1'; % mk1: nach knopf / mk2: nach trigger
ende2 = 'oAa.set';
ende1 = 'oAa2.set';

path ='C:\Dokumente und Einstellungen\FSC\Desktop\Diplomarbeit\set Dateien\oA\';
path_save = 'C:\Dokumente und Einstellungen\FSC\Desktop\Diplomarbeit\set Dateien\oA\';

del_win = 500; % Größe des rms Fensters in ms
filter  = [0 4]; % fuer FFT: filtergrenzen (min max)

eeglab;
tpA_vp = [];              %Schöne Schleife
for v = 1: size(vp,2)
    tpA_bed = [];horz = {};
        close all;
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
        
        for e=1:size(DELTA.data,3);
            t=e;
            tpA=TP_A(t);
            
            
            for k=1:size(DELTA.data,1);
                cdata=(k,win,e);
                
        
         %Definieren der Zeitfenster
        start=abs(xmin*1000)
        sw=size(DELTA.data,3);
        sw=TP
%!!!!!! tp_A=TP_A(v,1); % TP_A sind noch indizes, nicht Zeitpunkte in ms!!!!!!!!
        
        
        
        tp_A=round((tp_A+start)/dt);
        anf_A=ceil(tp_A-del_win/2);
        end_A=ceil(tp_A+del_win/2);        
        
        tp_B=TP_B(v,1);
        tp_B=round((tp_B+start)/dt);
        anf_B=ceil(tp_B-del_win/2);
        end_B=ceil(tp_B+del_win/2);
        
        anf=[('anf_A'),('anf_B');
        end=[('end_A'),('end_B');
        del_amp_1=[]; del_amp_2=[];
        
        for t=1:2;
                tpA_sweep = [];
                for i = 1: size(DELTA.data,3) % fuer jeden sweep
                    tpA_kan = []; max_kan = [];
                    figure  % macht abbildungen fuer jeden sweep
                    for j = 1: size(DELTA.data,1)
                        mdata_A=DELTA.data(j,anf(t):end(t),i)'; % kanal x zeit x sweep

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

                        % datenpunkt des peakmax im gesamten sweep
                        max_zeitpkt = find (peakmax == mdata);
                        max_zeitpkt = max_zeitpkt + A1 - 1; % index des maximums im gesamtarray der Datenpunkte)
                        tpA_kan = [tpA_kan,delta_time(max_zeitpkt)]; % umwandlung in ms; zeitpunke der drei kanälen
                        max_kan = [max_kan, peakmax]; % werte der 3 kanäle

                        plot(delta_time, DELTA.data(j,:,i))
                        hold on

                    end %topo

                    plot(tpA_kan, max_kan, 'rx')
                    hold off
                    set(gca,'ydir', 'reverse')

                    tpA_sweep = cat(1,tpA_sweep, max_kan);
                end % sweep
                
                maxA1 = median(tpA_sweep);
                maxA1 = mean(tpA_sweep);
                % in welchem zeitbereich wurden die maximas gefunden - um
                % zeitfenster zu bilden
                
        end %tp
        
        maxA=[maxA,maxA1];
       
    end %vp
  
    maxA_vp = cat(1, maxA_vp, maxA);
    maxA_A=maxA_vp(:,1:16);
    maxA_B=maxA_vp(:,17:32);
eval(['maxA_A_' name ' = maxA_A'])
eval(['maxA_B_' name ' = maxA_B'])