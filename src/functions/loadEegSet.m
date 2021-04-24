function [eeg,w2h_A, w2h_B] = loadEegSet(file)

    eeg = eeg_emptyset();
    
    %% loading some study infromation
    eeg.setname = file.name(1 : end-4);
    eeg.trials = 1;
    eeg.srate = 60;
    underscoresIndexes = strfind(eeg.setname,'_');
    eeg.subject = file.name(1 : underscoresIndexes(1) - 1);
    
    underscoresData = eeg.setname((underscoresIndexes(1) + 1) : end);
    
    if(length(underscoresData) == 1)
        eeg.run = 1;
        eeg.session = str2num(underscoresData(1));
    elseif (length(underscoresData) == 3)
         eeg.run = 2;
         eeg.session = str2num(underscoresData(3));
    else
        eeg.run = 0;
        eeg.session = 0;
    end
    
    %% loading raw data
    filename = [file.folder '/' file.name];
    formatSpec = '%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%s%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fopen(filename,'r'), formatSpec,...
        'Delimiter', '\t', 'TextType', 'string', 'EmptyValue', NaN,...
        'HeaderLines' ,44-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    fclose(fileID);
    t = table(dataArray{1:end-1}, 'VariableNames', {'ev_index','TotalTime','DeltaTime','A_X_Gaze','A_Y_Gaze','VarName6','VarName7','VarName8','A_PupilWidth',...
        'A_PupilHeight','VarName11','VarName12','VarName13','VarName14','B_X_Gaze','B_Y_Gaze','VarName17','VarName18','VarName19','B_PupilWidth','B_PupilHeight',...
        'VarName22','VarName23','VarName24','VarName25','VarName26','Count','Markers'});
    clearvars formatSpec fileID dataArray ;

    t = removevars(t, {'VarName6','VarName7','VarName8','VarName11','VarName12','VarName13','VarName14','VarName17','VarName18','VarName19','VarName22',...
        'VarName23','VarName24','VarName25','VarName26','A_X_Gaze','A_Y_Gaze','B_X_Gaze','B_Y_Gaze'});

    s = table2struct(t);
    clear t    
    
    %% loading events
    
    events = [];
    for i = 1:length(s)
        if s(i).ev_index == 12
            events = [events, s(i)]; %#ok<AGROW>
        end
    end
    %deleting marker record
    s = s(~isnan([s.A_PupilWidth]));   

    %% calculating PupilDiam and w2h
    w2h_B = zeros(1,length(s));
    w2h_A = zeros(1,length(s));
    for ii = 1:length(s)

        s(ii).B_PupilDiam = mean([s(ii).B_PupilHeight s(ii).B_PupilWidth]);
        s(ii).A_PupilDiam = mean([s(ii).A_PupilHeight s(ii).A_PupilWidth]);
        w2h_B(ii) = (s(ii).B_PupilWidth / s(ii).B_PupilHeight);
        w2h_A(ii) = (s(ii).A_PupilWidth / s(ii).A_PupilHeight);

    end
    
    %% adding event info
    gg=1;
    eeg.event(1:end) = [];
    for ii = 1:length(events)
        if contains(events(ii).DeltaTime, 'CS_') || contains(events(ii).DeltaTime, 'UC')
            eeg.event(gg).latency = (events(ii).TotalTime*1000)/16.66;
            eeg.event(gg).type = events(ii).DeltaTime;
            eeg.event(gg).code = events(ii).DeltaTime;
            eeg.event(gg).bvmknum = ii;
            eeg.event(gg).duration = 1;
            eeg.event(gg).channel = 0;
            eeg.event(gg).bvtime = 1;
            gg=gg+1;
        end
    end

    %% setting data   
    eeg.pnts = length([s(:).TotalTime]);
    eeg.times(1,:) = [s(:).TotalTime];
    
    eeg.data(1,:) = [s(:).A_PupilDiam];
    eeg.data(2,:) = [s(:).B_PupilDiam];
      
    
    clear s;    

end

