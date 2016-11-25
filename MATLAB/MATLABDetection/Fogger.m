
classdef Fogger < handle
    properties
        %index;
        %frequency;
        trial;
        fogTrials;
        init;
        buffAmount;
        buffer;
        progress;
        lastMaxTime;
        lastVal;
        maxValue;
        maxTime;
        minValue;
        freezingTime;
        fogData;
        normData;
    end
    methods
        function fog = Fogger()
            %fog.frequency = freq; %frequency
            fog.trial = 0;  %trial number, used for bookkeeping fogTrials array
            fog.fogTrials = zeros(38, 2);  %2D array of whether its freezing (col 1) and onset times (col 2)
            fog.init = 0;   %don't start counting anything until very first 0 value is encountered
            fog.buffAmount = 20;
            %fog.index = fog.buffAmount; %index of the trial, eventually used to find time
            fog.buffer = zeros(fog.buffAmount);
            fog.progress = [];
            fog.lastVal = 0;
            fog.lastMaxTime = -5000; %max indices
            fog.maxValue = -10000;
            fog.maxTime = 0;
            fog.minValue = -12000;
            fog.freezingTime = 0;
            fog.fogData = [;];
            fog.normData = [;];
        end
        function step(fog, trial) %feed one trial at a time
            %fog.normData = [;];
            %fog.fogData = [;];
            fog.minValue = -12000;
            fog.trial = fog.trial + 1;
            fog.lastMaxTime = -5000;
            %fog.index = fog.buffAmount;
            fog.init = 0;
            niceVals = fog.makeNice(trial(:,3));
            trial(:,3) = niceVals;
            trial(:,9) = trial(:,9) - trial(1,9);
            for j=fog.buffAmount:length(trial)
                freeze = fog.detectFog(trial(j,:));
                if freeze == 0
                    %fog.progress = [fog.progress fog.lastVal];
                else
                    fog.fogTrials(fog.trial,1) = freeze;
                    fog.fogTrials(fog.trial,2) = fog.freezingTime;
                    %break;
                end
            end
            fog.progress = [];
        end
        function isFog = detectFog(fog, sample) %feed one sample at a time
%             if fog.index < fog.buffAmount
%                 isFog = 0;
%                 return;
%             end
            %updatedSample = updateBuffer(sample);
            
            isFog = 0; %innocent until proven guilty
            apAcc = sample(3);  %AcY data
            if (apAcc < -15000 && apAcc > -20000 && fog.init == 0)  %consistent starting value
                fog.init = 1;
                fog.lastVal = apAcc;
                return
            end
            
            if fog.init == 0
                fog.lastVal = apAcc;
                return
            end
            
            if apAcc > -12000 && fog.lastVal < -12000 %starting max shift
                %find last min
                %fog.minValue = -12000; %reset
                fog.maxValue = apAcc;
                fog.maxTime = sample(9);
            elseif apAcc > -12000 %max shift
                if apAcc > fog.maxValue
                    fog.maxValue = apAcc;
                    fog.maxTime = sample(9);
                end
            elseif apAcc < -12000 && fog.lastVal > -12000 %end of max shift or start of min shift
                %find last max
                %fog.minValue = -12000;
                if fog.lastMaxTime < 0
                    fog.lastMaxTime = fog.maxTime;
                    fog.maxValue = -10000;
                else
                    timeDiff = fog.maxTime - fog.lastMaxTime;
                    if timeDiff < 500 && fog.minValue > -25000
                        isFog = 1;
                        fog.freezingTime = sample(9);
                        fog.fogData(1,end+1) = timeDiff;
                        fog.fogData(2, end) = fog.minValue;
                    else
                        fog.normData(1,end+1) = timeDiff;
                        fog.normData(2, end) = fog.minValue;
                    end
                    fog.lastMaxTime = fog.maxTime;
                    fog.maxValue = -10000;
                    fog.minValue = -12000;
                end
                fog.minValue = apAcc;
            elseif apAcc < -12000 % min shift
                if apAcc < fog.minValue
                    fog.minValue = apAcc;
                end
            end
            fog.lastVal = apAcc;
        end
        function smooth = makeNice(fog, trial)
            buff = zeros(length(trial),1);
            for i = 1:length(trial)
                total = 0;
                if i >20
                     for j= i-fog.buffAmount:i
                        total = total + trial(j);
                     end
                     buff(i) = total/fog.buffAmount;
                end
            end
            smooth = buff;
        end
        function newBuffer = updateBuffer(fog, sample)
            if fog.index <= fog.buffAmount
                fog.buffer(fog.index) = sample;
            else
                for i=1:fog.buffAmount
                    if i == fog.buffAmount
                        fog.buffer(fog.buffAmount) = sample;
                    else
                        fog.buffer(i) = fog.buffer(i+1);
                    end
                end
            end
            newBuffer = smoothBuffer(fog.buffer);
        end
        function average = smoothBuffer(fog, buffer)
            average = 0;
            for i= 1:length(buffer)
                average = average + buffer(i);
            end
            average = average / length(buffer);
        end
        function outputResult(fog) %output results
            for i= 1:length(fog.fogTrials)
                disp(fog.fogTrials(i,1));   %freezing or not
                if fog.fogTrials(i) == 1
                    %disp(fog.fogTrials(i,1));
                    disp(fog.fogTrials(i,2));   %onset times
                end
            end
        end
    end
end