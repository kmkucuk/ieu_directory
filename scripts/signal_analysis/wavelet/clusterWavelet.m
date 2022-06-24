function wholeData=clusterWavelet(ALLEEG,waveparams)
nFreqs=(abs(waveparams.freq_range(1)-waveparams.freq_range(end))+1)*(1/waveparams.freqsteps);

for k = 1:length(ALLEEG)
data=ALLEEG(k).data;
% data=permute(data,[1 3 2]);
fprintf('/nNow processing subject: %s', ALLEEG(k).subject);
[erspData, itpcData, nobasedata,frex,cycles]= initiateConvolution(data,waveparams);
wholeData(k).subject=ALLEEG(k).subject;
wholeData(k).group=ALLEEG(k).group;
wholeData(k).condition=ALLEEG(k).condition;   

wholeData(k).ersp=erspData;
 wholeData(k).chaninfo=ALLEEG(k).chanlocs;   
% wholeData(k).noBaseData=nobasedata;
wholeData(k).itpcdata=itpcData;
wholeData(k).times=ALLEEG(k).times;
wholeData(k).convFreqs=frex;
wholeData(k).convCycles=cycles;
end

