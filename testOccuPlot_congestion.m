clear all
clc

boundarySourceSensorIDs = [400468; 402955; 402954; 402950];
% boundarySinkSensorIDs = [402953; 400698];
boundarySinkSensorIDs = [400739; 400363];
[occuDataMatrix_source, occuDataMatrix_sink] = preloadOccuData(boundarySourceSensorIDs, boundarySinkSensorIDs);

% plot(occuDataMatrix_source);
% legend(num2str(boundarySourceSensorIDs));

figure
plot(occuDataMatrix_sink);
legend(num2str(boundarySinkSensorIDs));