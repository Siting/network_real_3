clear all
clc

sensorIDs = [400468; 402955; 402953; 400739; 402954; 400363; 402950; 400698];
startTime = 8;
endTime = 10;
startIndex = (startTime * 3600)/30 + 1;
endIndex = (endTime * 3600)/30 + 1;
%%
global boundarySourceSensorIDs
global boundarySinkSensorIDs
global testingSensorIDs
global sensorDataSource
global samplingModeVmax
global samplingModeDmax
global samplingModeDc
global sensorMode
global occuThreshold

series = 74;
stage = 9;
numSamplesStudied = 1;
sampleIndex = 25;
occuThreshold = 0.2;
startTimeStamp = 5;
studyLinks = [1; 3; 5; 7];
cali_configID = 42;
cali_paraID = 42;
simu_configID = series + 100;
boundarySourceSensorIDs = [400468; 402955; 402954; 402950];
boundarySinkSensorIDs = [402953; 400698];
testingSensorIDs = [400739; 400363];
sensorDataSource = 2;
samplingModeVmax = 1;
samplingModeDmax = 2;
samplingModeDc = 2;
sensorMode = 2;

% load CONFIG & PARA &...
load(['.\Configurations\configs\CONFIG-' num2str(cali_paraID) '.mat']);
load(['.\Configurations\parameters\PARAMETER-' num2str(cali_paraID) '.mat']);
load([CONFIG.caliNetworkID, '-graph.mat']);

% directories
simu_sensorEvolutionDataFolder = ['.\Result\testingData\config-' num2str(simu_configID)];
simu_linkEvolutionDataFolder = ['.\Result\evolutionData\config-' num2str(simu_configID)];
mkdir(simu_sensorEvolutionDataFolder);
mkdir(simu_linkEvolutionDataFolder);

% load noisy sensor data
[sensorDataMatrix] = getNoisySensorData_network(testingSensorIDs, PARAMETER.T,...
    PARAMETER.startTime, PARAMETER.endTime);

ROUND_SAMPLES = initializeAllSamples(linkMap);
% SIMULATION
for sample = 1 : numSamplesStudied
    [LINK, JUNCTION, SOURCE_LINK, SINK_LINK] = preloadAndCompute(linkMap, nodeMap, PARAMETER.T, PARAMETER.startTime, PARAMETER.endTime);
    % pre-load occupancy data
    [occuDataMatrix_source, occuDataMatrix_sink] = preloadOccuData(boundarySourceSensorIDs, boundarySinkSensorIDs);
    
    load(['.\ResultCollection\series' num2str(series) '\-acceptedPop-stage-' num2str(stage) '.mat']);
    for i = 1 : length(LINK)
        FUNDAMENTAL(i).vmax = ACCEPTED_POP(i).samples(1,sampleIndex);
        FUNDAMENTAL(i).dmax = ACCEPTED_POP(i).samples(2,sampleIndex);
        FUNDAMENTAL(i).dc = ACCEPTED_POP(i).samples(3,sampleIndex);
    end
    
    % run simulation
    [LINK, ROUND_SAMPLES] = runSimulationForSample(FUNDAMENTAL, PARAMETER, CONFIG, simu_configID, sample, simu_sensorEvolutionDataFolder,...
        LINK, JUNCTION, SOURCE_LINK, SINK_LINK, ROUND_SAMPLES, occuDataMatrix_source, occuDataMatrix_sink);
    
    % all links density results
    save([simu_linkEvolutionDataFolder '\LINK-CONFIG-' num2str(cali_configID) '-sample-' num2str(sample)],'LINK');
    
    % get model simulation data (cumulative)
    modelDataMatrix = getModelSimulation_analyze(simu_configID, sample, testingSensorIDs, PARAMETER.T, PARAMETER.deltaTinSecond, ROUND_SAMPLES);
    
end

%%
col=str2mat('r', 'g', 'b', 'k', 'y');

% load sensor true data
sensorDataCollection = [];
for i = 1 : length(sensorIDs)
    sensorID = sensorIDs(i);
    load(['.\SensorData_30s_analyze\' num2str(sensorID) '.mat']);
    sensorDataCollection = [sensorDataCollection flowDataSum(startIndex:endIndex)];
end

% compute left and right flow data
left(:,1) = sensorDataCollection(:,1) + sensorDataCollection(:,2) - sensorDataCollection(:,3);
right(:,1) = sensorDataCollection(:,8) - sensorDataCollection(:,7) - sensorDataCollection(:,5);
left(:,2) = sensorDataCollection(:,1) + sensorDataCollection(:,2) - sensorDataCollection(:,3) + sensorDataCollection(:,5);
right(:,2) = sensorDataCollection(:,8) - sensorDataCollection(:,7);

% plot
figure
subplot(2,1,1)
plot(left(:,1),'r');
hold on
plot(right(:,1),'g');
plot(modelDataMatrix(:,1),'k');
plot(sensorDataMatrix(:,1),'b');
legend('left','right','prediction','sensor');
title('sensor 400739');

subplot(2,1,2)
plot(left(:,2),'r');
hold on
plot(right(:,2),'g');
plot(modelDataMatrix(:,2),'k');
plot(sensorDataMatrix(:,2),'b');
legend('left','right','prediction','sensor');
title('sensor 400363');

saveas(gcf, ['../Plots\series' num2str(series) '\left_right_pre_true.pdf']);
saveas(gcf, ['../Plots\series' num2str(series) '\left_right_pre_true.fig']);
saveas(gcf, ['../Plots\series' num2str(series) '\left_right_pre_true.eps'], 'epsc');