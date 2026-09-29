%% Fit reinforcement learning model to Influenca run

function [alpha_win, alpha_pun, beta, lambda, log_likelihood] = fit_rl_model(run_data)

    % Initial parameter values
    x0 = [0.5, 0.5, 2, 0.5];
    
    % Recode choices: 1 -> 1, 0 -> 2 (A = 1, B = 2)
    choices = 2 - run_data.choice_a;

    cD = [choices, run_data.reward/50, run_data.draw_a, [run_data.reward_a, run_data.reward_b]];

    options = optimoptions('fmincon','Display','off','Algorithm','sqp');
      
    mcon.A = [];
    mcon.b = [];
    mcon.lb = [0,0,0,0]; % lower bounds
    mcon.ub = [1,1,15,1]; % upper bounds

    [xout,fval1,mcon.exitflag1,mcon.out1,mcon.lambda1,mcon.grad1,mcon.hessian1] = fmincon(@(x)model_additive_2LR(x,cD),x0,mcon.A,mcon.b,[],[],mcon.lb,mcon.ub,[], options);
    
    alpha_win = xout(1);
    alpha_pun = xout(2);
    beta = xout(3);
    lambda = xout(4);
    log_likelihood = fval1;
end
