library(foreign)
library(ggplot2)
library(cowplot)
library(MASS)
library(Hmisc)
library(plyr)
library(ggridges)
library(viridisLite)
library(viridis)
library(tidyr)
library(patchwork)


### INSERT YOUR ID HERE ###
ID = 'simon_test'


# Create plots folder
if (!dir.exists("plots")) {
  dir.create("plots", recursive = TRUE)
}

# Load data
trial_data <- read.csv(file.path('Tables', 'Demo_Influenca_trial_data.csv'),  header=TRUE)
run_data <- read.csv(file.path('Tables', 'Demo_Influenca_run_data.csv'),  header=TRUE)

# Select only runs of ID
trial_data_sub <- trial_data[trial_data$ID == ID,]
run_data_sub <- run_data[run_data$ID == ID,]

# Select trial data of first run
trial_data_first_run <- trial_data_sub[trial_data_sub$run_counter == 1,]

# Convert to long format
trial_data_first_run_l_p_reward <- pivot_longer(trial_data_first_run, col = c('p_reward_a', 'p_reward_b'), names_to = 'p_reward_option', values_to = 'p_reward')

# Plot win probabilities of first run
p_win_probs <- ggplot(trial_data_first_run_l_p_reward, aes(x = factor(trial), y = p_reward, color = factor(p_reward_option))) +
  geom_line(aes(group = p_reward_option)) +
  theme_cowplot() +
  scale_color_viridis(option = "D", discrete = TRUE, labels = c("Option A", "Option B")) +
  scale_x_discrete(breaks=seq(0, 150, 25)) +
  xlab(label = 'Trial') +
  ylab(label = 'Win Probability') +
  theme(
    panel.background = element_rect(fill = "white", color = NA),
    plot.background  = element_rect(fill = "white", color = NA),
    legend.background = element_rect(fill = "white", color = NA),
    text = element_text(face = 'bold',size = 5),axis.text = element_text(face = 'plain',size = 5),
    legend.title = (element_blank()),
    plot.title = element_text(size=6)) +
  ggtitle("Win Probabilities First Run")

ggsave(file.path("plots", paste0("fig_", ID, "_win_probabilities_first_run.png")), plot = p_win_probs, width = 3, height = 2, units = "in", dpi = 300)

# Plot scores
p_scores <- ggplot(trial_data_sub, aes(x = factor(trial), y = score, color = factor(level))) +
  geom_line(aes(group = level)) +
  theme_cowplot() +
  scale_color_viridis(option = "D", discrete = TRUE) +
  scale_x_discrete(breaks=seq(0, 150, 25)) +
  xlab(label = 'Trial') +
  ylab(label = 'Score') +
  labs(color = "Run") +
  theme(
    text = element_text(face = 'bold',size = 12),axis.text = element_text(face = 'plain',size = 12.0),
    legend.title = (element_text(size=12)),
    plot.title = element_text(size=12)) +
  ggtitle("Score per trial and level")

# Alpha win
p_alpha_win <- ggplot(run_data_sub, aes(x = factor(level), y = alpha_win)) +
  geom_col() +
  theme_cowplot() +
  xlab(label = 'Run') +
  ylab(label = 'Alpha reward') +
  theme(text = element_text(face = 'bold',size = 12),axis.text = element_text(face = 'plain',size = 12.0),
        legend.title = (element_blank()), legend.position="none",
        plot.title = element_text(size=12)) +
  ggtitle("Learning rate: wins")

p_alpha_pun <- ggplot(run_data_sub, aes(x = factor(level), y = alpha_pun)) +
  geom_col() +
  theme_cowplot() +
  xlab(label = 'Run') +
  ylab(label = 'Alpha loss') +
  theme(text = element_text(face = 'bold',size = 12),axis.text = element_text(face = 'plain',size = 12.0),
        legend.title = (element_blank()), legend.position="none",
        plot.title = element_text(size=12)) +
  ggtitle("Learning rate: loss")

p_beta <- ggplot(run_data_sub, aes(x = factor(level), y = beta)) +
  geom_col() +
  theme_cowplot() +
  xlab(label = 'Run') +
  ylab(label = 'Beta') +
  theme(text = element_text(face = 'bold',size = 12),axis.text = element_text(face = 'plain',size = 12.0),
        legend.title = (element_blank()), legend.position="none",
        plot.title = element_text(size=12)) +
  ggtitle("Reward sensitivity")

p_lambda <- ggplot(run_data_sub, aes(x = factor(level), y = lambda)) +
  geom_col() +
  theme_cowplot() +
  xlab(label = 'Run') +
  ylab(label = 'Lambda') +
  theme(text = element_text(face = 'bold',size = 12),axis.text = element_text(face = 'plain',size = 12.0),
        legend.title = (element_blank()), legend.position="none",
        plot.title = element_text(size=12)) +
  ggtitle("Probability weighting")

# Log-Likelihood per level
p_ll <- ggplot(run_data_sub, aes(x = factor(level), y = log_likelihood)) +
  geom_col() +
  theme_cowplot() +
  xlab(label = 'Run') +
  ylab(label = 'Log-Likelihood') +
  theme(text = element_text(face = 'bold',size = 12),axis.text = element_text(face = 'plain',size = 12.0),
        legend.title = (element_blank()), legend.position="none",
        plot.title = element_text(size=12)) +
  ggtitle("Model Fit Per Level")

