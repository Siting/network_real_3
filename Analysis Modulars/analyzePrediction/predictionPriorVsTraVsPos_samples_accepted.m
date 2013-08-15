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
global occuThreshold

series = 75;
traConfigID = 1;
stage = 7;
cali_configID = 43;
cali_paraID = 43;
numSamplesStudied = 30;
startTimeStamp = 5;
occuThreshold = 0.2;
studyLinks = [1; 3; 5; 7];
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
for sample = 1 : (2 * numSamplesStudied)+1
    [LINK, JUNCTION, SOURCE_LINK, SINK_LINK] = preloadAndCompute(linkMap, nodeMap, PARAMETER.T, PARAMETER.startTime, PARAMETER.endTime);
    % pre-load occupancy data
    [occuDataMatrix_source, occuDataMatrix_sink] = preloadOccuData(boundarySourceSensorIDs, boundarySinkSensorIDs);
    
    if sample <= 1 * numSamplesStudied
        for i = 1 : length(LINK)
            guessed_FUNDAMENTAL.vmax = vmax_mean_prior(i);
            guessed_FUNDAMENTAL.dmax = dmax_mean_prior(i);
            guessed_FUNDAMENTAL.dc = dc_mean_prior(i);
            [FUNDAMENTAL(i)] = sampleFUNDA(guessed_FUNDAMENTAL, vmax_var_prior(i), dmax_var_prior(i), dc_var_prior(i));
        end
    elseif sample > numSamplesStudied && sample <= (2 * numSamplesStudied)    
        load(['.\ResultCollection\series' num2str(series) '\-acceptedPop-stage-' num2str(stage) '.mat']);
        for i = 1 : length(LINK)
            FUNDAMENTAL(i).vmax = ACCEPTED_POP(i).samples(1,sample);
            FUNDAMENTAL(i).dmax = ACCEPTED_POP(i).samples(2,sample);
            FUNDAMENTAL(i).dc = ACCEPTED_POP(i).samples(3,sample);
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
    
    if mod(sample, 2) == 0
        disp(['sample ' num2str(sample) ' is finished']);
    end
end


% PLOT
figure
for i = 1 : length(testingSensorIDs)
    
    subplot(2,1,i)
    % prior
    for j = 1 : (1 * numSamplesStudied)
        load(['.\Result\testingData\config-' num2str(simu_configID) '\' num2str(j) '\cumuDensity.mat']);  % prior
        density = modelDataMatrix(:,i);
        h(1) = plot(density(startTimeStamp:end),'r');
        hold on
    end
    % pos
    for j = (numSamplesStudied+1) : (2 * numSamplesStudied)
        load(['.\Result\testingData\config-' num2str(simu_configID) '\' num2str(j) '\cumuDensity.mat']);  % prior
        density = modelDataMatrix(:,i);
        h(2) = plot(density(startTimeStamp:end),'k');
    end

    sensorData = sensorDataMatrix(:,i);
    % true
    h(3) = plot(sensorData(startTimeStamp+1:end), 'g');
    % tra
    load(['.\Result\testingData\config-' num2str(simu_configID) '\' num2str((2 * numSamplesStudied)+1) '\cumuDensity.mat']);
    density = modelDataMatrix(:,i);
    h(4) = plot(density(startTimeStamp:end),'b', 'LineWidth',1);

    xlabel('time');
    ylabel('flow');
    legend(h,'prior', 'posterior','true', 'tra');
    hold off

    saveas(gcf, ['../Plots\series' num2str(series) '\predictionSensorPriorVsTraVSPos_sensor_ ' num2str(testingSensorIDs(i)) '_acceptedSamples.pdf']);
    saveas(gcf, ['../Plots\series' num2str(series) '\predictionSensorPriorVsTraVSPos_sensor_ ' num2str(testingSensorIDs(i)) '_acceptedSamples.fig']);
    saveas(gcf, ['../Plots\series' num2str(series) '\predictionSensorPriorVsTraVSPos_sensor_ ' num2str(testingSensorIDs(i)) '_acceptedSamples.eps'], 'epsc');
end
