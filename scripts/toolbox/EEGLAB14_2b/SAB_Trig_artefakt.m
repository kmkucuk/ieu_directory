function [vp, data] = SAB_Trig_artefakt (vp_bez, sweepl, wastun, kanal_a,kanal_p, f_thresh, m_thresh, fenster)
%
% Das Programm sucht Artefakte nach 3 kriterien:
% 1. wird ein festgelegter threshold überschritten (z.b 80 oder 100 µV)
% 2. kommt es zu spikes / muskelartefakten über einen festgelegten threshold hinaus (z.b. 50µV)
% 3. manuelle moeglichkeit die epochen rauszusuchen die weitere artefakte haben (z.b. zu geringe amplituden, drifts)
%
% Es werden Abbildungen zu allen sweeps gemacht und nach den Kriterien 1
% und 2 je in rot (mit Artefakt) oder blau (ohne Artefakt) gekennzeichnet.
% Anschließend kann man diese Zuordnung manuell korrigieren - eine
% Eingabeaufforderung erfolgt automatisch.
% 
% Eingabe:
% vp_bez: 'string': name des datenfiles
% sweepl: 'string': name der gewuenschten sweepliste im datenfile (z.B. odk); Achtung! nur angeben was nach ind_sweeps_ folgt !
% was tun: 
%       - 'nurfest' bedeutet wenn ein datenpunkt innerhalb von fenster
%          groesser als f_thresh µV ist, der sweep als artefakt gilt (d.h.
%          nur Kriterium 1)
%       - 'festundmuskel' bedeutet das zusaetzlich ein ploetzlicher Sprung
%          von m_thresh µV ebenfalls als artefakt gilt (d.h. Kriterium 1
%          und 2)
% kanal_a: [array]: welche kanaele fuer die artefaktbereinigung  - die nummer in 2.dim des daten- arrays
            % (es bietet sich an nur kopfkanaele zu nehmen, denn schwitzartefakte im EOG
            % interesssieren nicht, ebenso kann man kaputte kanaele die global raus muessen rauslassen)
% kanal_p: [array]: zusaetzlich zu kanal_a: welche kanaele sollen geplottet werden?:(nummer in 2. dim des daten-arrays)
            % hier unbedingt EOG, ggf. trigger-kanal, nachdem die daten
            % konvertiert wurden und kaputte kanaele
% f_thresh: zahl: fester threshold zu kriterium 1,ab wann daten als artefakt gelten, z.b. wenn vp viel alpha hat koente der groesser sein 
% m_thresh: zahl: fester threshold zu kriterium 2,ab wann ploetzlicher sprung in daten als artefakt gilt
% fenster: [anfang  ende]: wenn einen artefakte nur in best. zeitfenster
%           interessieren; ALS ZEITBEREICH ANGEBEN, z.B. -500 bis 1000
%
% 
% Beispiel:
% [vp, data] = SAB_Trig_artefakt ('up023K14_1500_500', 'odk_minus500_bis_200', 'festundmuskel', [1:9,11,12],[10,14], 80, 80,[-2000 750]);
% 
% Ausgabe: 
% vp --> hat sich jetzt veraendert fuer:
% vp.sweeplisten.(ind_sweeps_oA) = aus sweepl (z.b. alle oder odk, siehe skript zum  konvertieren): die sweepnummern von alle, d.h. die indizies
%                                  der dim3 von daten die ohne artefakte sind
% vp.Times.(tachse_sweeps_oA) = Zeitachse in der die sweeps nach Artefakten betrachtet wurden
% vp.info.(['Erstellung_von_', ind_sweeps_oA]).(nummer) = information
%                                  darueber welche sweepliste zum artefakt korrigieren benutzt wurde, 
%                                  z.b. odk, denn dann waren u.U. schon von vornerein einige sweeps raus 
%                                  oder das programm wird 2mal benutzt dann die sweepliste mit dem gleichen
%                                  namen, hier werden immer alle
%                                  durchgaenge abgespeichert ("nummer")
% Achtung: die bezeichnungen von ind_sweeps_oA sowie tachse_sweeps_oA
            % beinhalten von fenster(1) und fenster(end), d.h. man braucht den Times
            % array um den wirklichen zeitbereich sicherzustellen --> irgendwie habe
            % ich das abspeichern mit minuszeichen nicht hinbekommen
            % die absolutwerte von 
