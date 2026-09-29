% Script to create the participant table and Influenca trial and run tables for demo version

% Add functions
addpath(fullfile('functions'));

% Set the input folder
main_folder = fullfile(pwd, '..', '..');
input_folder = fullfile(main_folder, 'Data', 'Demo', 'Data_Cleaned');
if ~exist(input_folder, 'dir')
    disp('Data_Cleaned folder not found.');
    return;
end

% Set the output folder
save_folder = fullfile(main_folder, 'Analyses', 'Demo', 'Tables');
if ~exist(save_folder, 'dir')
    mkdir(save_folder);  
end

% Get struct with all cleaned files
excel_files = dir(fullfile(input_folder, '*.xlsx')); % csv file before 

% initialize counter 
n_files_logged = 0;

% Suppress the warning about modified column headers
warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');

% Initilaze tables
Influenca_trial_data = {};
Influenca_run_data = {};

% Loop through cleaned files to append trial and run tables
for i = 1:length(excel_files)

    % Read file
    file_path = fullfile(input_folder, excel_files(i).name);
    data = readtable(file_path);
    
    % Get ID
    participantID = regexp(excel_files(i).name, 'Influenca_demo_(.*?)_S0', 'tokens', 'once');
    participantID = participantID{1};
    
    if isempty(participantID)
        continue;
    end
    
    % Read file
    file_path = fullfile(input_folder, excel_files(i).name);
    data = readtable(file_path);

    % Process VAS data if existent and complete
    
    % original by Simon M
    % if any(strcmp(data.Properties.VariableNames, 'VAS_response')) && sum(~isnan(data.VAS_response)) > 18
    %     mode = 'VAS';
    % 
    %      % Extract VAS and add it to run table
    %      VAS_run_data = add_VAS_to_table(VAS_run_data, data);
    % end
    
    % changed because VAS data was not recognized as numeric array (Sarah
    % M)
    % if any(strcmp(data.Properties.VariableNames, 'VAS_response'))
    % 
    %     VAS_numeric = data.VAS_response;
    % 
    %     % Convert to numeric 
    %     if iscell(VAS_numeric)
    %         VAS_numeric = str2double(VAS_numeric);
    %     elseif isstring(VAS_numeric)
    %         VAS_numeric = str2double(VAS_numeric);
    %     end
    % 
    %     % Check 
    %     if sum(~isnan(VAS_numeric)) > 20
    %         mode = 'VAS';
    % 
    %         % Add to run table
    %         VAS_run_data = add_VAS_to_table(VAS_run_data, data);
    % 
    %         n_vas_added = n_vas_added + 1;   
    % 
    %     end
    % end


    % Process Influenca data
    if ~any(strcmp(data.Properties.VariableNames, 'nTrials')) || max(data.nTrials) < 150 
        continue; % skip files with incomplete task data
    end
    
    % Extract influenca trials and add them to trials table
    [Influenca_trial_data, run_data] = add_trials_to_table(Influenca_trial_data, data);

    % Extract run information, compute reinforcement learning parameters and add them to run table
    Influenca_run_data = add_run_to_table(Influenca_run_data, run_data);  
    n_files_logged = n_files_logged + 1; % counter    

end 

% Turn warnings back on
warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');

% Add counter to tables
Influenca_run_data = add_columns(Influenca_run_data);
Influenca_trial_data = join(Influenca_trial_data, Influenca_run_data(:,~ismember(Influenca_run_data.Properties.VariableNames, {'level'})), 'Keys', {'ID','date'});

% After processing all files
fprintf('\nProcessed %d files.\n', n_files_logged);

% Save tables
save_tables = {'Influenca_trial_data', 'Influenca_run_data'};
for i = 1:length(save_tables)
    if ~isempty(eval(save_tables{i}))
        filename = ['Demo_' save_tables{i} '.csv'];
        writetable(eval(save_tables{i}), fullfile(save_folder, filename))
    end
end
