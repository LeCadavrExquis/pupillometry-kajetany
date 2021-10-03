%% FUNCTION peek
% peek random set and epoch and displays it on the plot; 
% press any key to reroll set and epoch;
function peek(AllEeg)
    w = 1;
    figure();

    while(w)
        set = randi([1,length(AllEeg)], 1, 1);
        epoch = randi([1,length(AllEeg(set).data(1,1,:))], 1, 1);  

        clf;
        titleName = AllEeg(set).setname + " | " + string(epoch) + "E | " ...
            + "NaN: "+ 100*sum(isnan(AllEeg(set).data(1,:,epoch)))/length(AllEeg(set).data(1,:,epoch)) + " %";
        title(titleName);       

        hold on;
        plot(AllEeg(set).times, AllEeg(set).data(1, :, epoch));
        hold off;

        w = waitforbuttonpress;
    end
end

