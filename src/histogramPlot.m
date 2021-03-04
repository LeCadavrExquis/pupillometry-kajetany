histData = zeros(1, length(ALLEEG));

for i = 1 : length(ALLEEG)
    eeg = ALLEEG(i);
    betterEye = 1;
    tmp = [];
    for j = 1 : length(eeg.data(1, 1, :))
        if(sum(isnan(eeg.data(1, :, j))) > sum(isnan(eeg.data(2, :, j))))
            betterEye = 2;
        end
        tmp = [tmp; sum(isnan(eeg.data(betterEye, :, j)))/(length(eeg.data(1, :, j)))];
    end
    histData(i) = mean(tmp);
end

histogram(histData,20);
xlabel('%');
ylabel('Count');
title("Histogram of % interpolation [better eye]");