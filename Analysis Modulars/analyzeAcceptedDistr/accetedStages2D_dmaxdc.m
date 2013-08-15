clear all
clc

series = 75;
studyStages = [1;2;5;7];
studyLinks = [1:9];
numSamplesStudied = 100;

col=str2mat('r', 'g', 'b', 'k', 'y');
stagesString = [];
for i = 1 : length(studyStages)
    stage = studyStages(i);
    if stage < 10
        stagesString = [stagesString; ['stage ' num2str(studyStages(i)) ' ']];
    else
        stagesString = [stagesString; ['stage ' num2str(studyStages(i))]];
    end
end

for j = 1 : length(studyLinks)
    link = studyLinks(j);
    figure
    for i = 1 : length(studyStages)
        stage = studyStages(i);
        % load accepted samples of the stage
        load(['.\ResultCollection\series' num2str(series) '\-acceptedPop-stage-' num2str(stage) '.mat']);
        samples = ACCEPTED_POP(link).samples(:,1:numSamplesStudied);
        % plot
        h(i) = scatter(samples(2,:),samples(3,:), col(i), 'filled');   % accepted
        hold on
    end
    legend(h, stagesString);
    xlabel('\rho_{max}');
    ylabel('\rho_c');
    title(['2D plot of accepted samples of link ' num2str(link) ' using the ABC SMC method']);
    saveas(gcf, ['../Plots\series' num2str(series) '\acceptedSamplesStages_link_'...
        num2str(link) '_stages_' num2str(reshape(studyStages,1,length(studyStages))) '_dmaxdc.pdf']);
    saveas(gcf, ['../Plots\series' num2str(series) '\acceptedSamplesStages_link_'...
        num2str(link) '_stages_' num2str(reshape(studyStages,1,length(studyStages))) '_dmaxdc.fig']);
    saveas(gcf, ['../Plots\series' num2str(series) '\acceptedSamplesStages_link_'...
        num2str(link) '_stages_' num2str(reshape(studyStages,1,length(studyStages))) '_dmaxdc.eps'], 'epsc');
end



