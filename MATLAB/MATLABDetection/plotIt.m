function plotIt(trial, filter)
    time = trial(:,9) - trial(1,9);
    figure('Name','Whatever')
    if filter == 1
        better = smootheIt(trial(:,3));
        plot(time, better)
    else
        plot(time, trial(:,3))
    end
    xlabel('Time (s)');
    ylabel('Acceleration m/s^2');
end