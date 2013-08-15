clear all
clc

series = 74;
studyStages = [1;3;5;7;9;];
studyLinks = [1;3;5;7;9];
numSampleStudied = 100;
linkLengths = [0.1; 1; 0.25; 0.18; 0.5];  % unit: mile
sensorOffsets = [0.2; 0.1];   % unit: mile
sensorIDs = [400739; 400363];

travelTimeCollection_sensor_1 = [];
travelTimeCollection_sensor_2 = [];
for j = 1 : length(studyStages)
    stage = studyStages(j);
    % load accepted samples
    load(['.\ResultCollection\series' num2str(series) '\-acceptedPop-stage-' num2str(j) '.mat']);
    travelTimeCollection_1 = [];
    travelTimeCollection_2 = [];
    for k = 1 : numSampleStudied
        sample_link1 = ACCEPTED_POP(1).samples(:,k);
        sample_link3 = ACCEPTED_POP(3).samples(:,k);
        sample_link5 = ACCEPTED_POP(5).samples(:,k);
        sample_link7 = ACCEPTED_POP(7).samples(:,k);
        sample_link9 = ACCEPTED_POP(9).samples(:,k);
        for i = 1 : length(sensorIDs)
            sensorID = sensorIDs(i);
            w_1 = sample_link5(1) * sample_link5(3) / (sample_link5(2)-sample_link5(3));
            w_2 = sample_link7(1) * sample_link7(3) / (sample_link7(2)-sample_link7(3));
            w_3 = sample_link9(1) * sample_link9(3) / (sample_link9(2)-sample_link9(3));
            if i == 1
                travelTime1 = linkLengths(5)/w_3 + linkLengths(4)/w_2 + (linkLengths(3)-sensorOffsets(1))/w_1;
            elseif i == 2
                travelTime2 = linkLengths(5)/w_3 + (linkLengths(4)-sensorOffsets(2))/w_2;
            end
        end
        travelTimeCollection_1 = [travelTimeCollection_1; travelTime1];
        travelTimeCollection_2 = [travelTimeCollection_2; travelTime2];
        
    end
    travelTimeCollection_sensor_1 = [travelTimeCollection_sensor_1 travelTimeCollection_1];
    travelTimeCollection_sensor_2 = [travelTimeCollection_sensor_2 travelTimeCollection_2];
end

figure
subplot(2,1,1)
boxplot(travelTimeCollection_sensor_1*60, 'labels', studyStages);
title('sensor 400739');
xlabel('stage');
ylabel('travel time(min)');

subplot(2,1,2)
boxplot(travelTimeCollection_sensor_2*60, 'labels', studyStages);
title('sensor 400363');
xlabel('stage');
ylabel('travel time(min)');

saveas(gcf, ['../Plots\series' num2str(series) '\congestion_travelTime.pdf']);
saveas(gcf, ['../Plots\series' num2str(series) '\congestion_travelTime.fig']);
saveas(gcf, ['../Plots\series' num2str(series) '\congestion_travelTime.eps'], 'epsc');

