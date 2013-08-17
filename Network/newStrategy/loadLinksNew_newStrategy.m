function[LINK, ROUND_SAMPLES] = loadLinksNew_newStrategy(linkMap,FUNDAMENTAL, configID, LINK, ROUND_SAMPLES)

global funsOption
global sensorMode

linkIds = linkMap.keys;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if funsOption == 2
    fileName = (['.\Configurations\fundamental_setting\FUN_CONFIG-' num2str(configID) '.csv']);
    fid=fopen(fileName);
    funForLinks=textscan(fid,'%d %f %f %f %f %f %f','delimiter',',','headerlines',1);
    vmax_mean = funForLinks{2};
    dmax_mean = funForLinks{3};
    dc_mean = funForLinks{4};
    vmax_var = funForLinks{5};
    dmax_var = funForLinks{6};
    dc_var = funForLinks{7};
    fclose(fid);
end

fileName = (['.\Configurations\time_speed\TIME_SPEED_CONFIG-' num2str(configID) '.csv']);
fid=fopen(fileName);
data=textscan(fid,'%s %f %f','delimiter',',','headerlines',1);
means = data{2};
vars = data{3};
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%

% OLD WAY: three parameters for link 2,4,6,8
% OLD WAY: vmax for link 9
% OLD WAY: dmax for link 1,3
% OLD WAY: dc for link 1,3,6,7,9
guessedFUNDAMENTAL = FUNDAMENTAL;

for i = 1 : length(linkIds)
    
    NTlink = linkMap(linkIds{i});
    link = LINK(linkIds{i});
    link.densityResult = [];
    if funsOption == 1
        % fundamental diagram parameters
        link.vmax = FUNDAMENTAL.vmax;
        link.dc = NTlink.numberOfLanes * FUNDAMENTAL.dc;
        link.dmax = NTlink.numberOfLanes * FUNDAMENTAL.dmax;
    elseif funsOption == 2
        guessedFUNDAMENTAL.vmax = vmax_mean(i);
        guessedFUNDAMENTAL.dmax = dmax_mean(i);
        guessedFUNDAMENTAL.dc = dc_mean(i);
        [FUNDAMENTAL] = sampleFUNDA(guessedFUNDAMENTAL, vmax_var(i), dmax_var(i), dc_var(i));
        link.vmax = FUNDAMENTAL.vmax;
        link.dmax = NTlink.numberOfLanes * FUNDAMENTAL.dmax;
        link.dc = NTlink.numberOfLanes * FUNDAMENTAL.dc;
    end
    if sensorMode == 2
        if i == 5 || i == 7
            sample = [link.vmax; link.dmax; link.dc];
            ROUND_SAMPLES(i).samples = [ROUND_SAMPLES(i).samples sample];
        end
    end
    LINK(linkIds{i}) = link;
end

%===========================================================
[vmax1, vmax3, vmax5, vmax7, dmax5, dmax7, dmax9] = sampleFUNDA_newStrategy(LINK, means, vars);

LINK = assignNewSamples_newStrategy(vmax1, vmax3, vmax5, vmax7, dmax5, dmax7, dmax9, LINK);
%===========================================================