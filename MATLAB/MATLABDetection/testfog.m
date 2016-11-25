
theFog = Fogger();

for i= 1:length(walkarray)
    theFog.step(walkarray{1,i});
end
for i= 1:length(fogarray)
    theFog.step(fogarray{1,i});
end
for i= 1:length(stoparray)
    theFog.step(stoparray{1,i});
end

theFog.outputResult();

figure ('Name', 'Widths vs Min Values')
plot(theFog.fogData(1,:),theFog.fogData(2,:), 'rx')
hold on
plot(theFog.normData(1,:),theFog.normData(2,:), 'bx')
hold on
line(500, get(gca, 'ylim'));
xlabel('Widths (s)');
ylabel('Min Values');
