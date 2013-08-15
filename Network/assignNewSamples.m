function[LINK] = assignNewSamples(vmax1, vmax3, vmax5, vmax7, dmax5, dmax7, dmax9, LINK)

LINK(1).vmax = vmax1;
LINK(3).vmax = vmax3;
LINK(5).vmax = vmax5;
LINK(7).vmax = vmax7;
LINK(5).dmax = dmax5 * LINK(5).numLanes;
LINK(7).dmax = dmax7 * LINK(7).numLanes;
LINK(9).dmax = dmax9 * LINK(9).numLanes;