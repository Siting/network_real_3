function[LINK, SOURCE_LINK, SINK_LINK, JUNCTION, ROUND_SAMPLES] = updateFundamentalFor_network(LINK, SOURCE_LINK, SINK_LINK, JUNCTION, FUNDAMENTAL, deltaT,...
    numEns, CONFIG, linkMap, POPULATION_2, index, ROUND_SAMPLES)
global sensorMode

linkIDs = linkMap.keys;

% LINK
for i = 1 : length(linkIDs)
    link = LINK(linkIDs{i});
    pop2 = POPULATION_2(linkIDs{i});
    link.vmax = pop2.samples(1, index);
    link.dc = link.numLanes * pop2.samples(3, index);
    link.dmax = link.numLanes * pop2.samples(2, index);
    link.densityResult = [];
    LINK(linkIDs{i}) = link;
    
    if sensorMode == 2
        if i == 5 || i == 7
            
            sample = [link.vmax; link.dmax; link.dc];
            ROUND_SAMPLES(i).samples = [ROUND_SAMPLES(i).samples sample];
        end
    end
    
end

% initialize links
[LINK] = initializeAllLinks(LINK, deltaT, numEns, CONFIG);

[SOURCE_LINK, SINK_LINK] = setFundamentalParameters_network(SOURCE_LINK, SINK_LINK, FUNDAMENTAL, linkMap, LINK);