function [vp,data, D ] = SAB_Trigger_konvertieren(konvert, anfang, ende, anfang_krit, ende_krit, trig_kanal, kratz);

% EINGABE
% konvert = name des unkonvertierten braindata-files (ohne k!!)
% anfang = datenpunkte (NICHT ms!!) vor dem knopf bzw. einer weniger: wenn z.b. anfang = 1500, heißt es 1499 punkte vor dem knopf und 1500 ist der nullpunkt 
% ende = datenpunkte nach dem Knopf
% anfang_krit = datenpunkte vor dem knopf in dem kein knopfdruck erlaubt ist (regel wie bei anfang)
% ende_krit = datenpunkte nach dem knopf in dem kein knopfdruck erlaubt ist
% trig_kanal = nach welchem Kanal soll konvertiert werden: z.B. 13: Trigger, 14: Knopf
% kratz = anzahl der datenpunkte, die 2 gefundene trigger mind. auseinander sein muessen um nicht als "kratzen" von einem knopfdruck zu zählen
% 
% Beispiel : [vp,data, D] = konvertieren_SAB_Trigger2('up023', 1500, 500, 250, 100, 14, 6);
% 
% Beachten und ggf. aendern im Skript:
% siehe path und path_save: anpassen, damit man es nicht jedesmal mit uebergeben muss !!!
%
% AUSGABE
% struct: vp --> wird auch abgespeichert!!!
% vp.data --> alle konvertierten sweeps als 3dim matrix (timepoi x kanal x sweep)
% vp.info --> nr_reversals: enthält die anzahl aller knopfdrücke (allerdings ohne "kratzen", letztlich size (vp.data,3)) 
%                           für statistik in Reversion pro minute umrechnen!!! 
%         --> trigger_kanal: nach welchem Kanal konvertiert wurde, z.b. k14: knopf, K13: musterwechsel
%         --> data: info ueber aufbau der datenmatrix (timepoi x kanal x sweep)
%         --> name: name des files der konvertiert wurde
% vp.times --> davon kann es diverse geben, u.a. alle und odk (ohne
%         doppelknopf): array mit den zeitachsen von wann bis wann ein
%         sweep geht (alle) bzw von wann bis wann jeder sweep
%         rausgeschmissen wurde, wenn es einen 2. knopfdruck gab (odk)
%         ACHTUNG!! im Gegensazu zur EINGABE ist die AUSGABE von times nicht
%         in Datenpunkten sondern in ms
%         ACHTUNG!! Annahme, das samplingfrequenz = 500 Hz; sonst Skript
%         adaptieren!!!!!!!
% vp.sweeplisten --> davon kann es diverse geben, haben immer 2 spalten
%                --> spalte 1: welche indizies die sweeps dieser sweepliste
%                in der datenmatrix vp.data haben (bezug zur 3dim)
%                --> spalte 2. welche datenpunkte des arrays D, d.h. wenn
%                alle rohdaten aneinandergekettet wurden, dem nullpunkt
%                des jeweiligen sweeps entsprechen
%                --> alle: von allen sweeps, d.h. wie vp.data
%                --> odk: die sweeps bei denen in dem kritischen zeitbereich (siehe restliche bezeichnung der sweepliste) 
%                keine doppelten knopfdrücke auftauchen
%
% fuer die bennennungenn der vp.times und vp.sweeplisten gibt es immer eine angabe in
% datenpunkten: siehe anfang/ende/anfang_krit und ende_krit fuer logik, v.a. auch bei welchem datenpunkt der nullpunkt liegt, 
% s.a. die arrays von vp.times selbst
%
% ggf. wird data  ausgegeben (entspricht vp.data, aber 1) nur von den odk-sweeps und 2) in der dim-reihenfolge 
% so daß man daten in eeglab einladen kann: kan x timepoi x sweep)
%
% ggf. wird D (rohdatenarray) ausgegeben, aber nicht abgespeichert 
%
% bis Strich: v.a. ingos Werk: erklärung zum knopffinden:
% krit_1 = sprung zwischen zwei Punkten groesser als krit_1 , d.h. knopf anfang oder ende?
% krit_2 = War bei diesem Sprung der erste Klein genug, daß er schon kleiner als krit_2 also "im schlauch", also Knopfanfang? 

%% bitte kontrollieren

path = '/Volumes/DATA/Arbeit/EEGlabor/FORSCHUNG/SAB_Trigger/Rohdaten/';
path_save ='/Volumes/DATA/Arbeit/EEGlabor/FORSCHUNG/SAB_Trigger/Konvertiert/';
%path ='/home/eegdaten/dat/SAB_Trig/Rohdaten/';
%path_save = '/home/eegdaten/dat/SAB_Trig/mat_konv/';

