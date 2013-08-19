function[ROUND_SAMPLES] = updateRoundSamples_newStrategy(LINK, ROUND_SAMPLES)

ROUND_SAMPLES(5).samples(1) = LINK(5).vmax;
ROUND_SAMPLES(5).samples(2) = LINK(5).dmax;
ROUND_SAMPLES(7).samples(1) = LINK(7).vmax;
ROUND_SAMPLES(7).samples(2) = LINK(7).dmax;
