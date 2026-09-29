%% Modeling Influenca Data 2021 - Model Fitting (Additive 2LR Model)
% contact: nils.kroemer@uni-tuebingen.de @cornu_copiae
% Parameter Estimation for Basic Model (fmincon call) 

function L = fit_model_additive_2LR(x,D)

%Model Parameters, original units 
alpha_win = x(1);   % initial alpha = 0,5
alpha_loose = x(2); %initial alpha = 0.5  
beta = x(3);

% Lambda 
lambda = x(4);

%Model Parameters, transformed for unconstrained search
%alpha = 1/(1+exp(-x(1)));
%beta  = exp(x(2)); 
%gamma = exp(x(3));

%Parse Data
rew = D(:,2);
action = D(:,1);
outcome = D(:,3);
rew_grid = D(:,4:5);

%Initialization of values for the model
L = 0;                          %initial value sum of squared error
RPE_alpha = zeros(length(action),1);  %initial RPEs
Q = zeros(length(action),1);    %initial Q values -> only one Q-value is calculated for this model 
est_prob = 0.5 * ones(length(action),1); % initial estimates of probability 
choice_prob = zeros(length(action),1); % initial values for choice_prob (0) ? 

%loop through trials
for t = 1:length(action)         
    % Compute outcome prediction error 
    % rew. pred. error is difference between was I right (1) or wrong(0) and est. prob
    % for that reward
    RPE_alpha(t,1) = outcome(t,1) - est_prob(t,1);
    % draw_blue immer 0 oder 1 und est_prob für den ersten Durchgang immer
    % 0,5; damit RPE_alpha im ersten Durchgang immer größer 0
    
    %updates Q values
    if t < length(action) 
               
        if rew(t,1) > 0
            % p_win(Option A,t+1) = P_win(Option A, t) + alpha*prediction error
            est_prob(t+1,1) = est_prob(t,1) + alpha_win * RPE_alpha(t,1);  
            Q(t+1,1) = lambda*(est_prob(t+1,1)-(1-est_prob(t+1,1))) + (1-lambda)* ((rew_grid(t+1,1)/50)-(rew_grid(t+1,2)/50));        
                       
        else 
            est_prob(t+1,1) = est_prob(t,1) + alpha_loose * RPE_alpha(t,1);            
            Q(t+1,1) = lambda*(est_prob(t+1,1)-(1-est_prob(t+1,1))) + (1-lambda)* ((rew_grid(t+1,1)/50)-(rew_grid(t+1,2)/50));       
        
        end     
        
        if action(t,1) == 1 %Probability for choice A (A=1, B=2) 
            choice_prob = 1/(1+ exp(Q(t).*-beta));  %beta = 0 -> choice = 0.5 (1/1) 
        else
            choice_prob = 1 - (1/(1+ exp(Q(t).*-beta)));  
        end         
               
        L = L + log(choice_prob);     
    end   
       
end
      
 

L=-L; %negative due to function minimization
 
end


