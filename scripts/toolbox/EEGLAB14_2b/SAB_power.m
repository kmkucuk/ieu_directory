% power
eeglab;

file='up204mk1oAa.set';
elec=5;
A=1:174; B=175:348;    
maxwin=B;  % sucht max power in Fenster A=-3000 bis -1000; B=-1000 bis 1000;


topo={'Cz' 'C3' 'C4' 'P3' 'P4' 'O1' 'O2' 'F3' 'F4' 'EOG' 'Fz' 'Pz'};
el=topo(elec);
el=cell2mat(el);

EEG = pop_loadset( 'filename', [file],'filepath',... 
'C:\\Dokumente und Einstellungen\\FSC\\Desktop\\Diplomarbeit\\set Dateien\\oA\\');

figure;
[pow,itc,powbase,times,freqs] = pop_newtimef( ...
    EEG, 1, 5, [-3000  998], [0] , ...
    'type', 'phasecoher',...
    'topovec', elec, ...
    'elocs', EEG.chanlocs, ...
    'chaninfo', EEG.chaninfo, ...
    'title', file, ...
    'alpha', 0.05,...
    'padratio', 8, ...
    'timesout', [348.5], ...
    'plotphase','off', ...
    'baseline', [-3000 998], ...
    'freqs', [1 4]);
    
%{
a=0;b=4;
meanvec=[]; cpow=[]; winpow=pow(:,maxwin); 

for i=1:170
 
 cpow=winpow(:,(a+i):(b+i));
 cmean=mean(mean(cpow));
 meanvec=[meanvec, cmean]; 
 
end
[val, ind]=max(meanvec);

tpA=[]; tpB=[];
if maxwin==A
    tpA=((ind+3)*10)-2744;
elseif maxwin==B
    tpB=((ind+177)*10)-2744;
end

name=(file(3:5));
name=[name,'_',el]; 
 
w1cen= tpA;
w2cen= tpB;

w1cen= (w1cen+2744)/10;
w1start=w1cen-15;
w1end=w1cen+15;
pow1=pow(:,w1start:w1end);
pow1=mean(mean(pow1));
eval(['pow1_', name, ' = pow1']);

w2cen=(w2cen+2744)/10;
w2start=w2cen-15;
w2end=w2cen+15;
pow2=pow(:,w2start:w2end);
pow2=mean(mean(pow2));
eval(['pow2_', name, ' = pow2']);

maxpow=max(max(winpow));
eval(['maxpow_', name, ' = maxpow']);


clear el elec file freqs  name pow powbase times topo w1cen...
    w1end w1start w2cen w2end w2start pow1 pow2 a b cmean cpow...
    maxwin meanvec ind i winpow maxpow
% varianz var(var(pow1))

% test=mean(pow(1001:end),1);
%}