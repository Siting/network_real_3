function[POPULATION_2] = generatePOPULATION2_newStrategy(travelTime_means, travelTime_vars, configID, linkMap, populationSize, LINK)

global expectAR
global funsOption

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
%%%%%%%%%%%%%%%%%%%%%%%%%%

% OLD WAY: three parameters for link 2,4,6,8
% OLD WAY: vmax for link 9
% OLD WAY: dmax for link 1,3
% OLD WAY: dc for link 1,3,6,7,9
guessedFUNDAMENTAL = struct('vmax',[],'dmax',[],'dc',[]);
for i = 1 : length(linkIds)    
    POPULATION_2(i) = struct('linkID',i, 'samples', []);
    guessedFUNDAMENTAL.vmax = vmax_mean(i);
    guessedFUNDAMENTAL.dmax = dmax_mean(i);
    guessedFUNDAMENTAL.dc = dc_mean(i);
    for j = 1 : populationSize
        [FUNDAMENTAL] = sampleFUNDA(guessedFUNDAMENTAL, vmax_var(i), dmax_var(i), dc_var(i));
        POPULATION_2(i).samples(:,j) = [FUNDAMENTAL.vmax; FUNDAMENTAL.dmax; FUNDAMENTAL.dc];
    end
end
% NEW WAY
means = travelTime_means;
vars = expectAR .* travelTime_vars;
keyboard
%===========================================================
for j = 1 : populationSize
    for i = 1 : length(linkIds)   
        LINK(i) = POPULATION_2(i).samples(:,j);
    end
    [vmax1, vmax3, vmax5, vmax7, dmax5, dmax7, dmax9] = sampleFUNDA_newStrategy(LINK, means, vars, j);
    
    POPULATION_2(1).samples(1,j) = vmax1;
    POPULATION_2(3).samples(1,j) = vmax3;
    POPULATION_2(5).samples(1,j) = vmax5;
    POPULATION_2(7).samples(1,j) = vmax7;
    POPULATION_2(5).samples(2,j) = dmax5;
    POPULATION_2(7).samples(2,j)  = dmax7;
    POPULATION_2(9).samples(2,j)  = dmax9;
end
%===========================================================