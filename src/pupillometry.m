%% const variables
MEAN_RANGE = 5;
w2h_UPPER_THRESHOLD = 1.3;
w2h_LOWER_THRESHOLD = 0.7;
MIN_INTERVAL_DISTANCE = 13;
INTERPOLATION_OFFSET = 3;
START_RANGE_REWARDS = -1;
END_RANGE_REWARDS = 2.5;
START_RANGE_CLUES = -1;
END_RANGE_CLUES = 5;
summary = [];
% conditions
clues = {'CS_Minus' 'to_win_CS_Plus_Cash' 'to_lose_CS_Plus_Cash' 'to_lose_CS_Plus_Porn' 'to_win_CS_Plus_Porn'};
rewards = {'NoUCsm' 'plan_No_UCSp_cash' 'plan_No_UCSp_porn' 'plan_UCSp_porn' 'plan_UCSp_cash' 'unpl_No_UCSp_porn' 'unpl_No_UCSp_cash' 'unpl_UCSp_cash' 'unpl_UCSp_porn' };

%% map defing group of a subject (control or study)
csv = readtable('../resources/subjects.csv');
subjects = string(csv.subject_id);
subjectsMap = containers.Map(subjects, csv.group_id);

%% loading data
sub_list = dir('../resources/ET');

%%delating "." and ".." directory
sub_list(1:2) = [];

%%loading eeglab
eeglab

%%loading data into EEGLAB   

if(isempty(sub_list))
    throw(MException("data folder is empty or unable to read data"));
end

% mkdir processedData;
% mkdir processedData kontrolna;
% mkdir processedData badawcza;
% mkdir(['./processedData/badawcza/jedzenie']);
% mkdir(['./processedData/badawcza/porno']);

for k = 1 : length(sub_list)
    
    currentSubject = sub_list(k).name;
    underscoresIndexes = strfind(currentSubject,'_');
    currentSubject = currentSubject(1 : underscoresIndexes(1) - 1);
    
%     if(~strcmp(currentSubject, '11210595'))
%        continue;
%     end
    try
        try
            eeg = loadEegSet(sub_list(k), MEAN_RANGE, w2h_UPPER_THRESHOLD,...
                w2h_LOWER_THRESHOLD, MIN_INTERVAL_DISTANCE, INTERPOLATION_OFFSET);
        catch e
            summary = [summary; "cannot load : " + sub_list(k).name];
            continue;
        end

        eeg = eeg_checkset( eeg );

        eeg1 = eeg;
        eeg1 = pop_eegfiltnew(eeg1, [],10,[],0,[],0);
        eeg1 = pop_epoch( eeg1, clues, [START_RANGE_CLUES  END_RANGE_CLUES], 'epochinfo', 'yes');
        eeg1.setname = eeg1.setname(1: end - 7);
        eeg1.setname = strcat(eeg1.setname, '_clues');
        eeg1.condition = 'clues';
        %eeg1 = addEpochInfo(eeg1);
        eeg1 = eeg_checkset(eeg1);
        eeg1 = pop_rmbase( eeg1, [-300    0]); %rmbase_qb zmienia na procentowy baseline (divisive as opposed to substractive)
        eeg1 = eeg_checkset( eeg1 );
        [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, eeg1);

        eeg = pop_eegfiltnew(eeg, [],10,[],0,[],0);
        eeg = pop_epoch( eeg, rewards, [START_RANGE_REWARDS  END_RANGE_REWARDS], 'epochinfo', 'yes');
        eeg.setname = eeg.setname(1: end - 7);
        eeg.setname = strcat(eeg.setname, '_rewards');
        eeg.condition = 'rewards';
        %eeg = addEpochInfo(eeg);
        eeg = eeg_checkset(eeg);
        eeg = pop_rmbase( eeg, [-300    0]); %rmbase_qb zmienia na procentowy baseline (divisive as opposed to substractive)
        eeg = eeg_checkset( eeg );
        [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, eeg);
        
        try
            if(subjectsMap(currentSubject) == 1)
