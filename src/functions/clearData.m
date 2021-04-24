function [alleeg,raport] = clearData(alleeg,doSave)
    i = 1;
    
    emptyEeg = 0;
    emptyEpochs = 0;
    missingData = 0;
    rewardsEpochs = 0;
    cuesEpochs = 0;
    
    missingDataAcceptance = 30; % in procents
    
    
    while(i <= length(alleeg))
       
       j = 1;            
       while(j <= length(alleeg(i).data(1,1,:)))
           %empty epoch
           if(sum(isnan(alleeg(i).data(:,:,j))) == length(alleeg(i).data(:,1,1))*length(alleeg(i).times))
               emptyEpochs = emptyEpochs + 1;
               alleeg(i).data(:, :, j) = [];
               alleeg(i).epoch = [];
               continue;
           end
           %better eye
           if(length(alleeg(i).data(:,1,1)) > 1 && sum(isnan(alleeg(i).data(1,:,j))) > sum(isnan(alleeg(i).data(2,:,j))))
              % (assuming that position 1 is better => swap eyes)
               alleeg(i).data(1,:,j) = alleeg(i).data(2,:,j);
           end
           
           %missing data
           acc = 0; 
           for k = 1 : length(alleeg(i).data(1,:,j))
               if(isnan(alleeg(i).data(1,k,j)))
                   acc = acc + 1;
               end
           end
           if((acc/length(alleeg(i).data(1,:,j))) > (missingDataAcceptance/100))
               alleeg(i).data(:,:,j) = [];
               alleeg(i).epoch(j) = [];
               missingData = missingData + 1;
               disp(alleeg(i).setname + " | E:" + j);
               continue;
           end
           j = j + 1;
       end
       
    %empty set
    if(isempty(alleeg(i).data))
       emptyEeg = emptyEeg + 1;
       disp("empty set: " + alleeg(i).setname);
       alleeg(i) = [];
       continue
    end

    %delete useless eyes
    if(length(alleeg(i).data(:,1,1)) == 2)
        alleeg(i).data(2,:,:) = [];
    end
          
    if(alleeg(i).condition == "rewards")
       rewardsEpochs = rewardsEpochs + length(alleeg(i).data(1,1,:));
    else
       cuesEpochs = cuesEpochs + length(alleeg(i).data(1,1,:));
    end
       
       i = i + 1;
    end
    
    raport.emptyEeg = emptyEeg;
    raport.emptyEpochs = emptyEpochs;
    raport.missingData = missingData;
    raport.rewardsEpochs = rewardsEpochs;
    raport.cuesEpochs = cuesEpochs;
    
    %% TODO
    if(doSave)
        %handle saving to file
    end

end

