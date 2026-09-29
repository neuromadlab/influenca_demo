%% Add Influenca run to the run table
% Input: Current run table and Influenca run data
% Output: Appended run table

function run_table = add_run_to_table(run_table, run_data)
    
    % Preallocate new row
    new_run = table('Size',[1, 12], ...
    'VariableTypes', {'string', 'datetime', 'double', ...
    'double', 'double', 'double', 'double', 'double', 'double', ...
    'double', 'double', 'double'}, ...
    'VariableNames', {'ID', 'date', 'level', ...
    'finalScore', 'alpha_win', 'alpha_pun', 'beta', 'lambda', ...
    'log_likelihood', 'run_counter', 'run_counter_day', 'days_from_start'});

    % Add run info
    new_run.ID(1) = string(run_data.ID{1}); % changed
    new_run.date(1) = run_data.date(1);
    new_run.level(1) = run_data.level(150);
    new_run.finalScore(1) = run_data.score(150);
    new_run.run_counter = NaN;
    new_run.run_counter_day = NaN;
    new_run.days_from_start = NaN;

    % Fit reinforcement learning model (additive 2LR model)
    [alpha_win, alpha_pun, beta, delta, log_likelihood] = fit_rl_model(run_data);

    % Add parameters
    new_run.alpha_win(1) = alpha_win;
    new_run.alpha_pun(1) = alpha_pun;
    new_run.beta(1) = beta;
    new_run.lambda(1) = delta;
    new_run.log_likelihood(1) = log_likelihood;
    
    % Add run to run table
    run_table = [run_table; new_run];
    

end