% Achtung: die neue variable vp wird mit der alten bezeichnung uebergespeichert
% 
% ggf. data: zum einladen der daten in eeglab per Hand
% 

%% bitte kontrollieren

path ='/home/eegdaten/dat/SAB_Trig/mat_konv/';
%path = '/Volumes/DATA/Arbeit/EEGlabor/FORSCHUNG/SAB_Trigger/Konvertiert/';
tr = 13; % ab welchem kanal folgen keine kopfkanaele oder EOG mehr?
    
%% heraussuchen der notwendigen Variablen aus vp
 close all; clc
load([path, vp_bez, '.mat'])

d = vp.data;
ind_sw = vp.sweeplisten.(['ind_sweeps_', sweepl]);
sf = vp.info.samplingfrequenz;
kanalnamen = vp.info.kanalnamen;

% finden des zeitarrays fuer die daten, d.h. alle
% ACHTUNG: davon sollte es nur eine variable geben!
times_alle = fieldnames(vp.Times);
for i = 1: size(times_alle,1)
    if isempty(strfind(char(times_alle(i)), 'alle'  )) == 0;
        ti = char(times_alle{i}); % name der sweepliste
        times = vp.Times.(ti); % daten der sweepliste
    end   
end
% in times die indizies des relevanten zeitfensters "fenster" finden
ind_ti = find (times >= fenster(1) & times <= fenster(end)); % indizies in times

% daten mit allen kanaelen, aber reduziert auf sweeps und zeitbereich, der
% nach
% artefakten durchgesehen werden soll
data = d(ind_ti, :, ind_sw(:,1)); % timepoi x kanal x sweep


%% ab hier nichts mehr aendern 

%wieviele sweeps gibt es
sw = size(data, 3);

% % BERECHNUNG VON PEAK TO PEAK : nur artefakt-bereinigungs-ausschnitt!
switch (wastun)
    case {'festundmuskel'}
        peaktopeak = [];
        for i = 1:sw
           peak = [];
           for k = 1:length(kanal_a)
                dummy = data(:,kanal_a(k),i);
                diff = dummy(2:end) - dummy(1:(end-1)); %berechnung von peak zu peak
                peak = cat(2, peak,diff);
            end
            peaktopeak = cat(3,peaktopeak,peak);
            
        end
end
 

% entscheidung fuer jeden sweep ob mit oder ohne artefakt
mit = []; ohne = []; mit_nummer = []; ohne_nummer = [];
kanal = [kanal_a, kanal_p];
for i = 1: sw

    % maximaler ausschlag von daten, kriterium für jeden sweep einzeln
    % dort aber über die daten aller kanäle zs und nur im gesuchten zeitfenster
    % und relevante kanaele (kanal_a)!!!!
    test = max(abs(data (:,kanal_a,i)));
    test_max = max(test);

    switch (wastun)
        case {'nurfest'}
            if test_max >= f_thresh
                mit = cat(3,mit, data (:,kanal,i));
                % zum behalten der ursprungssweepnr.von daten
                mit_nummer = cat(1,mit_nummer,ind_sw(i));
            else            
                ohne = cat(3,ohne, data (:,kanal,i));
                ohne_nummer = cat(1,ohne_nummer,ind_sw(i));
            end


        case {'festundmuskel'}
            %  testen ob peaktopeak-threshold überschritten, dabei letzten kanal(EOG) raus.
            test_peak = max(abs(peaktopeak (:,:,i)));
            test_max_peak = max(test_peak);

            if test_max >= f_thresh |  test_max_peak >= m_thresh
                mit = cat(3,mit, data (:,kanal,i));
                % zum behalten der ursprungssweepnr.von daten
                mit_nummer = cat(1,mit_nummer,ind_sw(i));
            else
                ohne = cat(3,ohne, data (:,kanal,i));
                ohne_nummer = cat(1,ohne_nummer,ind_sw(i));
            end

    end

