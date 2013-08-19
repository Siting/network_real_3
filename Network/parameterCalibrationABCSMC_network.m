function[] = parameterCalibrationABCSMC_network(CONFIG,PARAMETER,configID)

global testingSensorIDs
global junctionIndex
global sensorMode
global perturbationFactor
global boundarySourceSensorIDs
global boundarySinkSensorIDs
global samplingStrategy

tTotalStart = tic;
% load config & para & map
[deltaTinSecond, deltaT, nT, numIntervals, numEns,...
    startTime, endTime, startTimePara, unixTimeStep, guessedFUNDAMENTAL, trueNodeRatio,...
    vmaxVar, dmaxVar, dcVar, trueNodeRatioVar, modelFirst, modelLast, populationSize,...
    samplingSize, criteria, stateNoiseGamma, measNoiseGamma, etaW, junctionSolverType,...
    numTimeSteps, samplingInterval, trueStateErrorMean, trueStateErrorVar,...
    measConfigID, measNetworkID, caliNetworkID, testingDataFolder, evolutionDataFolder,...
    sensorDataFolder, configID, T, thresholdVector] = getConfigAndPara(CONFIG,PARAMETER);
numTimeSteps = (endTime-startTime)*3600/deltaTinSecond;

load([caliNetworkID, '-graph.mat']);
disp([caliNetworkID, '-graph loaded']);

% nodeIDs = nodeMap.keys;
junctionIndex = 1;

% pre-load links & junctions, also precompute junction lane ratio for
% diverge and merge junctions
[LINK, JUNCTION, SOURCE_LINK, SINK_LINK] = preloadAndCompute(linkMap, nodeMap, T, startTime, endTime);

% pre-load occupancy data
[occuDataMatrix_source, occuDataMatrix_sink] = preloadOccuData(boundarySourceSensorIDs, boundarySinkSensorIDs);

% iterate through nodes
% for i = 1 : length(nodeIDs)
arForRounds = [];
meanForRounds = [];
varForRounds = [];
timeForRounds = [];
weightsForRounds = [];
criteriaForRounds = [];
travelTime_means_Rounds = [];
travelTime_vars_Rounds = [];
ALL_SAMPLES = initializeAllSamples(linkMap);
numStages = size(thresholdVector,1);

