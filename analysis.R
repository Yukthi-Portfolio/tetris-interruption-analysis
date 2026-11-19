# All pacakages are Installed
# Loading the packages
library(tidyverse)  # For data manipulation and ggplot2
library(psych)      # For descriptive statistics
library(car)        # For Levene's test
library(effsize)    # For effect size calculation

setwd("~/Desktop/QDA-2")

# Loading the data
tetris_data <- read.csv("tetris.csv")

# To view the first few rows
head(tetris_data)

# To check structure
str(tetris_data)

# Checking for the missing values
sum(is.na(tetris_data))
colSums(is.na(tetris_data))

# Checking for duplicates
sum(duplicated(tetris_data))

# Ensure 'condition' is a factor
tetris_data$condition <- as.factor(tetris_data$condition)

# Checking the levels
levels(tetris_data$condition)

# Checking for any unusual values in score (should be 0-100)
summary(tetris_data$score)

# Looking for outliers visually
boxplot(tetris_data$score, main="Boxplot of Scores", ylab="Score")

# Overall summary
summary(tetris_data)

# Descriptive statistics by condition
describeBy(tetris_data$score, group = tetris_data$condition)

# Histogram by condition
ggplot(tetris_data, aes(x = score, fill = condition)) +
  geom_histogram(binwidth = 5, position = "dodge", color = "black") +
  labs(title = "Distribution of Tetris Scores by Condition",
       x = "Score",
       y = "Frequency") +
  theme_minimal()

# Boxplot comparison
ggplot(tetris_data, aes(x = condition, y = score, fill = condition)) +
  geom_boxplot() +
  labs(title = "Tetris Scores by Interruption Type",
       x = "Condition",
       y = "Score") +
  theme_minimal() +
  stat_summary(fun = mean, geom = "point", shape = 23, size = 3, fill = "white")

# Bar plot with error bars (mean ± SE)
summary_stats <- tetris_data %>%
  group_by(condition) %>%
  summarise(
    mean_score = mean(score),
    se = sd(score) / sqrt(n())
  )

ggplot(summary_stats, aes(x = condition, y = mean_score, fill = condition)) +
  geom_bar(stat = "identity", color = "black", width = 0.6) +
  geom_errorbar(aes(ymin = mean_score - se, ymax = mean_score + se), 
                width = 0.2, linewidth = 0.8) +
  geom_text(aes(label = round(mean_score, 2)), 
            vjust = -2.5, size = 4, fontface = "plain") +
  scale_fill_manual(values = c("auditory" = "#3498db", "visual" = "#e74c3c")) +
  scale_x_discrete(labels = c("auditory" = "Auditory", "visual" = "Visual")) +
  labs(x = "Interruption Condition",
       y = "Mean Tetris Score (± SE)",
       caption = "Figure 1. Mean Tetris Performance Scores by Interruption Condition.\nError bars represent ±1 SE. Auditory (M = 67.94, SE = 1.95) vs. Visual (M = 46.62, SE = 2.09),\nt(62) = 7.46, p < .001, d = 1.86.") +
  theme_minimal(base_size = 13) +
  theme(
    plot.caption = element_text(hjust = 0.5, size = 10, face = "bold"),
    axis.title = element_text(face = "plain", size = 11),
    axis.line = element_line(color = "black", linewidth = 0.7),
    axis.ticks = element_line(color = "black", linewidth = 0.7),
    axis.text = element_text(color = "black", size = 10),
    panel.grid.major = element_line(color = "grey90", linewidth = 0.3),
    panel.grid.minor = element_blank(),
    legend.position = "none"
  ) +
  ylim(0, 100)
       
# To save the plot
ggsave("tetris_results.png", width = 8, height = 6, dpi = 300)

# To check assumptions for Independent samples T-test

# Independence: Satisfied by between-participants design
# Normality check

# Shapiro-Wilk test for each group
shapiro.test(tetris_data$score[tetris_data$condition == "auditory"])
shapiro.test(tetris_data$score[tetris_data$condition == "visual"])

# Q-Q plots
par(mfrow = c(1, 2))
qqnorm(tetris_data$score[tetris_data$condition == "auditory"], 
       main = "Q-Q Plot: Auditory")
qqline(tetris_data$score[tetris_data$condition == "auditory"])

qqnorm(tetris_data$score[tetris_data$condition == "visual"], 
       main = "Q-Q Plot: Visual")
qqline(tetris_data$score[tetris_data$condition == "visual"])
par(mfrow = c(1, 1))

# Homogeneity of variance (Levene's Test)
leveneTest(score ~ condition, data = tetris_data)

# Inferential Statistics
# Perform independent samples t-test
t_test_result <- t.test(score ~ condition, 
                        data = tetris_data, 
                        var.equal = TRUE)  # Use var.equal=FALSE if Levene's test is significant

print(t_test_result)

# Effect size (Cohen's d)
cohen_d <- cohen.d(score ~ condition, data = tetris_data)
print(cohen_d)

#Results

# Create a comprehensive summary
cat("=== ANALYSIS SUMMARY ===\n\n")

# Sample sizes
cat("Sample Sizes:\n")
table(tetris_data$condition)

cat("\n\nDescriptive Statistics:\n")
print(describeBy(tetris_data$score, group = tetris_data$condition))

cat("\n\nt-test Results:\n")
print(t_test_result)

cat("\n\nEffect Size (Cohen's d):\n")
print(cohen_d)