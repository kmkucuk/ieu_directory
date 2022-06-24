%method = average or MAX plot. (e.g. 'mean' OR 'max')
%
%groupText = cell vector containing first three letters of groups (e.g.
%patient = 'pat', control = 'con' OR older = 'old', young = 'you'
%
% pCount = use if you are using 'max' which requires wholeData structure
% with all participant's data.
%
% maxFreqField = it is the structure field that contains maximum frequency (e.g. 'lowbeta').
% 
function mert_topoplot(convStats,conditions,timewins,freqs,datatype,ylims,method,groupText,pCount,maxFreqField)

load 10chanlocs.mat

times=convStats(1).times;

chans=[1 2 3 4 5 6 7 8];

plotC=length(conditions);
isempty(freqs)
plotT=length(timewins)/2;
actualFreqs = freqs;
if ~isempty(freqs)
    freqs=findIndices(convStats(1).convFreqs,freqs);
end

 
timeindx=findIndices(times,timewins);


data=[];
for i = 1:plotC
    if plotC > 1
        pIndices = (((conditions(i)-1)*pCount)+1) : (conditions(i)*pCount);
    else 
        pIndices = 1;
    end
    j=i;
    timeIndx=0;
    for k = 1:2:length(timewins)
    timeIndx=timeIndx+1;
    plotIndx = timeIndx+((j-1)*plotT);
        if ~isempty(freqs)
            if ~isempty(regexp(method,'mean'))
                data=mean(convStats(conditions(i)).(datatype)(freqs,timeindx(k):timeindx(k+1),chans),2); % FOR ERSP 
                titleText=[convStats(pIndices(1)).group ,' frequency: ' ,num2str(actualFreqs),'Hz'];
            else

                if freqs == 999
                    for pindex = pIndices
                        freqIndex = findIndices(convStats(1).convFreqs,convStats(pindex).(maxFreqField));
                        data = cat(4,data,convStats(pindex).(datatype)(freqIndex,:,:));
                    end
                    data=mean(max(data(:,timeindx(k):timeindx(k+1),chans,:,:),[],2),4); % FOR ERSP 
                else
                    data=cat(4,convStats(pIndices).(datatype));
                    data=mean(max(data(freqs,timeindx(k):timeindx(k+1),chans,:),[],2),4); % FOR ERSP 
                end
                titleText=[convStats(pIndices(1)).group ,' frequency: ' ,num2str(actualFreqs),'Hz'];
            end
        else
            if ~isempty(regexp(method,'mean'))
                data=mean(convStats(conditions(i)).(datatype)(timeindx(k):timeindx(k+1),chans),2); % FOR ERSP 
                titleText=[convStats(pIndices(1)).group ,' frequency: ' ,num2str(actualFreqs),'Hz'];
            else
                data=cat(3,convStats(pIndices).(datatype)(timeindx(k):timeindx(k+1),chans));
                data=mean(max(data,[],1),3);     
                titleText=[convStats(pIndices(1)).group ,' frequency: ' ,num2str(freqs),'Hz'];
%                 titleText=convStats(pIndices(1)).group;
            end        

        end
    %data2=max(convStats(conditions(i)).(datatype)(freqs,timeindx(k):timeindx(k+1),chans),[],2); % FOR ITC ANALYSES
 

%         if strncmp(convStats(conditions(i)).group,groupText{1},3)
%             rowidx=1;
%         elseif strncmp(convStats(conditions(i)).group,groupText{2},3)
%             rowidx=2;
%         end

%     subplot(plotT,plotC,plotIndx);    
    topoplot(data,EEG.chanlocs,'maplimits',ylims);
    title(titleText)
        if i==plotC
            cb=colorbar;
            cb.Position = cb.Position  + [.1 0 0 0];
            cbtitle=get(cb,'Title');
            set(cbtitle,'String',"dB")
            set(cb,'fontweight','bold','fontsize',12);
            cbticks=linspace(ylims(1),ylims(2),3);
            % %set colorbar ticks
            set(cb,'Ticks',cbticks);
            cb.Ruler.TickLabelFormat = '%.2f';
        end
    end
    
end
% 
% colorbar properties
% title   


% %set colorbar position
% hp4=get(subplot(plotC,plotT,j),'position');
% set(cb,'Position', [hp4(1)+hp4(3)+.015  .35  0.022  hp4(2)+hp4(3)-.15]);



    
