function[modelDataMatrix] = getModelSimulationDataCumu_network(configID, sample, tSensorIDs, T, deltaTinSecond, ROUND_SAMPLES)

c = (T*60)/deltaTinSecond;
for i = 1 : length(tSensorIDs)
    sensorID = tSensorIDs(i);
    % get density of sensors
    load(['.\Result\testingData\config-' num2str(configID) '\' num2str(sample) '\' num2str(sensorID) '-true']);
    
    % compute flow (unit: hr)
    if i == 1
        j = 5;
    elseif i == 2
        j = 7;
    end

    flow = Q(sensorData,ROUND_SAMPLES(j).samples(1,sample), ROUND_SAMPLES(j).samples(2,sample), ROUND_SAMPLES(j).samples(3,sample));

    % adjusted flow to the T time scale
    flow = flow ./ 60;  % unit: min
    flow = flow ./ (60/deltaTinSecond);  % unit: 2second

    % get cumulative flow
    cumulativeFlow = [];
    for j = 1 : (size(flow,1)/c)
        cumu = sum(flow(((j-1)*c+1) : (j*c)));
        cumulativeFlow = [cumulativeFlow;cumu];
    end
    modelDataMatrix(:,i) = cumulativeFlow;
end
