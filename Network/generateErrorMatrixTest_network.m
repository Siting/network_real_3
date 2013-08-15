function[errorMatrix] = generateErrorMatrixTest_network(modelData, sensorData, tSensorIDs)
global errorStart
errorMatrix = -10000 * ones(size(modelData(errorStart:end,1)), length(tSensorIDs));

for i = 1 : size(errorMatrix,2)
    errorMatrix(:,i) = abs(sensorData(errorStart:end,i) - modelData(errorStart:end,i));
end