disp('bitte kontrollieren, sonst im skript aendern:');
sf = 500 % samplingfrequenz
kanalnamen = {'Cz' 'C3' 'C4' 'P3' 'P4' 'O1' 'O2' 'F3' 'F4' 'EOG' 'Fz' 'Pz' 'trigger_wechsel' 'Knopf'  'leer' 'trigger_alle'}'

%% ab hier nichts mehr aendern

% konvertieren der rohdaten (ohnek!!!) in matlab: man erhält die rohdaten in 1sec abschnitte zerhackt
[daten,parameter]=importbraindata_raw([path, konvert]);
daten=double(daten);


% zusammenfügen der daten in einen langen array: das dauert!
D = [];
n = size(daten,1);
for i = 1:n
D = [D daten(i,:,:)];
end
D = squeeze(D);

%betrachten der Abbildunge des Knopfkanales: wo ist der sprung über threshold : entsprechende werte eingeben
Knopf = D(:,trig_kanal);

% krit_1 = input('Sprunghoehe: ');             % eher groß, z.b. 200
% krit_2 = input('Nicht gedrueckt: ');         % eher klein, z.B. 50

% suche den Sprung: deswegen diff, nur der jeweils erste Wert über threshold interessiert
delta = diff(Knopf);

% faustregel, die stimmen sollten: sonst anpassen!, mit hilfe von knopf-abb.
krit_1 = max(abs(Knopf)) - 50;
krit_2 = 50;
I = find(delta < (-1)* krit_1); % Sprung zwischen zwei Punkten
                                % groesser als krit_1 ?
J = find(abs(Knopf(I)) < krit_2); % Schau da noch mal nach:
                                  % War der erste Klein genug, daß er schon kleiner
                                  % als krit_2 also "im schlauch" 

% entscheidene variabale: enthält anzahl und zeitpunkte aller knopfdrücke
% noch inskl. der "gekratzten"
press = I(J);

%----------------------------------------------

%%%%
% ueberpruefen, ob knopfdruckkanal "gekratzt" hat, d.h. ob 2
% triggerspruenge sehr schnell aufeinander folgen
% dies schon hier, weil fuer den rest sich dann vom hier uebriggebliebenen
% die indizies gemerkt werden sollen
%%%%
merker2 = [];
for i = 1: (length(press) -1)
    if press(i+1) - press(i) <= kratz
        me = i+1; % der erste "abstieg zaehlt"
        merker2 = [me; merker2];
    end
end
press([merker2]) = [];



% umbenennung, damit auch die knopfdrücke am anfang/ende noch erhalten bleiben,
% um knopfdrücke alle rausschmeißen zu können, die zwar genug daten haben, aber wo
% im kritischen zeitfenster noch ein knopfdruck ist.
% abspeichern von press: damit man später weiß wieviele knopfdrücke es mal gab: verhaltensstatistik!!!!!
% erst hier, weil "gekrazte" knopfdruecke nicht in die verhaltensstatistik eingehen sollen
fress = press;
sweep_ind_press = 1:length(press);
sweep_ind = sweep_ind_press;


%rausschmeißen, wenn randknopfdrücke nicht genug daten haben
%check: Knopfdrucke hinten

index = size(D,1);
while index - ende < fress(end)
    fress = fress(1:(end-1));
    sweep_ind = sweep_ind(1:(end-1));
end

%check knopfdrucke vorne
while fress(1) - anfang < 0
    fress = fress(2:end);
    sweep_ind = sweep_ind(2:end);
end

%rausfinden, ob weiterer Knopfdruck im kritischen Zeitfenster:

% überprüfen von allen knopfdrücken, außer ersten und letzten, 
% ob der jeweils erste knopfdruck vorher/nachher im kritischen bereich ist, das reicht auch, denn wenn
% der erste drin ist und sweep raus das reicht, der 2. ist immer egal
merker = [];
for j = 2: (length(fress)-1)
    if fress(j) - fress(j-1) < anfang_krit | fress(j + 1) - fress(j) < ende_krit
        merker1 = j;
        merker = [merker; merker1];
        % disp ('sweep gelöscht, mitte')
    end 
end

% überprüfen vom ersten knopfdruck
erster = find(fress(1) == press);
if press(1) < fress(1) & press(erster) - press(erster-1) < anfang_krit
    merker1 = 1;
        merker = [merker; merker1];
    % disp('sweep gelöscht anfang vorne')
