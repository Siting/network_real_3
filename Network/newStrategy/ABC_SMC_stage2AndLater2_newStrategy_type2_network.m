function[NEW_ACCEPTED_POP, newWeights, ar, NEW_REJECTED_POP,...
    errorCollectionForStage, thresholdVector, criteriaForStage, travelTime_means, travelTime_vars]...
    = ABC_SMC_stage2AndLater2_newStrategy_type2_network(measConfigID, configID, samplingSize, criteria,...
                    ACCEPTED_POP, REJECTED_POP, ALL_SAMPLES, oldWeights, populationSize, PARAMETER, CONFIG,...
                    sensorMetaDataMap, LINK, SOURCE_LINK, SINK_LINK, JUNCTION, stage, linkMap, testingSensorIDs,...
                    sensorDataMatrix, nodeMap, errorCollectionForStage, ROUND_SAMPLES,  occuDataMatrix_source, occuDataMatrix_sink)
                
global samplingStrategy
global thresholdChoice
global sensorMode
   
condition = true;
[NEW_ACCEPTED_POP, NEW_REJECTED_POP] = initializeAcceptedRejected(linkMap);
newWeights = [];
times = 1;
existedLinks = 0;

LINKDataFolder = ([CONFIG.evolutionDataFolder num2str(stage) '\']);
if (exist (LINKDataFolder, 'dir') ~= 7)
    mkdir(LINKDataFolder);
end

% pick threshold based on the error distribution from the previous stage
if thresholdChoice == 2
    [thresholdVector, criteriaForStage] = pickThresholdValue(stage, configID);
elseif thresholdChoice == 1
    thresholdVector = PARAMETER.thresholdVector;
    criteriaForStage = thresholdVector(stage,1);
end

% calculate travel time
if samplingStrategy == 2
    [travelTime_values] = calculateTravelTime_newStrategy(ACCEPTED_POP, linkMap, sensorMetaDataMap);
    travelTime_means = mean(travelTime_values,1); % each column is a travel time item
    travelTime_vars = var(travelTime_values,0,1);
elseif samplingStrategy ~= 1
    disp('samplingStrategy is not assigned');
end

while(condition)
    % initialize ROUND_SAMPLES
    if sensorMode == 2
        ROUND_SAMPLES = initializeAllSamples(linkMap);
    else
        ROUND_SAMPLES = [];
    end
    % generate POPULATION_2 instead of using the SMC method
    if samplingStrategy == 2
        [POPULATION_2] = generatePOPULATION2_newStrategy(travelTime_means', travelTime_vars',...
            configID, linkMap, populationSize, LINK);
        indexCollection_1 = ones(populationSize,1);
    end

    % update Fundamental for links etc, and then run simulation
    disp('start simulation');
    [LINK, SOURCE_LINK, SINK_LINK, JUNCTION, T, deltaTinSecond, ROUND_SAMPLES]...
        = updateFunAndSimulate_type2_network(POPULATION_2, LINK, SOURCE_LINK, SINK_LINK, JUNCTION,...
        CONFIG, PARAMETER, indexCollection_1, sensorMetaDataMap, configID, stage, linkMap, ROUND_SAMPLES,...
        occuDataMatrix_source, occuDataMatrix_sink);

    % filter samples, accept or reject?
    disp('start calibration');
    [POPULATION_3, POPULATION_4, indexCollection_2, filteredWeights, errorCollectionForStage] = filterSamples_type2_network(POPULATION_2, indexCollection_1, oldWeights,...
        configID, measConfigID, stage, sensorDataMatrix, testingSensorIDs, linkMap, nodeMap, sensorMetaDataMap,...
        T, deltaTinSecond, thresholdVector, errorCollectionForStage, ROUND_SAMPLES);
    
    if times <= 5
        save([CONFIG.evolutionDataFolder '-sampledAndPertubed-stage-' num2str(stage) '-time-' num2str(times)], 'POPULATION_2',...
            'POPULATION_3', 'POPULATION_4');
    end

    if size(POPULATION_3(1).samples, 2) == 0 
        disp('round population size 0 after filtering');
    end

%     % save filtered LINKs
%     saveFilteredLinks(LINKDataFolder, indexCollection_2, CONFIG.evolutionDataFolder, configID, existedLinks, populationSize);
    
    % save
    NEW_ACCEPTED_POP = saveNewSamples(NEW_ACCEPTED_POP, POPULATION_3);
    NEW_REJECTED_POP = saveNewSamples(NEW_REJECTED_POP, POPULATION_4);

    % take one out use as example
    newAcceptedPop1 = NEW_ACCEPTED_POP(1).samples;
    % check population size
    if size(newAcceptedPop1,2) >= populationSize
        ar = size(newAcceptedPop1,2) / (times * length(oldWeights));
        NEW_ACCEPTED_POP = trimExessiveSamples(NEW_ACCEPTED_POP,populationSize);
        %% update weights
        newWeights = oldWeights;
        condition = false;
    elseif size(newAcceptedPop1,2) < populationSize
        disp(['population size is ' num2str(size(newAcceptedPop1,2)) ', start reasampling.']);
        condition = true;
        existedLinks = existedLinks + size(POPULATION_3(1).samples, 2);
        times = times + 1;
    end
end