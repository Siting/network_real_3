function[LINK, ROUND_SAMPLES] = loadLinksSample(LINK, FUNDAMENTAL, ROUND_SAMPLES)

for i = length(LINK) : -1 : 1
    LINK(i).vmax = FUNDAMENTAL(i).vmax;
    LINK(i).dmax = LINK(i).numLanes * FUNDAMENTAL(i).dmax;
    LINK(i).dc = LINK(i).numLanes * FUNDAMENTAL(i).dc;

    if i == 5 || i == 7    
        sample = [LINK(i).vmax; LINK(i).dmax; LINK(i).dc];
        ROUND_SAMPLES(i).samples = [ROUND_SAMPLES(i).samples sample];
    end
end