end


%% ABBILDUNGEN und manuelle Kontrolle
    

kanalnamen = kanalnamen(kanal)
zeigen = 1;


while zeigen == 1
    % mit_nummer
    % ohne_nummer
    mi = size(mit_nummer, 1);
    oh = size(ohne_nummer,1);
    for i = 1:mi
        figure(1)
        for k = 1:size(kanal,2)
            subplot(size(kanal,2),1,k), b = plot(times(ind_ti),mit(:,k,i));
            set(gca,'YDir','reverse','box','off', 'linewidth', 1,'color', 'none')
            set (b,'LineWidth',2 , 'LineStyle','-',  'Color',[1 0 0 ]) % COL-FIG

            if kanal(k)< tr
                ylim ([ -1*f_thresh f_thresh]);
                ylabel(sprintf ('%s', kanalnamen{k}))
                H = get(gca, 'position');
                set(gca, 'position', [H(1) H(2) H(3) (H(4)+0.04)]) %LEFT BOTTOM WIDTH HEIGHT
            end

            if k == 1
                t =  title(sprintf ('mit Artefakt / Sweep Nr. %d', mit_nummer(i)));
                set(t, 'FontWeight' , 'bold', 'Fontsize', 16)
            end
        end
        pause
    end

    for i = 1:oh
        % figure
        for k = 1:size(kanal,2)
            subplot(size(kanal,2),1,k), b = plot(times(ind_ti),ohne(:,k,i));
            set(gca,'YDir','reverse','box','off', 'linewidth', 1,'color', 'none')
            set (b,'LineWidth',2 , 'LineStyle','-',  'Color',[0 0 1 ]) % COL-FIG

            if kanal(k)< tr
                ylim ([ -1*f_thresh f_thresh]);
                ylabel(sprintf ('%s', kanalnamen{k}))
                H = get(gca, 'position');
                set(gca, 'position', [H(1) H(2) H(3) (H(4)+0.04)]) %LEFT BOTTOM WIDTH HEIGHT
            end

            if k == 1
                t = title(sprintf ('ohne Artefakt / Sweep Nr. %d', ohne_nummer(i)));
                set(t, 'FontWeight' , 'bold', 'Fontsize', 16)
            end
        end
        pause
    end


     % nachfrage ob aendern und nochmal alle zeigen
     fr = input('Waren Sweeps mit Artefakt eigentlich ohne? Ja oder Nein? : ');
     switch fr 
         case {'Ja', 'ja'}
             krit_1 = input('Welche Sweeps mit Artefakt waren falsch? Bsp. [2 5 8]: ');
             % raussuchen der indizies fuer sweepnummer die als falsch
             % angegeben wurden
             for i = 1:length(krit_1)
                 fi(i) = find(krit_1(i) == mit_nummer);
             end

             % neu einordnen als ohne artefakt
             ohne_nummer = cat(1, ohne_nummer, mit_nummer(fi));
             ohne = cat(3, ohne, mit(:,:,fi));
             % sweepliste wieder der reihe nach ordnen, aber so, daß man es mit
             % den daten auch machen kann
             ohne_n = sort(ohne_nummer);
             ohne_zw = [];
             for i = 1: length(ohne_n)
                 oh_fi = find(ohne_n(i) == ohne_nummer);
                 ohne_zw = cat(3, ohne_zw, ohne(:,:,oh_fi));
             end
             ohne = ohne_zw; ohne_nummer = ohne_n;
             
             % rausloeschen in liste mit artefakt
             mit(:,:,fi) = [];
             mit_nummer(fi) = [];

     end
     
     fr = input('Waren Sweeps ohne Artefakt eigentlich mit? Ja oder Nein? : ');
     switch (fr) 
         case {'Ja', 'ja'}
             krit_2 = input('Welche Sweeps ohne Artefakt waren falsch? Bsp. [7 9 11]:');
             % raussuchen der indizies fuer sweepnummer die als falsch
             % angegeben wurden
             for i = 1:length(krit_2)
                 fi(i) = find(krit_2(i) == ohne_nummer);
             end

             % neu einordnen als mit artefakt
             mit_nummer = cat(1, mit_nummer, ohne_nummer(fi));
             mit = cat(3, mit, ohne(:,:,fi));
             % sweepliste wieder der reihe nach ordnen, aber so, daß man es mit
             % den daten auch machen kann
             mit_n = sort(mit_nummer);
             mit_zw = [];
             for i = 1: length(mit_n)
                 mi_fi = find(mit_n(i) == mit_nummer);
                 mit_zw = cat(3, mit_zw, mit(:,:,mi_fi));
             end
             mit = mit_zw; mit_nummer = mit_n;

             % rausloeschen in liste ohne artefakte
             ohne(:,:,fi) = [];
             ohne_nummer(fi) = [];
     end
     
     fr = input('Alle Abbildungen nochmal zeigen? Ja oder Nein? : ');  
     switch(fr) 
         case {'Nein', 'nein'}
             zeigen = 2;
     end
