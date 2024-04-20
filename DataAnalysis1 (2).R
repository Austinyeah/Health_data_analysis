library(datasets)
install.packages("tidyverse")
install.packages("corrplot")
install.packages("mgcv")
install.packages(c("tidyverse", "rstatix"))
library(mgcv)
library(tidyverse)
library(ggplot2)
library(dplyr)
library(corrplot)
library(rstatix)
library(reshape2)

insurance_data <- read.csv("~/Health-Insurance-Dataset.csv")
par(mfrow = c(2, 3)) 

# Question A

# Age distribution
ggplot(insurance_data, aes(x = age)) +
  geom_histogram(binwidth = 5, fill = "blue", color = "black", alpha = 0.7) +
  labs(title = "Distribution of Age", x = "Age", y = "Frequency")


# BMI distribution
ggplot(insurance_data, aes(x = bmi)) +
  geom_histogram(binwidth = 2, fill = "green", color = "black", alpha = 0.7) +
  labs(title = "Distribution of BMI", x = "BMI", y = "Frequency")

# Children distribution
ggplot(insurance_data, aes(x = children)) +
  geom_bar(fill = "orange", color = "black", alpha = 0.7) +
  labs(title = "Distribution of Children", x = "Children", y = "Frequency")

# Bar plot for 'Smoker'
ggplot(insurance_data, aes(x = smoker, fill = smoker)) +
  geom_bar(color = "black", fill = c("lightblue", "lightcoral")) +
  labs(title = "Distribution of Smokers", x = "Smoker", y = "Count")

# Bar plot for 'Region'
ggplot(insurance_data, aes(x = region, fill = region)) +
  geom_bar(color = "black", fill = c("#66c2a5", "#fc8d62", "#8da0cb", "#e78ac3")) +
  labs(title = "Distribution of Regions", x = "Region", y = "Count")

# Bar plot for 'Sex'
ggplot(insurance_data, aes(x = sex, fill = sex)) +
  geom_bar(color = "black", fill = c("#1f78b4", "#ff7f00")) +
  labs(title = "Distribution of Genders", x = "Sex", y = "Count")

# Charges distribution
ggplot(insurance_data, aes(x = charges)) +
  geom_histogram(binwidth = 1000, fill = "red", color = "black", alpha = 0.7) +
  labs(title = "Distribution of Charges", x = "Charges", y = "Frequency")

# Bar plot for 'Region'
ggplot(insurance_data, aes(x = region, y = charges, fill = region)) +
  geom_boxplot(color = "black", alpha = 0.7) +
  labs(title = "Boxplot of Charges by Region", x = "Region", y = "Charges")

# Bar plot for 'Sex'
ggplot(insurance_data, aes(x = sex, y = charges, fill = sex)) +
  geom_boxplot(color = "black", alpha = 0.7) +
  labs(title = "Boxplot of Charges by Sex", x = "Sex", y = "Charges")

# Bar plot for 'Smoker'
ggplot(insurance_data, aes(x = smoker, y = charges, fill = smoker)) +
  geom_boxplot(color = "black", alpha = 0.7) +
  labs(title = "Boxplot of Charges by Smoking Status", x = "Smoker", y = "Charges")

# Boxplot for understanding the spread of Charges
ggplot(insurance_data, aes(x = 1, y = charges)) +
  geom_boxplot(fill = "purple", color = "black", alpha = 0.7) +
  labs(title = "Boxplot of Charges", x = "", y = "Charges")

# Summary statistics for all variables
summary(insurance_data)


# Question B

# Calculate correlation coefficients
cor_matrix <- cor(insurance_data[, c("age", "bmi", "children", "charges")])

print(cor_matrix)

ggplot(insurance_data, aes(x = bmi, y = children)) +
  geom_point(color = "green") +
  labs(title = "Scatter Plot: BMI vs. Children", x = "BMI", y = "Children")

ggplot(insurance_data, aes(x = age, y = charges)) +
  geom_point(color = "red") +
  labs(title = "Scatter Plot: Age vs. Charges", x = "Age", y = "Charges")

ggplot(insurance_data, aes(x = region, y = charges)) +
  geom_point(color = "pink") +
  labs(title = "Scatter Plot: Regions vs. Charges", x = "Region", y = "Charges")

# Testing for associations (using the cor.test function)
corrplot(cor_matrix, method = "number", type = "full", order = "hclust", tl.col = "black")

# Select numerical variables
numerical_vars <- subset(insurance_data, select = c(age, bmi, children, charges))

# Performing correlation tests for all pairs of numerical variables
cor_test_results <- matrix("", ncol = length(numerical_vars), nrow = length(numerical_vars))