for stage = 1 : numStages  % iterate stages
    disp(['stage ' num2str(stage)]);
    
    errorCollectionForStage = [];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if stage == 1
        stageStart = tic;
        state = true;
        [ACCEPTED_POP, REJECTED_POP] = initializeAcceptedRejected(linkMap);
        indexCollection = [];
        times = 1;
        LINKDataFolder = ([evolutionDataFolder num2str(stage) '\']);
        if (exist (LINKDataFolder, 'dir') ~= 7)
            mkdir(LINKDataFolder);
        end
        
        if sensorMode == 2
            ROUND_SAMPLES = initializeAllSamples(linkMap);
        else
            ROUND_SAMPLES = [];
        end
        
        while (state)
            
            % simulation=============
            disp('start simulation');
            
            for sample = 1 : samplingSize
                
                index = (times-1)*samplingSize + sample;
                
                % sampling parameters for FUNDAMENTAL diagram
                % only used for funsOption==1
                FUNDAMENTAL = sampleFUNDA(guessedFUNDAMENTAL, vmaxVar, dmaxVar, dcVar);

                % Initialize links
                [LINK, SOURCE_LINK, SINK_LINK, JUNCTION, numCellsNet, ALL_SAMPLES, numLanes, ROUND_SAMPLES] = initializeAll_network(FUNDAMENTAL, linkMap, JUNCTION, deltaT, numEns, CONFIG, ALL_SAMPLES,...
                    SOURCE_LINK, SINK_LINK, junctionSolverType, LINK, ROUND_SAMPLES);

                % run forward simulation
                [LINK] = runForwardSimulation(LINK, SOURCE_LINK, SINK_LINK, JUNCTION, deltaT,...
                    numEns, numTimeSteps, nT, junctionSolverType, occuDataMatrix_source, occuDataMatrix_sink);
                
                % save density results
                saveSimulationResults_network(LINK,sensorMetaDataMap,numEns,numTimeSteps,samplingInterval,...
                    startTimePara,unixTimeStep,trueStateErrorMean,trueStateErrorVar, index, configID, evolutionDataFolder, CONFIG, PARAMETER);
                
                if mod(sample, 20) == 0
                    disp(['sample ' num2str(sample) ' finished']);
                end
            end
            
            % calibration %%%%%%%%%%%%%%%%
            disp('start calibration');
            
            % noisy sensor data
            [sensorDataMatrix] = getNoisySensorData_network(testingSensorIDs, T, startTime, endTime);
            
            % ABC SMC stage 1: filter samples according
            [ACCEPTED_POP, REJECTED_POP, indexCollection, errorCollectionForStage] = ABC_SMC_stage1_type2_network(measConfigID, CONFIG.configID, samplingSize, ALL_SAMPLES,...
                populationSize, times, ACCEPTED_POP, REJECTED_POP, indexCollection, testingSensorIDs, sensorDataMatrix, nodeMap,...
                sensorMetaDataMap, linkMap,stage, T, deltaTinSecond, thresholdVector, errorCollectionForStage, ROUND_SAMPLES);
            
            % check accepted population Size
            if size(ACCEPTED_POP(1).samples,2) >= populationSize
                ar = size(ACCEPTED_POP(1).samples,2) / (times*samplingSize);
                ACCEPTED_POP = trimExessiveSamples(ACCEPTED_POP,populationSize);
                state = false;
            elseif size(ACCEPTED_POP(1).samples,2) < populationSize               
                disp(['population size is ' num2str(size(ACCEPTED_POP(1).samples,2)) ', start reasampling.']);
                times = times + 1;
            end
            
            rmdir(['.\Result\testingData\config-' num2str(configID) '\*'], 's');
            
        end
        
        % initialize weights
        weights = 1 / size(ACCEPTED_POP(1).samples,2) * ones(1, size(ACCEPTED_POP(1).samples,2));
        
        fclose('all');
        stageT = toc(stageStart);
        timeForRounds = [timeForRounds, stageT];
        criteriaForStage = thresholdVector(1);
        
        save([evolutionDataFolder '-allRandomSamples'], 'ALL_SAMPLES');
        save([evolutionDataFolder '-acceptedPop-stage-' num2str(stage)], 'ACCEPTED_POP');
        save([evolutionDataFolder '-rejectedPop-stage-' num2str(stage)], 'REJECTED_POP');
        save([evolutionDataFolder '-errorCollection-stage-' num2str(stage)], 'errorCollectionForStage');
        save([evolutionDataFolder '-weights-stage-' num2str(stage)], 'weights');
        
        
    else
        if sensorMode == 2
            ROUND_SAMPLES = initializeAllSamples(linkMap);
        else
            ROUND_SAMPLES = [];
        end
        stageStart = tic;
        
        if samplingStrategy == 2
            [ACCEPTED_POP, weights, ar, REJECTED_POP, errorCollectionForStage, thresholdVector, criteriaForStage, travelTime_means, travelTime_vars]...
                = ABC_SMC_stage2AndLater2_newStrategy_type2_network(measConfigID, configID, samplingSize, criteria,...
                ACCEPTED_POP, REJECTED_POP, ALL_SAMPLES, weights, populationSize, PARAMETER, CONFIG,...
                sensorMetaDataMap, LINK, SOURCE_LINK, SINK_LINK, JUNCTION, stage, linkMap, testingSensorIDs,...
                sensorDataMatrix, nodeMap, errorCollectionForStage, ROUND_SAMPLES, occuDataMatrix_source, occuDataMatrix_sink);
        elseif samplingStrategy == 1
            [ACCEPTED_POP, weights, ar, REJECTED_POP, errorCollectionForStage, thresholdVector, criteriaForStage] = ABC_SMC_stage2AndLater2_type2_network(measConfigID, configID, samplingSize, criteria,...
                ACCEPTED_POP, REJECTED_POP, ALL_SAMPLES, weights, populationSize, PARAMETER, CONFIG,...
                sensorMetaDataMap, LINK, SOURCE_LINK, SINK_LINK, JUNCTION, stage, linkMap, testingSensorIDs,...
                sensorDataMatrix, nodeMap, errorCollectionForStage, ROUND_SAMPLES, occuDataMatrix_source, occuDataMatrix_sink);
        else
            disp('sampling strategy is not assigned.');
        end
        
        if stage == numStages
            [travelTime_values] = calculateTravelTime_newStrategy(ACCEPTED_POP, linkMap, sensorMetaDataMap);
            travelTime_means = mean(travelTime_values,1); % each column is a travel time item
            travelTime_vars = var(travelTime_values,0,1);
        end
        
        save([evolutionDataFolder '-acceptedPop-stage-' num2str(stage)], 'ACCEPTED_POP');
        save([evolutionDataFolder '-rejectedPop-stage-' num2str(stage)], 'REJECTED_POP');
        save([evolutionDataFolder '-errorCollection-stage-' num2str(stage)], 'errorCollectionForStage');
        save([evolutionDataFolder '-weights-stage-' num2str(stage)], 'weights');
        
        fclose('all');
        stageT = toc(stageStart);
        timeForRounds = [timeForRounds, stageT];
        
    end
    [meanForLinks, varForLinks] = computeMeanAndVar(ACCEPTED_POP);
    meanForRounds(:,:,stage) = meanForLinks;
    varForRounds(:,:,stage) = varForLinks;
    arForRounds = [arForRounds ar];
    weightsForRounds = [weightsForRounds; weights];
    criteriaForRounds = [criteriaForRounds; criteriaForStage];
    if stage ~= 1
        travelTime_means_Rounds = [travelTime_means_Rounds; travelTime_means];
        travelTime_vars_Rounds = [travelTime_vars_Rounds; travelTime_vars];
        save([evolutionDataFolder '-calibrationResult-stage' num2str(stage)],'ar', 'meanForLinks', 'varForLinks', 'thresholdVector',...
        'stageT', 'criteriaForStage', 'weightsForRounds', 'perturbationFactor', 'travelTime_means', 'travelTime_vars');
    else
        save([evolutionDataFolder '-calibrationResult-stage' num2str(stage)],'ar', 'meanForLinks', 'varForLinks', 'thresholdVector',...
            'stageT', 'criteriaForStage', 'weightsForRounds', 'perturbationFactor');     
    end
    
end

tTotalEnd = toc(tTotalStart);
save([evolutionDataFolder '-calibrationResult'],'arForRounds', 'meanForRounds', 'varForRounds', 'thresholdVector',...
    'timeForRounds', 'weightsForRounds', 'tTotalEnd', 'criteriaForRounds', 'perturbationFactor', 'travelTime_means_Rounds',...
    'travelTime_vars_Rounds');
