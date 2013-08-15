function[sinkFeed] = updateAllSink(SINK_LINK,page,nT, LINK, deltaTinSecond, occuDataMatrix_sink)

global occuThreshold

global sensorMode

for i = 1 : length(SINK_LINK)
    link = SINK_LINK(i);
    incomingLinkID = link.incomingLinkID;
    incomingLink = LINK(incomingLinkID);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if sensorMode == 2
        index = ceil((page-1)/nT);
        flowDataSum = link.densityResult(index) * 60 * (60/deltaTinSecond);
        flowDataSum(find(flowDataSum>link.vmax*link.dc))= link.vmax*link.dc;
        occuData = occuDataMatrix_sink(index,i);
        if occuData >= occuThreshold
            densityDataSum = link.dmax - flowDataSum./(link.vmax*link.dc)*(link.dmax-link.dc);
        else
            densityDataSum = flowDataSum/link.vmax;
        end        
        sinkFeed(incomingLinkID) = densityDataSum;
    elseif sensorMode == 1       
        sinkFeed(incomingLinkID) = link.densityResult(ceil((page-1)/nT));
    else
        disp('there is error assigning sensorMode');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end