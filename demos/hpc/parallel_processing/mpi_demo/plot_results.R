library(readr)
library(ggplot2)

df <- read_csv("combined_data.csv")

df_summarized <- df %>%  
  group_by(R, slots, cl_type, fun) %>%
  summarise(t = mean(elapsed, na.rm = TRUE), 
            t_sd = sd(elapsed, na.rm = TRUE)) %>% 
  ungroup() %>% filter(cl_type != "none") %>% 
  rename(Function = 'fun')

ggplot(df_summarized, aes(x = slots, y = t, color = Function)) + 
  geom_point(size = 1) + geom_line() +
  #geom_errorbar(aes(ymin = t - t_sd, ymax = t + t_sd), width = .2,
  #              position=position_dodge(0.05)) +
  scale_y_log10() + 
  facet_wrap(. ~ cl_type, nrow = 1) + 
  labs(title="Elapsed time per number of slots (cores)", 
       x = "Slots", y = "Elapsed Time (seconds)")+
  theme_classic()

ggsave("results.png", width = 5, height = 3)