for (i in 1:length(numerical_vars)) {
  for (j in 1:length(numerical_vars)) {
    cor_test_results[i, j] <- toString(cor.test(numerical_vars[, i], numerical_vars[, j]))
  }
}

# Print correlation test results
rownames(cor_test_results) <- colnames(cor_test_results) <- colnames(numerical_vars)

for (i in 1:nrow(cor_test_results)) {
  for (j in 1:ncol(cor_test_results)) {
    cat(paste("Correlation test result for", rownames(cor_test_results)[i], "and", colnames(cor_test_results)[j], ":\n"))
    cat(cor_test_results[i, j], "\n\n")
  }
}


# Select categorical variables to do test on.
categorical_vars <- select(insurance_data, smoker, region, sex)

# Function to perform chi-square test and print results
perform_chi_square_test <- function(variable1, variable2) {
  contingency_table <- table(variable1, variable2)
  chi_square_test <- chisq.test(contingency_table)
  
  cat("Chi-square test result for", deparse(substitute(variable1)), "and", deparse(substitute(variable2)), ":\n")
  print(chi_square_test)
  cat("\n")
}

# Performing chi-square tests for all pairs of categorical variables
for (variable1 in colnames(categorical_vars)) {
  for (variable2 in colnames(categorical_vars)) {
    if (variable1 != variable2) {
      perform_chi_square_test(categorical_vars[[variable1]], categorical_vars[[variable2]])
    }
  }
}

# Question C

# Linear regression model
linear_model <- lm(charges ~ age + sex + bmi + children + smoker + region, data = insurance_data)

# Display the summary of the linear regression model
summary(linear_model)

# Correlation Coefficient Test
correlation_matrix <- cor(insurance_data[, c("age", "bmi", "children","charges")])

# Visualize correlation matrix
corrplot::corrplot(correlation_matrix, method = "color")

selected_vars <- c("age", "bmi", "children", "charges")
selected_data <- select(all_of(insurance_data), all_of(selected_vars))

# Scatter plots
pairs(selected_data)


gam_model <- gam(charges ~ s(age) + sex + s(bmi) + children + smoker + region, data = insurance_data)

# Display the summary of the GAM
summary(gam_model)

# Question D 

# Calculate the median charge value
median_charge <- median(insurance_data$charges)

# Created a new variable CHARGE_split
insurance_data$CHARGE_split <- ifelse(insurance_data$charges > median_charge, "High", "Low")

# Perform t-tests for continuous variables
continuous_vars <- select_if(insurance_data, is.numeric)
t_test_results <- lapply(continuous_vars, function(variable) t.test(variable ~ CHARGE_split, data = insurance_data))
print(t_test_results)
# Perform chi-square tests for categorical variables
categorical_vars <- select_if(insurance_data, is.factor)
chi_square_results <- lapply(categorical_vars, function(variable) chisq.test(table(variable, insurance_data$CHARGE_split)))

# Visualize the results
ggplot(insurance_data, aes(x = CHARGE_split, y = bmi, fill = CHARGE_split)) +
  geom_boxplot() +
  labs(title = "Boxplot of BMI by CHARGE_split", x = "CHARGE_split", y = "BMI") +
  theme_minimal()

ggplot(insurance_data, aes(x = CHARGE_split, y = age, fill = CHARGE_split)) +
  geom_boxplot() +
  labs(title = "Boxplot of Age by CHARGE_split", x = "CHARGE_split", y = "Age") +
  theme_minimal()

ggplot(insurance_data, aes(x = CHARGE_split, y = children, fill = CHARGE_split)) +
  geom_boxplot() +
  labs(title = "Boxplot of Children by CHARGE_split", x = "CHARGE_split", y = "Children") +
  theme_minimal()

#Question E

# ANOVA for BMI and Age with respect to Region
anova_bmi <- aov(bmi ~ region, data = insurance_data)
anova_age <- aov(age ~ region, data = insurance_data)

# Kruskal-Wallis test for Age across regions
kruskal.test(bmi ~ region, data = insurance_data)
kruskal.test(age ~ region, data = insurance_data)

# Post-hoc tests (Tukey's HSD)
posthoc_bmi <- tukey_hsd(anova_bmi)
posthoc_age <- tukey_hsd(anova_age)

# Display ANOVA results
summary(anova_bmi)
summary(anova_age)

# Display post-hoc results
posthoc_bmi
posthoc_age

# Chi-square test for Sex and Smoker with respect to Region
chi_sex <- chisq.test(insurance_data$sex, insurance_data$region)
chi_smoker <- chisq.test(insurance_data$smoker, insurance_data$region)

# Display Chi-square results
chi_sex
chi_smoker
