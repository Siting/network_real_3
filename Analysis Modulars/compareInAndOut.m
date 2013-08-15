clear all
clc

global boundarySourceSensorIDs
global boundarySinkSensorIDs
global testingSensorIDs
global sensorDataSource
global samplingModeVmax
global samplingModeDmax
global samplingModeDc
global sensorMode

series = 61;
stage = 5;
numSamplesStudied = 2;
startTimeStamp = 5;
startTime = 8;
endTime = 10;
startIndex = (startTime * 3600)/30 + 1;
endIndex = (endTime * 3600)/30 + 1;
studySensors = [400468; 400698];
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

% load prior and posterior
fileName = (['.\Configurations\fundamental_setting\FUN_CONFIG-' num2str(cali_configID) '.csv']);
fid=fopen(fileName);
funForLinks=textscan(fid,'%d %f %f %f %f %f %f','delimiter',',','headerlines',1);
vmax_mean = funForLinks{2};
dmax_mean = funForLinks{3};
dc_mean = funForLinks{4};
vmax_var = funForLinks{5};
dmax_var = funForLinks{6};
dc_var = funForLinks{7};
fclose(fid);
% load(['.\ResultCollection\series' num2str(series) '\-calibrationResult.mat']);

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

% load boundary data
[boundaryDataMatrix] = getNoisySensorData_network(studySensors, PARAMETER.T,...
    PARAMETER.startTime, PARAMETER.endTime);


ROUND_SAMPLES = initializeAllSamples(linkMap);
% SIMULATION
for sample = 1 : (2 * numSamplesStudied)
    [LINK, JUNCTION, SOURCE_LINK, SINK_LINK] = preloadAndCompute(linkMap, nodeMap, PARAMETER.T, PARAMETER.startTime, PARAMETER.endTime);
    
    if sample <= 1 * numSamplesStudied
        for i = 1 : length(LINK)
            guessed_FUNDAMENTAL.vmax = vmax_mean(i);
            guessed_FUNDAMENTAL.dmax = dmax_mean(i);
            guessed_FUNDAMENTAL.dc = dc_mean(i);
            [FUNDAMENTAL(i)] = sampleFUNDA(guessed_FUNDAMENTAL, vmax_var(i), dmax_var(i), dc_var(i));
        end
    else        
        load(['.\ResultCollection\series' num2str(series) '\-acceptedPop-stage-' num2str(stage) '.mat']);
        for i = 1 : length(LINK)
            FUNDAMENTAL(i).vmax = ACCEPTED_POP(i).samples(1,sample);
            FUNDAMENTAL(i).dmax = ACCEPTED_POP(i).samples(2,sample);
            FUNDAMENTAL(i).dc = ACCEPTED_POP(i).samples(3,sample);
        end
    end
    
    % run simulation
    [LINK, ROUND_SAMPLES] = runSimulationForSample(FUNDAMENTAL, PARAMETER, CONFIG, simu_configID, sample, simu_sensorEvolutionDataFolder,...
        LINK, JUNCTION, SOURCE_LINK, SINK_LINK, ROUND_SAMPLES);
    
    % all links density results
    save([simu_linkEvolutionDataFolder '\LINK-CONFIG-' num2str(cali_configID) '-sample-' num2str(sample)],'LINK');
    
    % get model simulation data (cumulative)
    modelDataMatrix = getModelSimulation_analyze(simu_configID, sample, testingSensorIDs, PARAMETER.T, PARAMETER.deltaTinSecond, ROUND_SAMPLES);
    
    % save cumulative density Matrix
    save([simu_sensorEvolutionDataFolder '\' num2str(sample) '\cumuDensity'],'modelDataMatrix');
    
    if mod(sample, 2) == 0
        disp(['sample ' num2str(sample) ' is finished']);
    end
end



% PLOT
figure
for i = 1 : length(testingSensorIDs)
    
    subplot(2,1,i)
    
    for j = 1 : (1 * numSamplesStudied)
        load(['.\Result\testingData\config-' num2str(simu_configID) '\' num2str(j) '\cumuDensity.mat']);  % prior
        density = modelDataMatrix(:,i);
        h(1) = plot(density(startTimeStamp:end),'r');
        hold on
    end
    
    for j = (numSamplesStudied+1) : (2 * numSamplesStudied)
        load(['.\Result\testingData\config-' num2str(simu_configID) '\' num2str(j) '\cumuDensity.mat']);  % prior
        density = modelDataMatrix(:,i);
        h(2) = plot(density(startTimeStamp:end),'k');
    end

    sensorData = sensorDataMatrix(:,i);
    h(3) = plot(sensorData(startTimeStamp+1:end), 'g');
    h(4) = plot(boundaryDataMatrix(startTimeStamp+1:end,1), 'm*');
    h(5) = plot(boundaryDataMatrix(startTimeStamp+1:end,2), 'b*');
    xlabel('time');
    ylabel('density');
    legend(h,'prior', 'posterior','true');
    hold off
    
    saveas(gcf, ['../Plots\series' num2str(series) '\predictionSensorPriorVsPosVsBoundary_sensor_ ' num2str(testingSensorIDs(i)) '_acceptedSamples.pdf']);
    saveas(gcf, ['../Plots\series' num2str(series) '\predictionSensorPriorVsPosVsBoundary_sensor_ ' num2str(testingSensorIDs(i)) '_acceptedSamples.fig']);
    saveas(gcf, ['../Plots\series' num2str(series) '\predictionSensorPriorVsPosVsBoundary_sensor_ ' num2str(testingSensorIDs(i)) '_acceptedSamples.eps'], 'epsc');
end
