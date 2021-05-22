function processedData = filter_w2h(rawData, w2h)
    w2h_UPPER_THRESHOLD = 1.3;
    w2h_LOWER_THRESHOLD = 0.7;

    processedData = NaN(1, length(rawData));
    for i = 1 : length(processedData)
        if((w2h(i) < w2h_UPPER_THRESHOLD) && (w2h(i) > w2h_LOWER_THRESHOLD))
            processedData(i) = rawData(i);
        end
    end
end

