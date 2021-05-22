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
    %     plot(ALLEEG(set).times, ALLEEG(set).data(4, :, epoch));
        hold off;
    %     legend(["Height", "Width"]);
    %     axis([ALLEEG(set).times(1) ALLEEG(set).times(end) -0.02 0.02])

        w = waitforbuttonpress;
    end
end

