% study rejected samples by stages
clear all
clc

global boundarySourceSensorIDs
global boundarySinkSensorIDs
global testingSensorIDs
global sensorDataSource
global thresholdChoice
global errorStart
global samplingModeVmax
global samplingModeDmax
global samplingModeDc
global sensorMode
global occuThreshold

series = 75;
traConfigID = 1;
studyStages = [7];
numSamplesStudied = 50;
cali_configID = 43;
cali_paraID = 43;
occuThreshold = 0.2;
simu_configID = series+100;
boundarySourceSensorIDs = [400468; 402955; 402954; 402950];
boundarySinkSensorIDs = [402953; 400698];
testingSensorIDs = [400739; 400363];
sensorDataSource = 2;
thresholdChoice = 2;
errorStart = 5;
samplingModeVmax = 1;
samplingModeDmax = 2;
samplingModeDc = 2;
sensorMode = 2;

% load prior and posterior
fileName = (['.\Configurations\fundamental_setting\FUN_CONFIG-' num2str(cali_configID) '.csv']);
fid=fopen(fileName);
funForLinks=textscan(fid,'%d %f %f %f %f %f %f','delimiter',',','headerlines',1);
vmax_mean_prior = funForLinks{2};
dmax_mean_prior = funForLinks{3};
dc_mean_prior = funForLinks{4};
vmax_var_prior = funForLinks{5};
dmax_var_prior = funForLinks{6};
dc_var_prior = funForLinks{7};
fclose(fid);

% load prior and posterior
fileName = (['.\Configurations\fundamental_setting\FUN_CONFIG-' num2str(traConfigID) '.csv']);
fid=fopen(fileName);
funForLinks=textscan(fid,'%d %f %f %f %f %f %f','delimiter',',','headerlines',1);
vmax_mean_tra = funForLinks{2};
dmax_mean_tra = funForLinks{3};
dc_mean_tra = funForLinks{4};
vmax_var_tra = funForLinks{5};
dmax_var_tra = funForLinks{6};
dc_var_tra = funForLinks{7};
fclose(fid);

% load CONFIG & PARA &...
criteriaForRounds = zeros(10,2);
load(['.\Configurations\configs\CONFIG-' num2str(cali_paraID) '.mat']);
load(['.\Configurations\parameters\PARAMETER-' num2str(cali_paraID) '.mat']);
load([CONFIG.caliNetworkID, '-graph.mat']);
simu_evolutionDataFolder = ['.\Result\testingData\config-' num2str(simu_configID)];
FUNDAMENTAL = PARAMETER.FUNDAMENTAL;

% directories
simu_sensorEvolutionDataFolder = ['.\Result\testingData\config-' num2str(simu_configID)];
simu_linkEvolutionDataFolder = ['.\Result\evolutionData\config-' num2str(simu_configID)];
mkdir(simu_sensorEvolutionDataFolder);
mkdir(simu_linkEvolutionDataFolder);

% assign line colors & legends
col=str2mat('r', 'g', 'b', 'k', 'y');
stagesString = [];
for i = 1 : length(studyStages)
    stagesString = [stagesString; ['stage ' num2str(studyStages(i))]];
end

% load noisy sensor data
[sensorDataMatrix] = getNoisySensorData_network(testingSensorIDs, PARAMETER.T,...
    PARAMETER.startTime, PARAMETER.endTime);

ROUND_SAMPLES = initializeAllSamples(linkMap);

