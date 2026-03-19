library(ggpubr)
library(rstatix)
library(car)
library(tidyverse)
#install.packages("tidyverse")

#### loading data
df = read.csv("D:/Users data/Margarita/intersections_stat_for_R.csv", header = TRUE)
head(df)
ggboxplot(
  df, x = "group", y = c("i1", "i2"), 
  merge = TRUE, palette = "jco"
)

#### Manova
model <- lm(cbind(i1, i2) ~ group, df)
Manova(model, test.statistic = "Pillai") #### toto vypise vysledky pro manovu

#### Multiple t-test
df_mod <- df %>%
  pivot_longer(-group, names_to = "variables", values_to = "value")
df_mod

stat.test <- df_mod %>%
  group_by(variables) %>%
  t_test(value ~ group) %>%
  adjust_pvalue(method = "BH") %>%
  add_significance()
stat.test #### toto vypise vysledky pro mnohonasobne testovani

