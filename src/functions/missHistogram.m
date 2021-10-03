%% FUNCTION missHistogram
% display histogram of missing data percentage
% @param runs: [run1: Int, run2: Int, ...] - selected indexes of run
% @param condition: String - {"cues" or "rewards"}
% example usage: missHistogram(ALLEEG, [1,2], "rewards")
function missHistogram(ALLEEG, runs, condition)
    histData = [];

    for set = ALLEEG
        if(~any(runs(:) == set.run) || ~(set.condition == condition))
            continue;
        end
        for j = 1 : length(set.data(1, 1, :))        
            histData = [histData; 100*sum(isnan(set.data(1, :, j)))/length(set.times)];
        end
    end

    figure('Renderer', 'painters', 'Position', [10 10 1000 600]);
    hist(histData,20);
    xlabel('%');
    ylabel('n');
    title("Histogram of NaN | run: " + runs(1) + ", " + runs(2) + " | " + condition);
    xline(30, '--r');
end