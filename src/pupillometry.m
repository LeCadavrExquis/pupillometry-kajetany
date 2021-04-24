%% const variables
summary = [];
 
% conditions
clues = {'CS_Minus' 'to_win_CS_Plus_Cash' 'to_lose_CS_Plus_Cash' 'to_lose_CS_Plus_Porn' 'to_win_CS_Plus_Porn'};
START_RANGE_CLUES = -1;
END_RANGE_CLUES = 2;

rewards = {'NoUCsm' 'plan_No_UCSp_cash' 'plan_No_UCSp_porn' 'plan_UCSp_porn' 'plan_UCSp_cash' 'unpl_No_UCSp_porn' 'unpl_No_UCSp_cash' 'unpl_UCSp_cash' 'unpl_UCSp_porn' };
START_RANGE_REWARDS = -1;
END_RANGE_REWARDS = 2;

%% map defing group of a subject (control or study)
csv = readtable('../resources/subjects.csv', 'Format', '%s%u');
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
    
%     if(~strcmp(currentSubject, '91218349'))
%        continue;
%     end
    try
        try
            [eeg, w2h_A, w2h_B] = loadEegSet(sub_list(k));
            
            eeg = eeg_checkset(eeg);
        catch e
            summary = [summary; "cannot load : " + sub_list(k).name];
            continue;
        end
        
        try
            eeg.group = subjectsMap(currentSubject);
        catch e
            summary = [summary; "unable to define group of subject : " + currentSubject];
            continue;
        end

        eeg.data(1,:) = filter_w2h(eeg.data(1,:), w2h_A);
        eeg.data(2,:) = filter_w2h(eeg.data(2,:), w2h_B);
        eeg = pop_eegfiltnew(eeg, [],10,[],0,[],0);
        
        eeg1 = eeg;
        
        eeg1 = pop_epoch( eeg1, clues, [START_RANGE_CLUES  END_RANGE_CLUES], 'epochinfo', 'yes');
        eeg1.setname = eeg1.setname(1: end - 7);
        eeg1.setname = strcat(eeg1.setname, '_cues');
        eeg1.condition = 'cues';
        eeg1 = pop_rmbase( eeg1, [-300    0]); %rmbase_qb zmienia na procentowy baseline (divisive as opposed to substractive)
        eeg1 = eeg_checkset( eeg1 );
        [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, eeg1);

        eeg = pop_epoch( eeg, rewards, [START_RANGE_REWARDS  END_RANGE_REWARDS], 'epochinfo', 'yes');
        eeg.setname = eeg.setname(1: end - 7);
        eeg.setname = strcat(eeg.setname, '_rewards');
        eeg.condition = 'rewards';
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