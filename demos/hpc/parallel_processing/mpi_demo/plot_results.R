library(readr)
library(ggplot2)
library(dplyr)

df <- read_csv("combined_data.csv")

df_summarized <- df %>%  
  group_by(R, workers, cl_type, fun) %>%
  summarise(t = mean(elapsed, na.rm = TRUE), 
            t_sd = sd(elapsed, na.rm = TRUE)) %>% 
  ungroup() %>% filter(cl_type != "none") %>% 
  rename(Function = 'fun')

ggplot(df_summarized, aes(x = workers, y = t, color = Function)) + 
  geom_point(size = 1) + geom_line() +
  #geom_errorbar(aes(ymin = t - t_sd, ymax = t + t_sd), width = .2,
  #              position=position_dodge(0.05)) +
  scale_y_log10() + 
  facet_wrap(. ~ cl_type, nrow = 1) + 
  labs(title="Elapsed time per number of workers (cores)", 
       x = "workers", y = "Elapsed Time (seconds)")+
  theme_classic()

ggsave("results.png", width = 5, height = 3)

system("convert -resize 825x495 results.png results_55pct.png")
