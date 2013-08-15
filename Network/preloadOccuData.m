function[occuDataMatrix_source, occuDataMatrix_sink] = preloadOccuData(boundarySourceSensorIDs, boundarySinkSensorIDs)

occuDataMatrix_source = [];
occuDataMatrix_sink = [];

for i = 1 : length(boundarySourceSensorIDs)
    sensorID = boundarySourceSensorIDs(i);
    load(['.\SensorData_occu\' num2str(sensorID) '.mat']);
    occuDataMatrix_source(:,i) = max(occuDataLanes,[],2);
end

for i = 1 : length(boundarySinkSensorIDs)
    sensorID = boundarySinkSensorIDs(i);
    load(['.\SensorData_occu\' num2str(sensorID) '.mat']);
    occuDataMatrix_sink(:,i) = max(occuDataLanes,[],2);
end
