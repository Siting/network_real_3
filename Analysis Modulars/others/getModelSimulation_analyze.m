function[modelDataMatrix] = getModelSimulation_analyze(simu_configID, sample, testingSensorIDs, T, deltaTinSecond, ROUND_SAMPLES)

c = (T*60)/deltaTinSecond;

for i = 1 : length(testingSensorIDs)
    sensorID = testingSensorIDs(i);
    load(['.\Result\testingData\config-' num2str(simu_configID) '\' num2str(sample) '\' num2str(testingSensorIDs(i)) '-true.mat']);  % pos
    
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