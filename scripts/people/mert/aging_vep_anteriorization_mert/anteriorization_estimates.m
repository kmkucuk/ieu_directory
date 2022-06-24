fnames = fieldnames(spssStructure);
fnames= fnames(4:end);
chanIndx = regexp(fnames{1},'F_');

% variableName = 'density';
itidx = 0;
antStruct = struct();

%%chanCoordinates 

fr = [0.673028145070219,-0.545007445768716,0.500000000000000];
ce = [4.40468591992013e-17,-0.719339800338651,0.694658370458997];
pa = [-0.673028145070219,-0.545007445768716,0.500000000000000];
oc = [-0.950477158362114,-0.308828749571334,-0.0348994967025010];
chancoordinates = [fr;ce;pa];
D = [vecnorm(chancoordinates - oc, 2, 2).' 0]; % last item is 0 because it represents the distance between occipital 
                                                % electrode from itself. 

getavg = [];
for pi = 1:length(spssStructure)
    if spssStructure(pi).exclusion == 1
        itidx = itidx+1;
        aggregate = [];
        for k = 1:length(fnames)
           aggregate = [aggregate spssStructure(itidx).(fnames{k})];

        end
        aggregate = cat(1,aggregate,[1 2 3 4]);
        aggregate = cat(1,aggregate,D);
        getavg = cat(3,getavg,aggregate);
        [minval, colIndx] = min(aggregate(1,[1 2 3])); % don't search O for mean
        minChanName = fnames{colIndx}(chanIndx);
        occipital = aggregate(1,end);
        avg = mean(aggregate(1,:));
        onlyMinMax_slope = polyfit(aggregate(2,[colIndx 4]),aggregate(1,[colIndx 4]),1);
        all_slope = polyfit(aggregate(2,:),aggregate(1,:),1);
        all_slope_coordinates = polyfit(aggregate(3,:),aggregate(1,:),1);
        
    %     if minChan == 'F' || minChan == 'C'
    %         % if minimum value is within frontal or central locations set
    %         % anteriozation distance as 2, set it to 1 if anteriorization
    %         % occured at parietal.
    %         anteriorizationDistance = 2;
    %     else
    %         anteriorizationDistance = 1; 
    %     end
        
       antStruct(itidx).subject = spssStructure(pi).subject;
       antStruct(itidx).group = spssStructure(pi).group;
       antStruct(itidx).exclusion = spssStructure(pi).exclusion;
       antStruct(itidx).minant = minval;
       antStruct(itidx).occ = occipital;
    %    spssStructure(pi).minant_weightD = 
    %    spssStructure(pi).([minChanName,'_',variableName])  = spssStructure(pi).(fnames{k});
    %    spssStructure(pi).anteriorizationDistance = anteriorizationDistance;
       antStruct(itidx).minchan = minChanName;
       
       antStruct(itidx).slopeMinMax =onlyMinMax_slope(1);
       antStruct(itidx).interceptMinMax =onlyMinMax_slope(2);
       
       antStruct(itidx).slopeAll = all_slope(1);
       antStruct(itidx).interceptAll =all_slope(2);

       antStruct(itidx).slopeAllDist = all_slope_coordinates(1);
       antStruct(itidx).interceptAllDist =all_slope_coordinates(2);
    end

    
end
% calculate average slope
olderAvg = mean(getavg(:,:,1:12),3);
olderSlope = polyfit(olderAvg(2,:),olderAvg(1,:),1);
youngAvg = mean(getavg(:,:,13:24),3);
youngSlope = polyfit(youngAvg(2,:),youngAvg(1,:),1);

% Create a new x axis with exactly 1000 points (or whatever you want).
xFit = linspace(min(olderAvg(2,:)), max(olderAvg(2,:)), 100);
% Get the estimated yFit value for each of those 1000 new x locations.
yFitOld = polyval(olderSlope , olderAvg(2,:));
yFitYoung = polyval(youngSlope , olderAvg(2,:));

figure(2)
plot(olderAvg(2,:),olderAvg(1,:),'r','linewidth',2)
hold on
plot(youngAvg(2,:),yFitOld,'r:','linewidth',2)
plot(youngAvg(2,:),yFitYoung,'b:','linewidth',2)
plot(youngAvg(2,:),youngAvg(1,:),'b','linewidth',2)

set(gca,'ylim',[-3 3],'FontName','Helvetica','FontSize',18,...
    'TickDir','out','linewidth',5,'XColor',[0 0 0],'YColor',[0 0 0])
set(gca,'box','off')
% cellst = num2cell(nan(length(antStruct)+1,length(fieldnames(antStruct))));
% cellst(1,:) = fieldnames(antStruct).'
% cellst(2:end,:) = squeeze([struct2cell(antStruct)]).';
% cd('F:\Backups\Matlab Directory\Compensation_Aging\anteriorization')
% writecell(cellst,'antStructExo.xlsx')
% close all