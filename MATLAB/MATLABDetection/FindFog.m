
classdef FindFog < handle
    properties
        index;
        frequency;
        hillCount;
        trial;
        fogTrials;
        init;
        tmpAngles;
        angles;
        zeroRun;
    end
    methods
        function fog = FindFog(freq)
            fog.frequency = freq; %frequency
            fog.hillCount = 0;   %width (used for slope) of peaks
            fog.index = 0; %index of the trial, eventually used to find time
            fog.trial = 0;  %trial number, used for bookkeeping fogTrials array
            fog.fogTrials = zeros(fog.frequency, 2);  %2D array of whether its freezing (col 1) and onset times (col 2)
            fog.init = 0;   %don't start counting anything until very first 0 value is encountered
            fog.tmpAngles(1:fog.frequency) = -5;   %temporary list of angles of indices between acceleration hills
            fog.angles = zeros(fog.frequency); %the angles of the trial
            fog.zeroRun = 0;    %time between peeks
        end
        function step(fog, trial) %feed one trial at a time
            fog.trial = fog.trial + 1;
            fog.index = 0;
            niceVals = fog.makeNice(trial);
            fog.angles = fog.getAngles(trial);
            fog.tmpAngles(1:fog.frequency) = -5;
            fog.init = 0;
            for j= 1:length(trial) 
                freeze = fog.detectFog(niceVals(j,:));
                
                if freeze == 0
                    fog.index = fog.index + 1;
                else
                    fog.fogTrials(fog.trial,1) = freeze;
                    fog.fogTrials(fog.trial,2) = (fog.index/fog.frequency);
                    break;
                end
            end
        end
        function result = makeNice(fog, trial) %copied from MotionCapture (getAccelerations)
            data = trial;
            result = zeros(size(data));
            result(3:end-2,:) = (data(1:end-4,:) - 2*data(3:end-2,:) + data(5:end,:)) / (2/fog.frequency)^2;
            
            % extrapolate samples at beginning and end
            result(1:2,:) = repmat(result(3,:), 2, 1);
            result(end-1:end,:) = repmat(result(end-2,:), 2, 1);
            
        end
        function isFog = detectFog(fog, sample) %feed one sample at a time
            isFog = 0;
            apAcc = sample(1);  %AP Acceleration
            if (abs(apAcc) > 0.5 && fog.init == 0)  %always start at zero
                return
            end
            if isnan(apAcc) 
                apAcc = sample(2)/2; %AP acceleration is usually twice as big in magnitude as vertical acceleration
            end
            if (apAcc > 0.35 && fog.init == 1)
                angle = fog.angles(fog.index, 1);
                if isnan(angle) % if NaN, take value of last VALID angle
                    %NOTE: I could have alternatively saved a buffer of the
                    %last x number of angles but this is more efficient,
                    %even though it uses values generated from
                    %getPitchAngle, so I am still processing one sample at
                    %a time
                    start = fog.index;
                    if (fog.index > 0)
                        for n = 1:20
                            if start -1 > 0
                                angle = fog.angles(start -1);
                                if isnan(angle) == 0
                                    break;
                                end
                            else
                                angle = 0;
                                break;
                            end
                        end
                    end
                end
                fog.hillCount = fog.hillCount + 1;
                fog.tmpAngles(fog.hillCount) = angle;
                fog.zeroRun = 0;
            else
                if ((fog.hillCount/fog.frequency) < 0.4 && fog.init > 0 && fog.hillCount > 2)
                    fog.hillCount = 0;
                    fog.zeroRun = fog.zeroRun + 1;
                    maxAngle = max(fog.tmpAngles);
                    trueMax = max(maxAngle);
                    if trueMax > 0 && (fog.zeroRun/fog.frequency) < 0.1
                        isFog = 1;  %freezing confirmed
                    end
                else
                    fog.init = 1;
                    fog.zeroRun = fog.zeroRun + 1;
                    fog.hillCount = 0;
                end
            end
        end
        function angles = getAngles(fog, trial) %copied from MotionCapture (getPitchAngles)
            data = trial;           
            m2 = data(:,4:6); % marker 2 position
            m3 = data(:,7:9); 
            dm = m3-m2;
            hor = sum(dm(:,1:2).^2,2).^.5;
            ver = dm(:,3);
            angles = atan(ver ./ hor);
        end
        function outputResult(fog) %output results
            for i= 1:length(fog.fogTrials)
                disp(fog.fogTrials(i,1));   %freezing or not
                if fog.fogTrials(i) == 1
                    disp(fog.fogTrials(i,2));   %onset times
                end
            end
        end
    end
end