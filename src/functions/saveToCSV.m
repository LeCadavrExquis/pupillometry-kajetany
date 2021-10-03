%% FUNCTION saveToCSV
% saves alleeg object to csv files (one for pupil data and second for corresponding subject meta data)
function saveToCSV(AllEeg)
eventsRewards = containers.Map(...
    ["UCSp porn", "UCSp cash", "No UCSp", "No UCSp cash", "No UCSp_porn"],...
    [{["plan_UCSp_porn", "unpl_UCSp_porn"]},...
    {["plan_UCSp_cash", "unpl_UCSp_cash"]},...
    {["NoUCsm", ""]},...
    {["plan_No_UCSp_cash","unpl_No_UCSp_cash"]},...
    {["plan_No_UCSp_porn", "unpl_No_UCSp_porn"]}]);
eventsCues = containers.Map(...
    ["CS Minus", "win CS Cash", "lose CS Cash", "lose CS Porn", "win CS Porn"],...
    [
    {"CS_Minus"},...
    {"to_win_CS_Plus_Cash"},...
    {"to_lose_CS_Plus_Cash"},...
    {"to_lose_CS_Plus_Porn"},...
    {"to_win_CS_Plus_Porn"}]);
groupDict = containers.Map([1,2,3],["porn", "food", "control"]);
subjects_csv = [];
data_csv = [];

    for eeg = AllEeg
        if(eeg.condition == "rewards")
            for key = keys(eventsRewards)
                tmpData = meanEvent(eeg, eventsRewards(key{1}));
                if(isempty(tmpData) || length(tmpData)~=180)
                    warning("Empty/(Broken) mean event: " + key{1} +" in " + eeg.setname);
                    continue;
                end
                subjects_csv = [subjects_csv; ...
                string(eeg.subject), groupDict(eeg.group), string(eeg.condition),...
                string(eeg.run), string(eeg.session), key{1}];
                data_csv = [data_csv; tmpData];
            end
        elseif(eeg.condition == "cues")
            for key = keys(eventsCues)
                tmpData = meanEvent(eeg, eventsCues(key{1}));
                if(isempty(tmpData) || length(tmpData)~=180)
                    warning("Empty/(Broken) mean event: " + key{1} +" in " + eeg.setname);
                    continue;
                end
                subjects_csv = [subjects_csv; ...
                string(eeg.subject), groupDict(eeg.group), string(eeg.condition),...
                string(eeg.session), string(eeg.run), key{1}];
                data_csv = [data_csv; tmpData];
            end
        else
            disp("ups ...");
        end
    end



table1 = array2table(subjects_csv,...
'VariableNames',{'subject','group','condition', 'session', 'run', 'event'});
table2 = array2table(data_csv, ...
'VariableNames',"P" + string(1:180));

writetable(table1,'dataInfo_raw.csv');
writetable(table2,'pupilData_raw.csv');
end
function data = meanEvent(eeg, events)
    data = [];
    for ep = 1 : size(eeg.data, 3)
        if(sum(eeg.event(ep).code == events))
            data = [data; eeg.data(1,:,ep)];
        end
    end
    data = mean(data, 'omitnan');
end
