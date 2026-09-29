% Add Influenca run to the trial table
% Input: Current trial table and data (VAS+Influenca)
% Output: Appended trial table and Influenca run data

function [trial_table, task_data] = add_trials_to_table(trial_table, data)

    % Set columns
    % if strcmp(data.Device{1}, 'mobile')
    %     rt_column = 'syringeChoice_time';
    %     response_column = 'syringeChoice_clicked_name';
    % elseif strcmp(data.Device{1}, 'desktop')
    %     rt_column = 'keyChoice_rt';
    %     response_column = 'keyChoice_keys';
    % end

    % Detect available columns instead of  Device - changed by SM because
    % syringe is also possible for PC now
    if ismember('syringeChoice_time', data.Properties.VariableNames) && ~all(isnan(data.syringeChoice_time))
        rt_column = 'syringeChoice_time';
    elseif ismember('keyChoice_rt', data.Properties.VariableNames)
        rt_column = 'keyChoice_rt';
    else
        error('No RT column found');
    end
    
    if ismember('syringeChoice_clicked_name', data.Properties.VariableNames) && ~strcmp(data.syringeChoice_clicked_name{1}, '[]')
        response_column = 'syringeChoice_clicked_name';
    elseif ismember('keyChoice_keys', data.Properties.VariableNames) && iscell(data.keyChoice_keys)
        response_column = 'keyChoice_keys';
    else
        error('No response column found');
    end

    columns = {'participant', 'nTrials', 'date_dt', ...
        'device', 'Level', 'Score', rt_column, response_column, ...
        'LeftProbability', 'RightProbability', 'LeftCured', 'RightCured', ...
        'correctChoice', 'correctlyDone'};

    % Set rows
    rows = 1:max(data.nTrials);

    % Get task data
    task_data = data(rows, columns);

    %%%%%% KEEP BON008X PREFIX %%%%%% added by Sarah M
    if iscell(task_data.participant) || isnumeric(task_data.participant)
        task_data.participant = string(task_data.participant);  % <- THIS PRESERVES THE PREFIX
    end

    % Rename columns
    task_data.Properties.VariableNames{'participant'} = 'ID';
    task_data.Properties.VariableNames{'LeftProbability'} = 'p_reward_a';
    task_data.Properties.VariableNames{'RightProbability'} = 'p_reward_b';
    task_data.Properties.VariableNames{'LeftCured'} = 'reward_a';
    task_data.Properties.VariableNames{'RightCured'} = 'reward_b';
    task_data.Properties.VariableNames{'nTrials'} = 'trial';
    task_data.Properties.VariableNames{'Level'} = 'level';
    task_data.Properties.VariableNames{'Score'} = 'score';
    task_data.Properties.VariableNames{rt_column} = 'rt';

    % Add choice_a column (1 if a (left) was chosen; 0 if b (right) was chosen)
    task_data.choice_a = ismember(task_data.(response_column), {'left', '["leftSyringe","leftSyringe"]'});
    task_data.(response_column) = [];

    % Add draw_a column (1 if a (left) was drawn; 0 if b (right) was drawn)
    task_data.draw_a = ismember(task_data.correctChoice, 'left');
    task_data.correctChoice = [];

    % Add win column (win = 1; loss = -1)
    task_data.win = 2 * (task_data.correctlyDone - 0.5);
    task_data.correctlyDone = [];
    
    % Add reward column
    for i = 1:150
        if task_data.choice_a(i) == 1
             selected_reward = task_data{i, 'reward_a'};
        elseif task_data.choice_a(i) == 0
             selected_reward = task_data{i, 'reward_b'};
        end
        task_data.reward(i) = selected_reward * task_data.win(i); 
    end
    
    % Rename column
    task_data.Properties.VariableNames{'date_dt'} = 'date';

    %%%%%%% ADDED BY SARAH M BECAUSE OF CONVERTING TROUBLES %%%%%%%%
    
    % Force rt to be numeric
    if iscell(task_data.rt)
        task_data.rt = str2double(task_data.rt);
    end

    % If trial_table is empty, initialize properly
    if isempty(trial_table)
        trial_table = task_data;
        return
    end

    % Force rt type in existing table
    if iscell(trial_table.rt)
        trial_table.rt = str2double(trial_table.rt);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Add task data to trial table
    trial_table = [trial_table; task_data];

end
