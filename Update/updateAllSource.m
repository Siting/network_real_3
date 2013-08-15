function[sourceFeed] = updateAllSource(SOURCE_LINK,page,nT, LINK, deltaTinSecond, occuDataMatrix_source)

global occuThreshold

if isempty(occuThreshold) == 1
    disp('occuThreshold not assigned');
end

% linkIds = SOURCE_LINK.keys;
global sensorMode
for i = 1 : length(SOURCE_LINK)
    link = SOURCE_LINK(i);
    outgoingLinkID = link.outgoingLinkID;
    outgoingLink = LINK(outgoingLinkID);
    %%%%%%%%%%%%%%%%%%%%%
    if sensorMode == 2
        index = ceil((page-1)/nT);
        flowDataSum = link.densityResult(index) * 60 * (60/deltaTinSecond);
        flowDataSum(find(flowDataSum>link.vmax*link.dc))= link.vmax*link.dc;
        occuData = occuDataMatrix_source(index,i);
        if occuData >= occuThreshold 
            densityDataSum = link.dmax - flowDataSum./(link.vmax*link.dc)*(link.dmax-link.dc);
        else
            densityDataSum = flowDataSum/link.vmax;
        end
        sourceFeed(outgoingLinkID) = densityDataSum;
    elseif sensorMode == 1
        sourceFeed(outgoingLinkID) = link.densityResult(ceil((page-1)/nT));
    else
        disp('there is error assigning sensorMode');
    end
    %%%%%%%%%%%%%%%%%%%%%
end