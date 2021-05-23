%% const variables
%events
clues = {'CS_Minus' 'to_win_CS_Plus_Cash' 'to_lose_CS_Plus_Cash' ...
    'to_lose_CS_Plus_Porn' 'to_win_CS_Plus_Porn'};
rewards = {'NoUCsm' 'plan_No_UCSp_cash' 'plan_No_UCSp_porn' ...
    'plan_UCSp_porn' 'plan_UCSp_cash' 'unpl_No_UCSp_porn' ...
    'unpl_No_UCSp_cash' 'unpl_UCSp_cash' 'unpl_UCSp_porn' };
% events' groups
eventsRewards = containers.Map(...
    ["UCSp porn", "UCSp cash", "No UCSp", "No UCSp cash", "No UCSp_porn"],...
    [{["plan_UCSp_porn", "unpl_UCSp_porn"]},...
    {["plan_UCSp_cash", "unpl_UCSp_cash"]},...
    {["NoUCsm", ""]},...
    {["plan_No_UCSp_cash","unpl_No_UCSp_cash"]},...
    {["plan_No_UCSp_porn", "unpl_No_UCSp_porn"]}]);
eventsCues = containers.Map(...
    ["CS Minus", "win CS Cash", "lose CS Cash", "lose CS Porn", "win CS Porn"],...
    [{"CS_Minus"},...
    {"to_win_CS_Plus_Cash"},...
    {"to_lose_CS_Plus_Cash"},...
    {"to_lose_CS_Plus_Porn"},...
    {"to_win_CS_Plus_Porn"}]);
% DEBUG
summary = []; 
%% parameters

START_RANGE_CLUES = -1;
END_RANGE_CLUES = 2;
START_RANGE_REWARDS = -1;
END_RANGE_REWARDS = 2;

%% map group of a subject (control/study1/study2)
csv = readtable('../resources/subjects.csv', 'Format', '%s%u');
subjects = string(csv.subject_id);
subjectsMap = containers.Map(subjects, csv.group_id);

%% loading data
sub_list = dir('../resources/ET');
sub_list(1:2) = [];%delating "." and ".." directory
if(isempty(sub_list))
    throw(MException("data folder is empty or unable to read data"));
end

%% loading data into EEGLAB   
eeglab

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
%         raw1 = eeg.data(1,:);
%         raw2 = eeg.data(2,:);
%% freq filter
        eeg = pop_eegfiltnew(eeg, [],10,[],0,[],0);
%         eeg.data(3,:) = raw1;
%         eeg.data(4,:) = raw2;
%         eeg.data(5,:) = w2h_A;
%         eeg.data(6,:) = w2h_B;
%% width to height filter 
        eeg.data(1,:) = filterW2H(eeg.data(1,:), w2h_A);
        eeg.data(2,:) = filterW2H(eeg.data(2,:), w2h_B);
       
%% cuting into epochs & baseline removal
        eeg1 = eeg; % duplicate to cut into rewards/cues sets
% cues:        
        eeg1 = pop_epoch( eeg1, clues, [START_RANGE_CLUES  END_RANGE_CLUES], 'epochinfo', 'yes');
        eeg1.setname = eeg1.setname(1: end - 7);
        eeg1.setname = strcat(eeg1.setname, '_cues');
        eeg1.condition = 'cues';

%         raw1 = eeg1.data(3,:,:);
%         raw2 = eeg1.data(4,:,:);
%         w2h_A = eeg1.data(5,:,:);
%         w2h_B = eeg1.data(6,:,:);

%         eeg1 = pop_rmbase( eeg1, [-300    0]); %rmbase_qb zmienia na procentowy baseline (divisive as opposed to substractive)
        eeg1 = removeBaseLine(eeg1, [42, 60], 22);
      
%         eeg1.data(3,:,:) = raw1;
%         eeg1.data(4,:,:) = raw2;
%         eeg1.data(5,:,:) = w2h_A;
%         eeg1.data(6,:,:) = w2h_B;
%      

% rewards
        eeg = pop_epoch( eeg, rewards, [START_RANGE_REWARDS  END_RANGE_REWARDS], 'epochinfo', 'yes');
        eeg.setname = eeg.setname(1: end - 7);
        eeg.setname = strcat(eeg.setname, '_rewards');
        eeg.condition = 'rewards';

%         raw1 = eeg.data(3,:,:);
%         raw2 = eeg.data(4,:,:);
%         w2h_A = eeg.data(5,:,:);
%         w2h_B = eeg.data(6,:,:);

%        eeg = pop_rmbase( eeg, [-300    0]); %rmbase_qb zmienia na procentowy baseline (divisive as opposed to substractive)
        eeg = removeBaseLine(eeg, [42, 60], 22);
      
%         eeg.data(3,:,:) = raw1;
%         eeg.data(4,:,:) = raw2;
%         eeg.data(5,:,:) = w2h_A;
%         eeg.data(6,:,:) = w2h_B;
%% saving to EEGLAB structure ALLEEG
        try 
            eeg1 = eeg_checkset( eeg1 );
            [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, eeg1);
        catch e
            summary = [summary; "check problem loading: " + sub_list(k).name + " (cues)"];
        end
        try 
            eeg = eeg_checkset( eeg );
            [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, eeg);
        catch e
            summary = [summary; "check problem loading: " + sub_list(k).name + " (rewards)"];
        end
    catch e
        summary = [summary; "problem occured reading : " + sub_list(k).name];
    end
end

eeglab redraw