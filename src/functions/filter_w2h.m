function data = filter_w2h(rawData, w2h)
    w2h_UPPER_THRESHOLD = 1.4;
    w2h_LOWER_THRESHOLD = 0.6;
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    data = NaN(1, length(rawData));
    for i = 1 : length(data)
        if(w2h(i) < w2h_UPPER_THRESHOLD && w2h(i) > w2h_LOWER_THRESHOLD)
            data(i) = rawData(i);
        end
    end
end

