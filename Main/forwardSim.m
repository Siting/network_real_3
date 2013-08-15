function[LINK] = forwardSim(LINK,SOURCE_LINK,SINK_LINK,JUNCTION,page,...
    deltaT,ensemble,nT,junctionSolverType, occuDataMatrix_source, occuDataMatrix_sink)

deltaTinSecond = deltaT * 60 * 60;

[sourceFeed, sinkFeed] = updateFeedInData(SOURCE_LINK,SINK_LINK,page,nT, LINK, deltaTinSecond, occuDataMatrix_source, occuDataMatrix_sink);

[LINK] = updateAllJunctions(sourceFeed, sinkFeed, JUNCTION,LINK,page,ensemble,SOURCE_LINK,SINK_LINK, junctionSolverType);

[LINK] = updateAllLinks(LINK,deltaT,page,ensemble);