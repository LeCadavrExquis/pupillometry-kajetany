w = 1;
figure();

tmpALLEEG = ALLEEG_bezW2H;
while(w)
    set = randi([1,length(tmpALLEEG)], 1, 1);
    epoch = randi([1,length(tmpALLEEG(set).data(1,1,:))], 1, 1);  
    
    clf;
    titleName = alleeg2(set).setname + " | " + string(epoch) + "E";
    title(titleName);       
    
    hold on;
    plot(tmpALLEEG(set).times, tmpALLEEG(set).data(1, :, epoch));
%     plot(ALLEEG(set).times, ALLEEG(set).data(4, :, epoch));
    hold off;
%     legend(["Height", "Width"]);
%     axis([ALLEEG(set).times(1) ALLEEG(set).times(end) -0.02 0.02])
    
    w = waitforbuttonpress;
end