%                mkdir(['./processedData/badawcza/porno/', currentSubject]); 
%                pop_saveset(eeg, eeg.setname, ['./processedData/badawcza/porno/', currentSubject])
%                pop_saveset(eeg1, eeg1.setname, ['./processedData/badawcza/porno/', currentSubject])
%                copyfile([sub_list(k).folder, '\', sub_list(k).name],['./processedData/badawcza/porno/', currentSubject] )
            elseif(subjectsMap(currentSubject) == 2)
%                mkdir(['./processedData/badawcza/jedzenie/', currentSubject]);
%                pop_saveset(eeg, eeg.setname, ['./processedData/badawcza/jedzenie/', currentSubject])
%                pop_saveset(eeg1, eeg1.setname, ['./processedData/badawcza/jedzenie/', currentSubject])
%                copyfile([sub_list(k).folder, '\', sub_list(k).name],['./processedData/badawcza/jedzenie/', currentSubject] )
            elseif(subjectsMap(currentSubject) == 3)
%                mkdir(['./processedData/kontrolna/', currentSubject]);
%                pop_saveset(eeg, eeg.setname, ['./processedData/kontrolna/', currentSubject])
%                pop_saveset(eeg1, eeg1.setname, ['./processedData/kontrolna/', currentSubject])
%                copyfile([sub_list(k).folder, '\', sub_list(k).name],['./processedData/kontrolna/', currentSubject] )
            end
        catch e
            summary = [summary; "unable to define group of subject : " + currentSubject];
        end
    catch e
        summary = [summary; "problem occured reading : " + sub_list(k).name];
    end

end

eeglab redraw
%%
%WARNING: function works with the assumption that data(3,:) corresond to
%intervals_A and 4 correspond to intervals_B
function eeg = addEpochInfo(eeg)
    %%eeg.epoch.intervals_A
    for i = 1 : length(eeg.epoch)
        j = 1;
        eeg.epoch(i).intervals_A = [];
        while(j <= eeg.pnts)
            if(eeg.data(3, j, i) ~= 0)
                startJ = j;
                while(eeg.data(3, j, i) ~= 0)
                    if(j >= eeg.pnts)
                        break;
                    end
                    j = j + 1;
                end
                eeg.epoch(i).intervals_A = [eeg.epoch(i).intervals_A; startJ, j];
            end
            j = j + 1;
        end
    end
    
    %%eeg.epoch.intervals_B
    for i = 1 : length(eeg.epoch)
        j = 1;
        eeg.epoch(i).intervals_B = [];
        while(j <= eeg.pnts)
            if(eeg.data(4, j, i) == 1)
                startJ = j;
                while(eeg.data(4, j, i) == 1)
                    if(j >= eeg.pnts)
                        break;
                    end
                    j = j + 1;
                end
                eeg.epoch(i).intervals_B = [eeg.epoch(i).intervals_B; startJ, j];
            end
            j = j + 1;
        end
    end
    
    %%percentage of interpolated data    
    for i = 1 : length(eeg.epoch)
        eeg.epoch(i).noisePercentage_A = 100 * sum(eeg.data(3,:,i))/size(eeg.data, 2);
        eeg.epoch(i).noisePercentage_B = 100 * sum(eeg.data(4,:,i))/size(eeg.data, 2);
    end
    
    %%matlab is just stupid
    eeg.data(3,:,:) = [];
    eeg.data(3,:,:) = [];
end
%%
function tmpIntervalsData = writeTempIntervalData(intervals, pnts)
    tmpIntervalsData = zeros(1, pnts);
    if (isempty(intervals))
        return;
    end
    if(intervals(1,1) < 1)
        intervals(1,1) = 1;
    end
    
    [rows, ~] = size(intervals);
    for i = 1 : rows-1
        tmpIntervalsData(intervals(i, 1) : intervals(i, 2)) = 1;
    end
end
%%
function interpolatedData = interpolateIntervals(data, intervals, MEAN_RANGE)
    interpolatedData = [];
    counter = 1;
    [intervalsRows,~] = size(intervals);
    stop = -1;
    if(~isempty(intervals))
        stop = intervals(counter,1);       
        if (stop <= MEAN_RANGE + 1)
            stop = MEAN_RANGE + 1 + 1;
        end
        if(intervals(end, 2) >= length(data) - MEAN_RANGE - 1)
            intervals(end,2) = length(data) - MEAN_RANGE - 1;
        end
    end

    i = 1;
    while(i <= length(data))
        if(i == stop)
            interpolatedData = interpolatedData(1:end);
            interpolatedData = [interpolatedData,...
                linspace(mean(data(stop - MEAN_RANGE - 1 : stop - 1)),...
                         mean(data(intervals(counter, 2) + 1 : intervals(counter, 2) + 1 + MEAN_RANGE)), ...
                         (intervals(counter, 2) - stop + 1))]; %#ok<AGROW>
            
           i = intervals(counter,2) + 1; 
           counter = counter + 1;
           if(counter < intervalsRows)
                stop = intervals(counter,1);
           end
        end
        interpolatedData(i) = data(i);  %#ok<AGROW>
        i = i + 1;
    end
end
%%
function intervals = getIntervals(M, w2h_UPPER_THRESHOLD, w2h_LOWER_THRESHOLD, MIN_INTERVAL_DISTANCE, INTERPOLATION_OFFSET)
    intervals = [];
    tmp = NaN;
    for i = 1 : length(M)
        if(M(i) > w2h_UPPER_THRESHOLD || M(i) < w2h_LOWER_THRESHOLD)
            if(isnan(tmp))
                tmp = i - INTERPOLATION_OFFSET;
            end
        else
            if(~isnan(tmp))
                intervals = [intervals; tmp, i + INTERPOLATION_OFFSET]; %#ok<AGROW>
                tmp = NaN;
            end
        end
    end
    
    if(isnan(tmp))
       intervals = [intervals; tmp, length(M)]; %#ok<AGROW>
    end    
    %% suming close intervals
    [rows, ~] = size(intervals);
    garbbage = [];
    for i = 1 : rows-1
        if(intervals(i, 2) + MIN_INTERVAL_DISTANCE > intervals(i+1, 1))
            intervals(i+1, 1) = intervals(i, 1);
            garbbage = [garbbage; i];
        end
    end
    if(isempty(intervals) || rows < 2)
        return
    end
    intervals(rows, 1) = intervals(rows-1,1);
    garbbage = [garbbage; rows-1];
    
    intervals(garbbage,:) = [];
    
end

%%
function data = interpolateData(rawData, w2h, w2h_UPPER_THRESHOLD, w2h_LOWER_THRESHOLD)
    data = NaN(1, length(rawData));
    for i = 1 : length(data)
        if(w2h(i) < w2h_UPPER_THRESHOLD && w2h(i) > w2h_LOWER_THRESHOLD)
            data(i) = rawData(i);
        end
    end
end
%%
function eeg = loadEegSet(file, MEAN_RANGE, w2h_UPPER_THRESHOLD, w2h_LOWER_THRESHOLD, MIN_INTERVAL_DISTANCE, INTERPOLATION_OFFSET)
    DEBUG_PLOT = false;

    eeg = eeg_emptyset();
    
    %% loading some study infromation
    eeg.setname = file.name(1 : end-4);
    eeg.trials = 1;
    eeg.srate = 60;
    underscoresIndexes = strfind(eeg.setname,'_');
    eeg.subject = file.name(1 : underscoresIndexes(1) - 1);
    
    underscoresData = eeg.setname((underscoresIndexes(1) + 1) : end);
    
    if(length(underscoresData) == 1)
        eeg.group = 1;
        eeg.session = str2num(underscoresData(1));
    elseif (length(underscoresData) == 3)
         eeg.group = 2;
         eeg.session = str2num(underscoresData(3));
    else
        eeg.group = 0;
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
    
    eeg.data(1,:) = interpolateData([s(:).A_PupilDiam], w2h_A, w2h_UPPER_THRESHOLD, w2h_LOWER_THRESHOLD);
    eeg.data(2,:) = interpolateData([s(:).B_PupilDiam], w2h_B, w2h_UPPER_THRESHOLD, w2h_LOWER_THRESHOLD);
    
    %eeg.intervals_A = getIntervals(w2h_A, w2h_UPPER_THRESHOLD, w2h_LOWER_THRESHOLD, MIN_INTERVAL_DISTANCE, INTERPOLATION_OFFSET);
    %eeg.intervals_B = getIntervals(w2h_B, w2h_UPPER_THRESHOLD, w2h_LOWER_THRESHOLD, MIN_INTERVAL_DISTANCE, INTERPOLATION_OFFSET);
     
    %eeg.data(1,:) = interpolateIntervals([s(:).A_PupilDiam], eeg.intervals_A, MEAN_RANGE);
    %eeg.data(2,:) = interpolateIntervals([s(:).B_PupilDiam], eeg.intervals_B, MEAN_RANGE);
    %chan 3 and 4 temp (will be removed after cuting into epoch)
    %eeg.data(3,:) = writeTempIntervalData(eeg.intervals_A, eeg.pnts);
    %eeg.data(4,:) = writeTempIntervalData(eeg.intervals_B, eeg.pnts);
    
    if(DEBUG_PLOT)
        figure(11);
        plot([s(:).TotalTime], [s(:).A_PupilDiam], [s(:).TotalTime], eeg.data(1,:));
    end
    
    clear s;
    

end
