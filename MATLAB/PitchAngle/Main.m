mc = MotionCapture(frequency, positions, freezing)

for i = 1:30
    count = 1;
    troughs = [];
    currentTrial = mc.getPitchAngle(i);
    fd = FeatureDefiner();
    disp(sprintf('Trial: %d', i))
    foundFOG = false;
    for j = 1:size(currentTrial)
       
       [startTime, endTime, lowest] = fd.ProcessData(currentTrial(j), j/30);
       if endTime - startTime > 0 && foundFOG == false
           if endTime - startTime < 0.4 && lowest > -0.5
               disp(sprintf('FOG: %g', j/30))
               foundFOG = true;
           else 
               disp(sprintf('NORMAL'))
           end
           %troughs(1, count) = startTime;
           %troughs(2, count) = endTime;
           %count = count + 1;
       end       
    end
end
