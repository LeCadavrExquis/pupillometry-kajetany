%% FUNCTION butterfly
% diplays pupilometric signals from selected parameters; one line on a
% graph corresponds to mean signal from one subject and selected events
% @param eventType: String - title for graph
% @param events: array<String> - event types todr
% @param group: Int - {0 or 1 or 2}
% @param condition: String - {"cues" or "rewards"}
% @param doSave: Bool - true if you want to save a result graph
% example usage: butterfly(ALLEEG, "UCSp porn",["plan_UCSp_porn","plan_No_UCSp_porn"], 2, "rewards", true)
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
    %%   
    [n,~] = size(acc);
    tit = "" + eventType + " | group: " + group;
    txt = "epochs :" + n;

    figure(8);
    cla;
    title(tit);
    xline(0, '--r');
    ylim([-1,3]);
    text(0, 0.04, txt);
    hold on;
    for i = 1 : n
        plot(eeg.times, acc(i,:));
        pause(0.1);
    end    
    hold off;
    if(doSave)
        saveas(gcf, "" + eventType + "_" + group + ".jpg");
    end

    figure(9);
    cla;
    plot(eeg.times, mean(acc, 'omitnan'));
    title(append(tit, " -> MEAN"));
    xline(0, '--r');
    ylim([0.5,1.5]);
    text(0, 0.84, txt);
    if(doSave)
        saveas(gcf, "" + eventType + "_" + group + "_MEAN" + ".jpg");
    end
end