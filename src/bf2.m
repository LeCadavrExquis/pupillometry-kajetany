eventsRewards = containers.Map(...
    ["UCSp porn", "UCSp cash", "No UCSp", "No UCSp cash", "No UCSp_porn"],...
    [{["plan_UCSp_porn", "unpl_UCSp_porn"]},...
    {["plan_UCSp_cash", "unpl_UCSp_cash"]},...
    {["NoUCsm", ""]},...
    {["plan_No_UCSp_cash","unpl_No_UCSp_cash"]},...
    {["plan_No_UCSp_porn", "unpl_No_UCSp_porn"]}]);
eventsCues = containers.Map(...
    ["CS Minus", "win CS Cash", "lose CS Cash", "lose CS Porn", "win CS Porn"],...
    [
    {"CS_Minus"},...
    {"to_win_CS_Plus_Cash"},...
    {"to_lose_CS_Plus_Cash"},...
    {"to_lose_CS_Plus_Porn"},...
    {"to_win_CS_Plus_Porn"}
    ]);

cd("../plots/butterfly_pure")

for i = 1 : 3
    %i stands for group
    for key = keys(eventsRewards)
        drawButterFly(alleeg2, key{1}, eventsRewards(key{1}), i, "rewards");
    end
    
        
    for key = keys(eventsCues)
        drawButterFly(alleeg2, key{1}, eventsCues(key{1}), i, "cues")
    end    
end



%%
function drawButterFly(ALLEEG, eventType, events, group, condition)
acc = [];
for i = 1 : length(ALLEEG)
    eeg = ALLEEG(i);
    if(condition ~= eeg.condition)
        continue;
    end
    if(group ~= eeg.group)
        continue;
    end

    for j = 1 : length(eeg.epoch)
        if(sum(events == eeg.epoch(j).eventtype) == 0)
            continue;
        end
        
        acc = [acc; eeg.data(1, :, j)]; %#ok<AGROW>
    end
end
[n,~] = size(acc);
tit = "" + eventType + " | group: " + group;
txt = "epochs :" + n;

figure(8);
clf;
hold on;
for i = 1 : n
    plot(eeg.times, acc(i,:));
end
hold off;

title(tit);
xline(0, '--r');
ylim([-0.05,0.05]);
text(0, 0.04, txt);
saveas(gcf, "" + eventType + "_" + group + ".jpg");


plot(eeg.times, mean(acc, 'omitnan'));
title(append(tit, " -> MEAN"));
xline(0, '--r');
ylim([-0.05,0.05]);
text(0, 0.04, txt);
saveas(gcf, "" + eventType + "_" + group + "_MEAN" + ".jpg");

end