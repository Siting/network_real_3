clear all
clc

series = 70;
studyStages = [5];
studyLinks = [1;3;5;7];
numSampleStudied = 100;
studyParameters = [1;];

for i = 1 : length(studyParameters)
    parameter = studyParameters(i);
    for j = 1 : length(studyStages)
        stage = studyStages(j);
        % load accepted samples
        load(['.\ResultCollection\series' num2str(series) '\-acceptedPop-stage-' num2str(j) '.mat']);
        sampleCollection = [];
        for k = 1 : length(studyLinks)
            link = studyLinks(k);
            samples = ACCEPTED_POP(link).samples(parameter,1:numSampleStudied);
            sampleCollection = [sampleCollection, samples'];
        end
    end
end
keyboard
[r,p] = corrcoef(sampleCollection);
[i,j] = find(p<0.05);

figure
plot(sampleCollection(:,1),'r.');
hold on
plot(sampleCollection(:,2),'k.');
plot(sampleCollection(:,3),'b.');
plot(sampleCollection(:,2),'g.');
grid on
