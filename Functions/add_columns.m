%% Add counter and group columns to run table

function run_table = add_columns(run_table)

    % Skip if run table is empty
    if isempty(run_table)
        return;
    end

    % Sort table 
    run_table = sortrows(run_table, {'ID', 'date'});
    
    % Add run counter column to table
    run_table.run_counter = nan(height(run_table),1);
    groups = findgroups(run_table.ID);
    for g = 1:max(groups)
        indices = find(groups == g);
        run_table.run_counter(indices) = 1:length(indices);
    end
    
    % Add run counter (day) column to table
    run_table.run_counter_day = nan(height(run_table),1);
    groups = findgroups(run_table.ID, dateshift(run_table.date, 'start', 'day'));
    for g = 1:max(groups)
        indices = find(groups == g);
        run_table.run_counter_day(indices) = 1:length(indices);
    end

    % Add group column (anxiety, anhedonia)
    % if ismember('group', run_table.Properties.VariableNames)
    %     run_table.group = [];
    % end
    % run_table = join(run_table, group_table(:,{'ID', 'group'}), 'Keys', 'ID');
    % run_table.group = nan(height(run_table),1); % delete when finished!
   
    % Add days from start column
    % run_table.days_from_start = nan(height(run_table),1);
    % for i = 1:height(run_table)
    %     start_date = min(run_table.date(strcmp(run_table.ID, run_table.ID(i))));
    %     run_table.days_from_start(i) = days(run_table.date(i) - start_date);
    % end

    % Add days from start column
    G = findgroups(run_table.ID);
    start_dates = splitapply(@min, run_table.date, G);
    run_table.days_from_start = days(run_table.date - start_dates(G));
    
end
