function butterfly(ALLEEG, eventType, events, group, condition, doSave)
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
    ylim([-0.3,0.3]);
    text(0, 0.04, txt);
    if(doSave)
        saveas(gcf, "" + eventType + "_" + group + ".jpg");
    end

    if(~doSave)
        pause(5);
    end
    plot(eeg.times, mean(acc, 'omitnan'));
    title(append(tit, " -> MEAN"));
    xline(0, '--r');
    ylim([-0.3,0.4]);
    text(0, 0.84, txt);
    if(doSave)
        saveas(gcf, "" + eventType + "_" + group + "_MEAN" + ".jpg");
    end
end