elseif press(1) < fress(1)& press(erster + 1) - press(erster) < ende_krit
   merker1 = 1;
        merker = [merker; merker1];
    % disp('sweep gelöscht anfang hinten')
end


% überprüfen letzter knopfdruck
letzter = find(fress(end) == press);
if press(end) > fress(end) & press(letzter) - press(letzter-1) < anfang_krit 
     merker1 = size(fress,1);
     merker = [merker; merker1];
     % disp('sweep gelöscht ende vorne')
elseif press(end) > fress(end) & press(letzter + 1) - press(letzter) < ende_krit
     merker1 = size(fress,1);
        merker = [merker; merker1];
     % disp('sweep gelöscht ende hinten')
end


 
% rausschmeißen der knopfdrücke die oben als ungültig gemerkt wurden
fress([merker]) = [];
sweep_ind([merker]) = [];


% zusammenfügen der konvertierten, gültigen daten
sweep = [];
for k = 1: size(press)
    s = D(press(k)- (anfang-1) : press(k)+ende,:);
    sweep = cat(3,sweep,s);
end

% %abb
figure(1)
subplot(2,1,1), plot(Knopf);
hold on;
%plot(press,-1* krit_1 *(ones(size(press))),'rx');
%plot(fress,-1* krit_1 *(ones(size(fress))),'go');
plot(press,zeros(size(press)),'rx');
plot(fress,zeros(size(fress)),'go');
hold off
a = mean(sweep,3);
subplot(2,1,2), t = plot(a(:,trig_kanal));
hold on;
plot(anfang, 0, 'rx')
hold off;

% berechnen von dt aud sf
dt = 1000/sf;


% umbenennen zum verständlichen abspeichern
ind_sweeps_press = [sweep_ind_press', press];
ind_sweeps = [sweep_ind', fress];
krit_fenster = [(anfang_krit*-1)+1 : ende_krit]; krit_fenster = krit_fenster *dt; % 
zeitfenster = [(anfang*-1)+1: ende]; zeitfenster = zeitfenster *dt; % 

% bennennungen
vp.data = sweep;
if isempty(strfind(char(kanalnamen(trig_kanal)), 'Knopf'  )) == 0 | isempty(strfind(char(kanalnamen(trig_kanal)), 'knopf'  )) == 0;
    vp.info.nr_reversals = length(press);
end
vp.info.trigger_kanal = trig_kanal;
vp.info.data = 'timepoi x kanal x sweep';
vp.info.name = konvert; 
vp.info.samplingfrequenz = sf;
vp.info.kanalnamen = kanalnamen;

ind_sweeps_odk =  sprintf('%s%1.0f%s%1.0f','ind_sweeps_odk_minus', anfang_krit*dt, '_bis_', ende_krit*dt); 
ind_sweeps_alle = sprintf('%s%1.0f%s%1.0f','ind_sweeps_alle_minus', anfang *dt, '_bis_', ende*dt); 
vp.sweeplisten.(ind_sweeps_alle) = ind_sweeps_press;
vp.sweeplisten.(ind_sweeps_odk) = ind_sweeps;


tachse_sweeps_odk =  sprintf('%s%1.0f%s%1.0f','Times_odk_minus', anfang_krit*dt, '_bis_', ende_krit*dt);
tachse_sweeps_alle = sprintf('%s%1.0f%s%1.0f','Times_alle_minus', anfang*dt, '_bis_', ende*dt); 
vp.Times.(tachse_sweeps_alle) = zeitfenster; % dann ist der punkt an dem knopf gefunden wird == 0, aber der erste datenpunkt einen kuerzer als angegeben fuer anfang
vp.Times.(tachse_sweeps_odk) = krit_fenster;

% speichern
dateiname = sprintf('%s%s%s%1.0f%s%1.0f%s%1.0f', path_save,konvert, 'K', trig_kanal,  '_', anfang, '_', ende)
save(dateiname, 'vp');



%% einladen in eeglab per hand
d = vp.data; % holt daten aus struct
sw = vp.sweeplisten.(ind_sweeps_odk); % holt die richtigen indizies zum erstellen der gesuchten sweepliste aus struct 
                                                      % !!! hier immer den richtigen namen einsetzen !!!
sw = sw(:,1);
data = d(:,:,sw);% erstellt datenarray NUR mit erwuenschten sweeps
data = permute(data,[2 1 3]);  % baut die daten in richtige structur von eeglab

%eeglab % oeffnet eeglab