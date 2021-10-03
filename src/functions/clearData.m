%% FUNCTION clearData
% removes blank and damaged trials
% @param missingDataAcceptance: Procents - trials that have missing data
%           percentage higher then this param will be removed
% @output [alleeg, excludedEpochs]
%   excludedEpochs: N x numberOfPoints array<Double> - array containing
%          removed epochs
%          WARNING: code will broke if the rewards and cues number of
%          points in epoch differs (solution call this method without this output param)
function [alleeg, excludedEpochs] = clearData(alleeg, missingDataAcceptance)
    emptyEeg = 0;
    emptyEpochs = 0;
    missingData = 0;
    rewardsEpochs = 0;
    cuesEpochs = 0;
    
    excludedEpochs = [];
    
    i = 1; 
    while(i <= length(alleeg))
       
       j = 1; 
       while(j <= length(alleeg(i).data(1,1,:)))
           % better eye
           if(length(isnan(alleeg(i).data(:,1,1))) > 1 && sum(isnan(alleeg(i).data(1,:,j))) > sum(isnan(alleeg(i).data(2,:,j))))
              % assuming that position 1 is better
               tmp = alleeg(i).data(1,:,j);
               
               alleeg(i).data(1,:,j) = alleeg(i).data(2,:,j);
               
               alleeg(i).data(2,:,j) = tmp;
           end
           
           % missing data
           acc = 0; 
           for k = 1 : length(alleeg(i).data(1,:,j))
               if(isnan(alleeg(i).data(1,k,j)))
                   acc = acc + 1;
               end
           end
           miss = 100*acc/length([alleeg(i).data(1,:,j)]);
           if( miss > missingDataAcceptance)
               excludedEpochs = [excludedEpochs; alleeg(i).data(1,:,j)];
               
               alleeg(i).data(:,:,j) = [];
               alleeg(i).epoch(j) = [];
               missingData = missingData + 1;
               continue;
           end
           j = j + 1;
       end
       
    % empty set
    if(isempty(alleeg(i).data))
       emptyEeg = emptyEeg + 1;
       disp("empty set: " + alleeg(i).setname);
       alleeg(i) = [];
       continue;
    end
    
    % good stuff
    if(alleeg(i).condition == "rewards")
       rewardsEpochs = rewardsEpochs + length(alleeg(i).data(1,1,:));
    else
       cuesEpochs = cuesEpochs + length(alleeg(i).data(1,1,:));
    end
       i = i + 1;
    end
    
    disp("empty eeg           = " + emptyEeg);
    disp("empty epochs        = " + emptyEpochs);
    disp("missing data epochs = " + missingData);
    disp("rewards epochs      = " + rewardsEpochs);
    disp("cues epochs         = " + cuesEpochs);   
end

