function missHistogram(ALLEEG)
    histData = [];

    runs = [3,4];
    condition = "rewards";

    for set = ALLEEG

        if(~any(runs(:) == set.session) || ~(set.condition == condition))
            continue;
        end
        for j = 1 : length(set.data(1, 1, :))        
            histData = [histData; 100*sum(isnan(set.data(1, :, j)))/length(set.times)];
        end
    end

    hist(histData,20);
    xlabel('%');
    ylabel('n');
    title("Histogram of NaN [better eye] | run: " + runs(1) + ", " + runs(2) + " | " + condition);
end