function[sourceFeed, sinkFeed] = updateFeedInData(SOURCE_LINK,SINK_LINK,page,nT, LINK, deltaTinSecond, occuDataMatrix_source, occuDataMatrix_sink)

sourceFeed = updateAllSource(SOURCE_LINK,page,nT, LINK, deltaTinSecond, occuDataMatrix_source);

sinkFeed = updateAllSink(SINK_LINK,page,nT, LINK, deltaTinSecond, occuDataMatrix_sink);