# Reward
p_outcomes <- ggplot(trial_data_sub, aes(x = factor(level), y = reward)) +
  stat_summary(fun = mean, size = 1, position = position_dodge(width = 0.6), geom = "point") +
  stat_summary(fun.data = "mean_cl_boot", size = 0.4, position = position_dodge(width = 0.6), geom = "linerange") +
  theme_cowplot() +
  xlab(label = 'Level') +
  ylab(label = 'Reward') +
  theme(text = element_text(face = 'bold',size = 12),axis.text = element_text(face = 'plain',size = 12.0),
        legend.title = (element_text(size=12)),
        plot.title = element_text(size=12)) +
  ggtitle("Mean Reward Per Level")

# RTs
p_rt <- ggplot(trial_data_sub, aes(x = factor(level), y = rt)) +
  stat_summary(fun = mean, size = 1, position = position_dodge(width = 0.6), geom = "point") +
  stat_summary(fun.data = "mean_cl_boot", size = 0.4, position = position_dodge(width = 0.6), geom = "linerange") +
  theme_cowplot() +
  xlab(label = 'Level') +
  ylab(label = 'RT (s)') +
  #labs(color = 'Level') +
  theme(text = element_text(face = 'bold',size = 12),axis.text = element_text(face = 'plain',size = 12.0),
        legend.title = (element_text(size=12)),
        plot.title = element_text(size=12)) +
  ggtitle("Mean RT Per Level")

fig_stan_estimates <- (p_alpha_win | p_alpha_pun | p_beta | p_lambda) / 
  (p_scores | p_outcomes | p_rt | p_ll) +
  plot_annotation(tag_levels = 'a') & theme(plot.tag = element_text(size = 12), 
                                            legend.key.size = unit(0.1, 'in'),
                                            legend.key.width = unit(0.05, 'in'),
                                            legend.title = element_text(size=12),
                                            legend.text = element_text(size=12))

ggsave(file.path("plots", paste0("fig_", ID, ".png")), plot = fig_stan_estimates, width = 12, height = 6, units = "in", dpi = 600)



### Parameter plots of all participants
alpha_win <- ggplot(run_data, aes(x = factor(run_counter), y = alpha_win)) +
  stat_summary(fun = mean, size = 1, position = position_dodge(width = 0.6), geom = "point") +
  stat_summary(fun.data = "mean_cl_boot", size = 0.4, position = position_dodge(width = 0.6), geom = "linerange") +
  theme_cowplot() +
  scale_color_viridis(option = "D") +
  xlab(label = 'Run') +
  ylab(label = expression(alpha['win'])) +
  theme(text = element_text(face = 'bold', size = 12),axis.text = element_text(face = 'plain',size = 12.0),
        legend.title = (element_blank()), legend.position="none",
        axis.text.x = element_blank(),
        axis.title.x = element_blank(),
        plot.title = element_text(size=12)) +
  ggtitle("Learning rate: wins")

alpha_pun <- ggplot(run_data, aes(x = factor(run_counter), y = alpha_pun)) +
  stat_summary(fun = mean, size = 1, position = position_dodge(width = 0.6), geom = "point") +
  stat_summary(fun.data = "mean_cl_boot", size = 0.4, position = position_dodge(width = 0.6), geom = "linerange") +
  theme_cowplot() +
  scale_color_viridis(option = "D") +
  xlab(label = 'Run') +
  ylab(label =  expression(alpha['pun'])) +
  theme(text = element_text(face = 'bold', size = 12),axis.text = element_text(face = 'plain',size = 12.0),
        legend.title = (element_blank()), legend.position="none",
        axis.text.x = element_blank(),
        axis.title.x = element_blank(),
        plot.title = element_text(size=12)) +
  ggtitle("Learning rate: loss")

beta <- ggplot(run_data, aes(x = factor(run_counter), y = beta)) +
  stat_summary(fun = mean, size = 1, position = position_dodge(width = 0.6), geom = "point") +
  stat_summary(fun.data = "mean_cl_boot", size = 0.4, position = position_dodge(width = 0.6), geom = "linerange") +
  theme_cowplot() +
  scale_color_viridis(option = "D") +
  xlab(label = 'Run') +
  ylab(label = expression(beta)) +
  theme(text = element_text(face = 'bold',size = 12),axis.text = element_text(face = 'plain',size = 12.0),
        legend.title = (element_blank()),legend.position="none",
        plot.title = element_text(size=12)) +
  ggtitle("Reward sensitivity")

lambda <- ggplot(run_data, aes(x = factor(run_counter), y = lambda)) +
  stat_summary(fun = mean, size = 1, position = position_dodge(width = 0.6), geom = "point") +
  stat_summary(fun.data = "mean_cl_boot", size = 0.4, position = position_dodge(width = 0.6), geom = "linerange") +
  theme_cowplot() +
  scale_color_viridis(option = "D") +
  xlab(label = 'Run') +
  ylab(label = expression(lambda)) +
  theme(text = element_text(face = 'bold',size = 12),axis.text = element_text(face = 'plain',size = 12.0),
        legend.title = (element_blank()),legend.position="none",
        plot.title = element_text(size=12)) + 
  ggtitle("Probability weighting")

