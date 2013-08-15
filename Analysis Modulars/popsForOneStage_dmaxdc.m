clear all
clc

series = 76;
studyStages = [9];
studyLinks = [9];
cali_configID = 41;
cali_paraID = 41;
simu_configID = series+100;
time = 3;

for j = 1 : length(studyLinks)
    link = studyLinks(j);
    for i = 1 : length(studyStages)
        stage = studyStages(i);
        load(['.\ResultCollection\series' num2str(series) '\-sampledAndPertubed-stage-' num2str(stage) '-time-' num2str(time) '.mat']);
        population_1 = POPULATION_1(link).samples;
        population_2 = POPULATION_2(link).samples;
        population_3 = POPULATION_3(link).samples;
        population_4 = POPULATION_4(link).samples;
        
        
        figure(j*i)
        %2D
        h(1) = scatter(population_1(2,:),population_1(3,:),'r', 'filled');    % previous
        hold on
        S = repmat([3]*10,numel(population_3(1,:)),1);
        h(2) = scatter(population_3(2,:),population_3(3,:),'k', 'filled');    % accepted
        
        h(3) = scatter(population_4(2,:),population_4(3,:),'b', 'filled');          % rejected
        legend(h, 'new samples','accepted', 'rejected');
        xlabel('\rho_{max}');
        ylabel('\rho_c');
        title(['2D plot of all generated samples at one stage ' num2str(stage) ' of link ' num2str(link) '.']);

        saveas(gcf, ['../Plots\series' num2str(series) '\popOneStage_stage_' num2str(stage) '_link_' num2str(link) '_time_' num2str(time) '.pdf']);
        saveas(gcf, ['../Plots\series' num2str(series) '\popOneStage_stage_' num2str(stage) '_link_' num2str(link) '_time_' num2str(time) '.fig']);
        saveas(gcf, ['../Plots\series' num2str(series) '\popOneStage_stage_' num2str(stage) '_link_' num2str(link) '_time_' num2str(time) '.eps'], 'epsc');
    end
end