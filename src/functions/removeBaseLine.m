function resultEeg = removeBaseLine(eeg, baseRange, extraSearchRange)
    resultEeg = eeg;
    for i = 1 : size(eeg.data,3)
        for j = 1 : 2
            baseMean = mean(eeg.data(j, baseRange(1) : baseRange(2), i),'omitnan');
            if(isnan(baseMean))
                baseMean = mean(eeg.data(j, (extraSearchRange + baseRange(1)):baseRange(2), i), 'omitnan');
                if(isnan(baseMean))
                    warning("All NaN values in mean range ("+eeg.setname+")");
                end
            end
            resultEeg.data(j,:,i) = (eeg.data(j,:,i) - baseMean)/baseMean;
        end
    end
end