% SIMULATION for PRIOR & TRA
for sample = 1 : (numSamplesStudied+1)
    [LINK, JUNCTION, SOURCE_LINK, SINK_LINK] = preloadAndCompute(linkMap, nodeMap, PARAMETER.T, PARAMETER.startTime, PARAMETER.endTime);
    % pre-load occupancy data
    [occuDataMatrix_source, occuDataMatrix_sink] = preloadOccuData(boundarySourceSensorIDs, boundarySinkSensorIDs);
    clear all
    if sample <= 1 * numSamplesStudied
        for i = 1 : length(LINK)
            guessed_FUNDAMENTAL.vmax = vmax_mean_prior(i);
            guessed_FUNDAMENTAL.dmax = dmax_mean_prior(i);
            guessed_FUNDAMENTAL.dc = dc_mean_prior(i);
            [FUNDAMENTAL(i)] = sampleFUNDA(guessed_FUNDAMENTAL, vmax_var_prior(i), dmax_var_prior(i), dc_var_prior(i));
        end
    else
        for i = 1 : length(LINK)
            guessed_FUNDAMENTAL.vmax = vmax_mean_tra(i);
            guessed_FUNDAMENTAL.dmax = dmax_mean_tra(i);
            guessed_FUNDAMENTAL.dc = dc_mean_tra(i);
            [FUNDAMENTAL(i)] = sampleFUNDA(guessed_FUNDAMENTAL, vmax_var_tra(i), dmax_var_tra(i), dc_var_tra(i));
        end      
    end
    
    % run simulation
    [LINK, ROUND_SAMPLES] = runSimulationForSample(FUNDAMENTAL, PARAMETER, CONFIG, simu_configID, sample, simu_sensorEvolutionDataFolder,...
        LINK, JUNCTION, SOURCE_LINK, SINK_LINK, ROUND_SAMPLES, occuDataMatrix_source, occuDataMatrix_sink);
    
    % all links density results
    save([simu_linkEvolutionDataFolder '\LINK-CONFIG-' num2str(cali_configID) '-sample-' num2str(sample)],'LINK');

    % get model simulation data (cumulative)
    modelDataMatrix = getModelSimulation_analyze(simu_configID, sample, testingSensorIDs, PARAMETER.T, PARAMETER.deltaTinSecond, ROUND_SAMPLES);
    
    % save cumulative density Matrix
    save([simu_sensorEvolutionDataFolder '\' num2str(sample) '\cumuDensity'],'modelDataMatrix');
    
    if mod(sample, 5) == 0
        disp(['sample ' num2str(sample) ' is finished']);
    end
end

% FILTER
[ACCEPTED_POP_NEW, REJECTED_POP_NEW] = initializeAcceptedRejected(linkMap);
sensorSelection = [];
errorCollectionForStage = [];
criteria = 0;
for sample = 1 : (numSamplesStudied+1)
    
    % load model density simulation data (first row = initial state)
    [modelDataMatrix] = getModelSimulation_analyze(simu_configID, sample,...
        testingSensorIDs, PARAMETER.T, PARAMETER.deltaTinSecond, ROUND_SAMPLES);
    % create error matrix (density)
    errorMatrix = generateErrorMatrixTest_network(modelDataMatrix, sensorDataMatrix, testingSensorIDs);
    
    % reject or select?
    if thresholdChoice == 1
        [choice, sensorSelection, sampleError] = rejectAccept_network(errorMatrix, criteria, nodeMap,...
            sensorMetaDataMap, linkMap, studyStages(i), sensorSelection, PARAMETER.thresholdVector);
    elseif thresholdChoice == 2
        thresholdVector(studyStages(1),:) = [criteriaForRounds(studyStages(1)) criteriaForRounds(studyStages(1))];
        [choice, sensorSelection, sampleError] = rejectAccept_network(errorMatrix, criteria, nodeMap,...
            sensorMetaDataMap, linkMap, studyStages(1), sensorSelection, thresholdVector);
    end
    
    errorCollectionForStage = [errorCollectionForStage sampleError];
end

% sort array in ascending order
errorArrayStages(:,1) = sort(errorCollectionForStage(1:numSamplesStudied), 'ascend');
errorArrayStages(:,2) = errorCollectionForStage(end) .* ones(size(errorArrayStages(:,1),1),1);
matrixSize = size(sensorDataMatrix(:,1),1);

relativeErrorStages(:,1) = max(errorArrayStages(:,1) / ( 1/matrixSize * norm(sensorDataMatrix(:,1))),...
    errorArrayStages(:,1) / ( 1/matrixSize * norm(sensorDataMatrix(:,2))));
relativeErrorStages(:,2) = max(errorArrayStages(:,2) / ( 1/matrixSize * norm(sensorDataMatrix(:,1))),...
    errorArrayStages(:,2) / ( 1/matrixSize * norm(sensorDataMatrix(:,2))));


% load errorCollection matrix
errorArrayStages_pos = [];
for i = 1 : length(studyStages)
    load(['.\ResultCollection\series' num2str(series) '\-errorCollection-stage-' num2str(studyStages(i)) '.mat']);
    errorCollectionForStage = errorCollectionForStage(1:numSamplesStudied)';   % an array of errors for each sample
    errorArrayStages(:,3) = [errorArrayStages_pos errorCollectionForStage];
    
    matrixSize = size(sensorDataMatrix(2:end,1),1);
    
    % compute relative error
    relativeErrorStages(:,3) = max(errorArrayStages(:,3) / ( 1/matrixSize * norm(sensorDataMatrix(2:end,1))),...
        errorArrayStages(:,3) / ( 1/matrixSize * norm(sensorDataMatrix(2:end,2))));  % an array of relative errors for each sample
end

figure
subplot(2,1,1)
boxplot(errorArrayStages,'labels', ['pri'; 'tra'; 'pos']);
ylabel('Absolute error');
hold on

subplot(2,1,2)
boxplot(relativeErrorStages,'labels', ['pri'; 'tra'; 'pos']);
ylabel('Relative error');

saveas(gcf, ['../Plots\series' num2str(series) '\errorDistribution_priorVStraVSpos.pdf']);
saveas(gcf, ['../Plots\series' num2str(series) '\errorDistribution_priorVStraVSpos.fig']);
saveas(gcf, ['../Plots\series' num2str(series) '\errorDistribution_priorVStraVSpos.eps'], 'epsc');