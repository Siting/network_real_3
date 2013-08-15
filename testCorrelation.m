clear all
clc
% check correlation between three parameters for each link
studyLinks = [1;3;5;7;9];
series = 70;
stage = 7;
numSamplesStudied = 100;

load(['.\ResultCollection\series' num2str(series) '\-acceptedPop-stage-' num2str(stage) '.mat']);

for i = 1 : length(studyLinks)
    link = studyLinks(i);
    samples = ACCEPTED_POP(link).samples(:,1:numSamplesStudied);
    [R,p]=corrcoef(samples');
    [i,j] = find(p<0.05);
    [i j]
    keyboard
end

