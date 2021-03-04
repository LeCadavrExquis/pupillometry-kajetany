condition = "rewards";
event = [
    "plan_UCSp_porn",...
    "plan_UCSp_cash",...
    "unpl_UCSp_porn",...
    "unpl_UCSp_cash"
    ];
figure(10)
hold on
title("BF " + condition + " - UCSp");
xline(0, '--r');
ylim([-0.05,0.05]);

skipped = 0;
for i = 1 : length(ALLEEG)
    eeg = ALLEEG(i);
    acc = [];
    
    if(condition ~= eeg.condition)
        skipped = skipped + 1;
        continue;
    end
    
    for j = 1 : length(eeg.epoch)
        if(sum(event == eeg.epoch(j).eventtype) == 0)
            continue;
        end
        
        betterEye = 1;
        if(eeg.epoch(j).noisePercentage_A > eeg.epoch(j).noisePercentage_B)
        betterEye = 2;
        end
        acc = [acc; eeg.data(betterEye, :, j)]; %#ok<AGROW>
    end

    plot(eeg.times, mean(acc));
end

hold off