end

%% umbenennen und abspeichern (sweepl und times)

tachse_sweeps_oA =  sprintf('%s%1.0f%s%1.0f','Times_oA_', abs(fenster(1)), '_bis_', abs(fenster(end)));
vp.Times.(tachse_sweeps_oA) = times(ind_ti);

for i = 1: length(ohne_nummer)
    fi(i) = find(ohne_nummer(i) == ind_sw(:,1));
end
sweepl_ges = ind_sw(fi,:)
ohne_nummer; % kontrolle

ind_sweeps_oA =  sprintf('%s%1.0f%s%1.0f','ind_sweeps_oA_', abs(fenster(1)), '_bis_', abs(fenster(end)));
vp.sweeplisten.(ind_sweeps_oA) = sweepl_ges;

try
    si = size(fieldnames(vp.info.(['Erstellung_von_', ind_sweeps_oA])));
    fi_n = sprintf('%s%1.0f', 'v', si(1)+1);
    vp.info.(['Erstellung_von_', ind_sweeps_oA]).(fi_n) = sprintf('%s%s%s%d%s%d', 'Die erstellte Sweepliste basiert auf ind_sweeps_', sweepl, '_artefaktfreier Zeitbereich (siehe auch times): ', fenster(1), 'bis', fenster(end));
catch
    fi_n = sprintf('%s%1.0f', 'v', 1);
    vp.info.(['Erstellung_von_', ind_sweeps_oA]).(fi_n) = sprintf('%s%s%s%d%s%d', 'Die erstellte Sweepliste basiert auf ind_sweeps_', sweepl, '_artefaktfreier Zeitbereich (siehe auch times): ', fenster(1), 'bis', fenster(end));
end

% speichern
dateiname = sprintf('%s%s', path,vp_bez)
save(dateiname, 'vp');

close all

%% einladen in eeglab per hand
d = vp.data; % holt daten aus struct
sw = vp.sweeplisten.(ind_sweeps_oA); % holt die richtigen indizies zum erstellen der gesuchten sweepliste aus struct 
                                                      % !!! hier immer den richtigen namen einsetzen !!!
sw = sw(:,1);
data = d(:,:,sw);% erstellt datenarray NUR mit erwuenschten sweeps
data = permute(data,[2 1 3]);  % baut die daten in richtige structur von eeglab


