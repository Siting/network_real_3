function[FUNDAMENTAL] = sampleFUNDA(guessed_FUNDAMENTAL, vmaxVar, dmaxVar, dcVar)

global samplingModeVmax
global samplingModeDmax
global samplingModeDc

state = true;

vmaxMean = guessed_FUNDAMENTAL.vmax;
dmaxMean = guessed_FUNDAMENTAL.dmax;
dcMean = guessed_FUNDAMENTAL.dc;

% for uniform draw
vmaxLow = vmaxMean - 3 * sqrt(vmaxVar);
vmaxHigh = vmaxMean + 3 * sqrt(vmaxVar);
dmaxLow = dmaxMean - 3 * sqrt(dmaxVar);
dmaxHigh = dmaxMean + 3 * sqrt(dmaxVar);
dcLow = dcMean - 3 * sqrt(dcVar);
dcHigh = dcMean + 3 * sqrt(dcVar);

while(state)
    
    if samplingModeVmax == 1
        sampleVmax = normrnd(vmaxMean, sqrt(vmaxVar));      
    elseif samplingModeVmax == 2
        sampleVmax = vmaxLow + (vmaxHigh-vmaxLow).*rand(1,1);     
    end
    
    if samplingModeDmax == 1
        sampleDmax = normrnd(dmaxMean, sqrt(dmaxVar));
    elseif samplingModeDmax == 2
        sampleDmax = dmaxLow + (dmaxHigh-dmaxLow).*rand(1,1);
    end
    
    if samplingModeDc == 1
        sampleDc = normrnd(dcMean, sqrt(dcVar));
    elseif samplingModeDc == 2
        sampleDc = dcLow + (dcHigh-dcLow).*rand(1,1);
    end

    if sampleVmax > 0 && sampleDmax > 0 && sampleDc > 0 &&...
            sampleDmax > sampleDc && sampleVmax <= 170
        FUNDAMENTAL.vmax = sampleVmax;
        FUNDAMENTAL.dmax = sampleDmax;
        FUNDAMENTAL.dc = sampleDc;
        state = false;
    end
end