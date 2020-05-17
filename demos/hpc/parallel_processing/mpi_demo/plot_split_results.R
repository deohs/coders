library(readr)
library(ggplot2)
library(dplyr)
library(scales)

df <- read_csv("combined_data_split.csv")

df_summarized <- df %>%  
  mutate(splits = factor(sprintf("%d", splits), ordered = TRUE)) %>% 
  group_by(R, splits, split_method, workers, cl_type, fun) %>%
  summarise(t = mean(elapsed, na.rm = TRUE), 
            t_sd = sd(elapsed, na.rm = TRUE)) %>% 
  ungroup() %>% filter(cl_type != "none") %>% 
  rename(`Split Method` = 'split_method')

ggplot(df_summarized, aes(x = splits, y = t, fill = `Split Method`)) + 
  geom_bar(position = "dodge", stat = "identity") +
  #geom_errorbar(aes(ymin = t - t_sd, ymax = t + t_sd), width = .2,
  #              position=position_dodge(0.05)) +
  scale_y_log10() + 
  facet_wrap(. ~ cl_type, nrow = 1) + 
  labs(title = paste("Elapsed time per split count and method", 
                     "for workers=8 and replicates(R)=100,000",
                     sep = "\n"),
       x = "Split Count", y = "Elapsed Time (seconds)")+
  theme_classic()

ggsave("results_splits_log10.png", width = 5, height = 3)

system("convert -resize 825x495 results_splits_log10.png results_splits_log10_55pct.png")
