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

series = 70;
stage = 7;
numSamplesStudied = 50;
startTimeStamp = 5;
studyLinks = [1; 3; 5; 7];
cali_configID = 41;
cali_paraID = 41;
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
    
    % extract sample for every link & assign to links
    for i = 1 : length(LINK)
        if sample == 1
            FUNDAMENTAL(i).vmax = vmax_mean(i);
            FUNDAMENTAL(i).dmax = dmax_mean(i);
            FUNDAMENTAL(i).dc = dc_mean(i);
        elseif sample == 2
            load(['.\ResultCollection\series' num2str(series) '\-calibrationResult-stage' num2str(stage) '.mat']);
            FUNDAMENTAL(i).vmax = meanForLinks(1, i);
            FUNDAMENTAL(i).dmax = meanForLinks(2, i);
            FUNDAMENTAL(i).dc = meanForLinks(3, i);
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
    
    if mod(sample, 20) == 0
        disp(['sample ' num2str(sample) ' is finished']);
    end
end

% PLOT
figure

for i = 1 : length(testingSensorIDs)
    subplot(2,1,i)
    
    load(['.\Result\testingData\config-' num2str(simu_configID) '\1\cumuDensity.mat']);  % prior
    priorDensityMatrix = modelDataMatrix(:,i);
    
    load(['.\Result\testingData\config-' num2str(simu_configID) '\2\cumuDensity.mat']);  % pos
    postDensityMatrix = modelDataMatrix(:,i);
    
    sensorData = sensorDataMatrix(:,i);   % sensor
    
    plot(priorDensityMatrix(startTimeStamp:end),'r');
    hold on
    plot(postDensityMatrix(startTimeStamp:end), 'k');
    plot(sensorData(startTimeStamp+1:end), 'g');
    legend('prior','pos','true');
    hold off
end

saveas(gcf, ['../Plots\series' num2str(series) '\predictionSensorPriorVsPos_sensor_ ' num2str(testingSensorIDs(i)) '_mean_acceptedSamples.pdf']);
saveas(gcf, ['../Plots\series' num2str(series) '\predictionSensorPriorVsPos_sensor_ ' num2str(testingSensorIDs(i)) '_mean_acceptedSamples.fig']);
saveas(gcf, ['../Plots\series' num2str(series) '\predictionSensorPriorVsPos_sensor_ ' num2str(testingSensorIDs(i)) '_mean_acceptedSamples.eps'], 'epsc');
