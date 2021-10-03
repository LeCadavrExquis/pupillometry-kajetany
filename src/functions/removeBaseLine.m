%% FUNCTION removeBaseLine
% divisive baseline; function does not check for argument correctnes
% @param baseRange: [startProbe: Int, endProbe: Int] - range of probes to
%                   take mean from
% @param extraSearchRange: Int - in case all probes are NaN mean is taken
%                   from a larger range (+/- extraSearchValue)
function resultEeg = removeBaseLine(eeg, baseRange, extraSearchRange)
    resultEeg = eeg;
    for i = 1 : size(eeg.data,3)
        for j = 1 : 2
            baseMean = mean(eeg.data(j, baseRange(1) : baseRange(2), i),'omitnan');
            if(isnan(baseMean))
                baseMean = mean(eeg.data(j, (extraSearchRange + baseRange(1)):(baseRange(2) + extraSearchRange), i), 'omitnan');
                if(isnan(baseMean))
                    warning("All NaN values in mean range ("+eeg.setname+")");
                end
            end
            resultEeg.data(j,:,i) = eeg.data(j,:,i)/baseMean;
        end
    end
end