classdef FeatureDefiner < handle
    properties 
        lastValue;
        lastTime;
        valueDiffFromLast;
        timeDiffFromLast;
        slopeFromLast;
        
        troughLowThreshold;
        troughMinTime;
        troughStartTime;
        troughActive;
        troughMiddleDetected;
        troughLowest;
    end
    
    methods
        function fd = FeatureDefiner()
            fd.lastValue = 0;
            fd.lastTime = 0;
            fd.valueDiffFromLast = 0;
            fd.timeDiffFromLast = 0;
            fd.slopeFromLast = 0;
        
            fd.troughLowThreshold = 0;
            fd.troughMinTime = 0;
            fd.troughStartTime = 0;
            fd.troughActive = false;
            %fd.troughMid = false;
            fd.troughLowest = 0;
        end
        
        function [startTime, endTime, lowest] = ProcessData(fd, value, time)
          fd.valueDiffFromLast = value - fd.lastValue;
          fd.timeDiffFromLast = time - fd.lastTime;
          startTime = 0;
          endTime = 0;
          lowest = 0;
          
          if fd.timeDiffFromLast > 0
              fd.slopeFromLast = fd.valueDiffFromLast/fd.timeDiffFromLast;
          end
          
          fd.lastTime = time;
          
          if value < fd.troughLowThreshold && fd.troughActive == false && fd.lastValue > fd.troughLowThreshold
            fd.troughActive = true;
            fd.troughStartTime = fd.lastTime;           
          end
          
          fd.lastValue = value;
          
          if fd.troughActive && fd.lastValue < fd.troughLowest
            fd.troughLowest = fd.lastValue; 
          end
                  
          if fd.troughActive && fd.lastValue >= fd.troughLowThreshold
              fd.troughActive = false;
              
              if fd.lastTime >= fd.troughMinTime + fd.troughStartTime
                  startTime = fd.troughStartTime;
                  endTime = fd.lastTime;
                  lowest = fd.troughLowest;
                  fd.troughLowest = 0;
              end
          end    
        end
    end
end
      
        
        
        
        