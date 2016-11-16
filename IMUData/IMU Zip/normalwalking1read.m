filename = 'Stopping 1 csv.csv';
data1 = csvread(filename);
data2 = csvread('Normal Walking csv.csv');
data3 = csvread('FOG 1 csv.csv');


            time = data1(:,1);
            figure('Name','Normal Stopping - Pitch Angle')
            plot(time, data1(:,9))
            xlabel('Time (s)');
            ylabel('Pitch angle (rad)');
           
            time = data2(:,1);
            figure('Name','Normal Walking - Pitch Angle')
            plot(time, data2(:,9))
            xlabel('Time (s)')
            ylabel('Pitch angle (rad)')
            
            time = data3(:, 1);
            figure('Name','Freezing of Gait - Pitch Angle')
            plot(time, data3(:,9))
            xlabel('Time (s)')
            ylabel('Pitch angle (rad)')
            
            % x acceleration
            
             time = data1(:,1);
            figure('Name','Normal Stopping - X Acceleration')
            plot(time, data1(:,2))
            xlabel('Time (s)');
            ylabel('Acceleration (m/s^2)');
            
            time = data2(:,1);
            figure('Name','Normal Walking - X Acceleration')
            plot(time, data2(:,2))
            xlabel('Time (s)')
            ylabel('Acceleration (m/s^2)')
            
            time = data3(:, 1);
            figure('Name','Freezing of Gait - X Acceleration')
            plot(time, data3(:,2))
            xlabel('Time (s)')
            ylabel('Acceleration (m/s^2)')