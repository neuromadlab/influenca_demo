%% Preprocessing of raw Inlfuenca Demo files                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 % MATLAB script to read raw food choice task CSV files, clean the data, rename files and write it to Excel files

% Set the input folder
input_folder = fullfile(pwd, 'Data');

% Create the 'Data_Cleaned' folder inside 'Demo' folder
output_folder = fullfile(pwd, 'Data_Cleaned');
if ~exist(output_folder, 'dir')
    mkdir(output_folder);  
end

% Define the log file path inside the Demo folder
log_file = fullfile(pwd, 'processed_files_log.txt');

% Create or load the log file that tracks processed files
if exist(log_file, 'file')
    processed_files = readlines(log_file);
else
    processed_files = string.empty;
end

% Start message
disp('Processing new files...');

% Get a list of all CSV files in the folder
csv_files = dir(fullfile(input_folder, '*.csv'));

% Check if there are any CSV files
if isempty(csv_files)
    disp('No CSV files found in the input folder.');
    return;
end

% Initialize counters for processed new files, empty new files, and failed new files
new_files_total = 0;
new_files_successful = 0;
new_files_empty = 0;
new_files_failed = 0;
test_files = 0;

% Suppress the warning about modified column headers
warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');

% Loop through each CSV file in the folder
for i = 1:length(csv_files)
    file_path = fullfile(input_folder, csv_files(i).name);
    
    % Check if the file has already been processed three times, if so skip it
    if sum(contains(processed_files, csv_files(i).name)) > 2
        continue; 
    end
    
    % Increment the count of new files
    new_files_total = new_files_total + 1;
    
    % Load CSV file
    try
        % Use 'detectImportOptions' and allow MATLAB to modify column headers
        opts = detectImportOptions(file_path); 
        data = readtable(file_path, opts);
        
        % Check if the file is empty (no data)
        if isempty(data)
            new_files_empty = new_files_empty + 1;
            continue; % Skip further processing of this file
        end
        
        % Shift all values to the top of the file
        data = shift_non_empty_to_top(data);

        % Remove unnecessary columns
        columns_to_delete = [
            data.Properties.VariableNames(startsWith(data.Properties.VariableNames, 'mouse_')), ...
            data.Properties.VariableNames(startsWith(data.Properties.VariableNames, 'mobile'))
        ];
        data = remove_unnecessary_columns(data, columns_to_delete);

        % Fetch the necessary values for renaming the file
        if any(strcmp(data.Properties.VariableNames, 'participant')) && ...
           any(strcmp(data.Properties.VariableNames, 'date'))
          
            participantID = string(data.participant(1));
            data.participant = repmat({participantID}, height(data), 1);

                       
            % Extract the date value
            date_value = string(data.date(1));

            % Add datetime date column
            date_dt = datetime(strrep(date_value, 'h', '.'), 'InputFormat', 'yyyy-MM-dd_HH.mm.ss.SSS');
            data.date_dt = repmat(date_dt, height(data), 1);
        
            % Update the participantID in the cleaned data table to reflect zero-padding
            data.participant = repmat({participantID}, height(data), 1);
        
            % Generate the new filename using Task_Demo_participantID_SessionNr_date.xlsx format
            task_version = data.expName{1};
            new_file_name = sprintf('%s_%s_S0_%s.xlsx', task_version, participantID, date_value);
            output_file_path = fullfile(output_folder, new_file_name);
            
        else
            % If the necessary columns are not found, throw an error
            error('Necessary columns for renaming not found in file.');
        end
        
        % Format RT column
        if ismember('syringeChoice_time', data.Properties.VariableNames)
            data.syringeChoice_time = str2double(regexprep(data.syringeChoice_time, '[\[\]]', ''));
        end

        % Write the processed data to an Excel file in the new folder
        writetable(data, output_file_path);
        
        % Append the current file name to the log file
        fid = fopen(log_file, 'a');
        fprintf(fid, '%s\n', csv_files(i).name);
        fclose(fid);
        
        % Increment the counter for successfully processed new files
        new_files_successful = new_files_successful + 1;
        
    catch ME
        % Increment the counter for failed new files (excluding empty files)
        if ~isempty(data)
            new_files_failed = new_files_failed + 1;
        end
        disp(['Failed to process ', csv_files(i).name, ': ', ME.message]);
    end
end

% Turn warnings back on
warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');

% Print the summary for new files only
disp(['Summary: ', num2str(new_files_successful), ' out of ', num2str(new_files_total), ' new files were successfully processed.']);
disp([num2str(new_files_empty), ' out of ', num2str(new_files_total), ' new files were empty.']);
disp([num2str(test_files), ' test files were skipped'])
disp([num2str(new_files_failed), ' out of ', num2str(new_files_total), ' new files failed to process (excluding empty files).']);

% Function to shift non-empty values to the top for each column
function data = shift_non_empty_to_top(data)
    % Check for skipped trials and add placeholders
    if any(ismember(data.Properties.VariableNames, 'optionRight'))
        indices_skipped = find(strcmp(data.choice, 'missed'));
        if iscell(data.optionRight)
            data.optionRight(indices_skipped) = {'-9999'};
            data.optionRight = str2double(data.optionRight);
        else
            data.optionRight(indices_skipped) = -9999;
        end
    end

    % Shifts non-empty (non-NaN) values to the top for each column in the table
    for col = 1:width(data)
        % Get the current column as an array
        column_data = data{:, col};
        
        if iscell(column_data)
            % For cell arrays (strings), find non-empty values
            non_empty_values = column_data(~cellfun('isempty', column_data)); % Non-empty cells
            % Create placeholders for empty values as empty strings
            empty_values = repmat({''}, size(column_data)); % Empty strings for cell arrays
            
        else
            % For numeric or non-cell types, find non-NaN values
            non_empty_values = column_data(~ismissing(column_data)); % Non-missing values
            % Create placeholders for empty values as NaN
            empty_values = NaN(size(column_data)); % NaN for numeric arrays
        end
        
        % Fill the top part with non-empty values
        num_non_empty = length(non_empty_values); 
        if num_non_empty > 0
            empty_values(1:num_non_empty) = non_empty_values; 
        end
        
        % Assign the shifted column back to the table
        data{:, col} = empty_values;
    end

    % Remove placeholders
    if any(ismember(data.Properties.VariableNames, 'optionRight'))
        data.optionRight(data.optionRight == -9999) = NaN;
    end
end

% Function to remove specific columns if they exist
function data = remove_unnecessary_columns(data, columns_to_delete)
    % Remove specific columns if they exist in the data table
    data = removevars(data, intersect(data.Properties.VariableNames, columns_to_delete));
end
