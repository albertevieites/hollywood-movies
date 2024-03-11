# Import Libraries
library(ggplot2)
library(corrplot)
library(dplyr)
library(tidyverse)
library(purrr)
library(foreign)
library(apaTables)
library(PerformanceAnalytics)
library(psych)
library(corrr)
library(caret)
library(gridExtra)
library(patchwork)
library(RColorBrewer)
library(stringr)
library(showtext)
library(gganimate)
library(viridis)

# Fonts
showtext_auto()

font_add_google("Merriweather", "merriweather")
font_add_google("Merriweather Sans", "merriweather-sans")

# Cleaned Dataset
df_cleaned <- read.csv("data/clean_df.csv")
head(df_cleaned)
View(df_cleaned)

# Remove first column rank variable from the old dataset
df_cleaned <- subset(df_cleaned, select = -1)
names(df_cleaned)

# Numeric dataframe
df_numeric <- df_cleaned %>%
  select_if(is.numeric)

names(df_numeric)

# Double check data frame
str(df_cleaned)
summary(df_cleaned)
colSums(is.na(df_cleaned))

# Visualizations
# Create correlation matrix
correlation <- cor(df_numeric)

## Different correlation panels
pairs.panels(df_numeric, pch = 20, stars = TRUE, main = "Correlation Plot")

## Net correlation plot
df_numeric %>% 
  correlate() %>% 
  network_plot()

## Correlation Plot
my_colors <- colorRampPalette(c("#8C2C2C", "white", "#2E3F8B"))(200)
corrplot(correlation, 
         order = 'AOE', 
         tl.srt =  45,
         tl.col = "black",
         col = my_colors )

## Histograms
# Create histograms for numeric variables
df_long <- pivot_longer(df_numeric, cols = everything(), names_to = "variable", values_to = "value")

df_long$variable <- recode(df_long$variable,
                           'Audience..score..' = 'Audience Score',
                           'Rotten.Tomatoes..' = 'Rotten Tomatoes Score',
                           'Worldwide.Gross' =  'Worldwide Gross',
                           .default = df_long$variable) 

p_numerical <- ggplot(df_long, aes(x = value)) +
  geom_histogram(bins = 12, fill = "#2E3F8B", color = "grey") +
  facet_wrap(~ variable, scales = "free", ncol = 2, strip.position = "bottom") +
  theme_minimal() +
  labs(x = NULL, y = NULL) +
  theme(plot.title = element_text(hjust = 0.5),
        strip.background = element_blank(),
        strip.text.x = element_text(size = 10, color = "black", face = "bold"),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(color = "grey", size = 0.2), 
        panel.grid.minor.x = element_blank(),
        panel.grid.minor.y = element_blank(),
        panel.background = element_blank(),
        strip.placement = "outside")

p_numerical

# Create histograms for categorical variables
df_categorical <- df_cleaned %>%
  select(Genre, Lead.Studio)

df_long_categorical <- df_categorical %>%
  pivot_longer(cols = everything(), names_to = "variable", values_to = "value")

df_long_categorical <- df_long_categorical %>%
  filter(value != "", !is.na(value))

df_long_categorical <- df_long_categorical %>%
  mutate(value = factor(value)) %>%
  mutate(value = fct_infreq(value))

p_categorical <- ggplot(df_long_categorical, aes(x = value)) +
  geom_bar(fill = "#2E3F8B", color = "grey") +
  facet_wrap(~ variable, scales = "free_x", ncol = 1, strip.position = "bottom") +
  theme_minimal() +
  theme(
    strip.background = element_blank(),
    strip.text.x = element_text(size = 10, color = "black", face = "bold"),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(color = "grey", size = 0.1, linetype = "dashed"),
    panel.grid.minor.y = element_blank(),
    panel.background = element_blank(),
    strip.placement = "outside",
    axis.text.x = element_text(angle = 45, hjust = 1)
  ) +
  labs(x = NULL, y = "Count")

p_categorical

# Combining plots
## AUDIENCE SCORE | ROTTEN TOMATOES SCORE
## Create my own colour palette
my_colors <- c("#000000", "#306155", "#2E3F8B", "#E0A800", "#5C3061", "#8C2C2C")
## Boxplot
p_box_aud = ggplot(df_cleaned, aes(x = Audience..score.., y = Genre, fill = Genre)) +
  geom_boxplot(alpha = 0.8) +
  labs(x = "Audience Score") +
  scale_fill_manual(values = my_colors) +
  theme_minimal() +
  theme(
    text = element_text(family = "Helvetica", size = 12),
    axis.title.x = element_text(face = "bold", size = 14, margin = margin(r = 100, unit = 'pt')),
    axis.text.x = element_text(face = "bold"),
    axis.text.y = element_text(face = "bold"),
    axis.title.y = element_blank(),
    panel.grid.major.x = element_line(color = "grey", size = 0.1, linetype = "dashed"),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.y = element_blank(), 
    panel.grid.minor.y = element_blank(),
    panel.background = element_blank(),
    legend.position = "none"
  )

p_box_aud

## Bar
p_bar_aud = ggplot(df_cleaned, aes(y = Genre, fill = Genre)) +
  geom_bar(alpha = 0.8) +
  labs(x = "Number of Movies") +
  scale_fill_manual(values = my_colors) +
  theme_minimal() +
  theme(
    text = element_text(family = "Helvetica", size = 12),
    axis.title.x = element_text(face = "bold", size = 14, margin = margin(r = 100, unit = 'pt')),
    axis.text.x = element_text(face = "bold"),
    axis.text.y = element_blank(),
    axis.title.y = element_blank(),
    panel.grid.major.x = element_line(color = "grey", size = 0.1, linetype = "dashed"),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.y = element_blank(), 
    panel.grid.minor.y = element_blank(),
    panel.background = element_blank(),
    legend.position = "none"
  )
p_bar_aud

## Point - Scatter
p_scatter_aud = ggplot(df_cleaned) +
  geom_point(aes(x = Rotten.Tomatoes.. , y = Audience..score.., colour = Genre), size = 3, alpha = .8) +
  labs(x = "Rotten Tomatoes Score", y = "Audience Score") +
  scale_colour_manual(values = my_colors) +
  theme_minimal() +
  theme(
    axis.title.x = element_text(face = "bold", size = 12),
    axis.title.y = element_text(face = "bold", size = 12),
    panel.grid.major.x = element_line(color = "grey", size = 0.1, linetype = "dashed"),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.y = element_line(color = "grey", size = 0.1, linetype = "dashed"), 
    panel.grid.minor.y = element_blank(),
    panel.background = element_blank(),
    legend.position = "none"
  )

p_scatter_aud


## AUDIENCE SCORE | WORLWIDE GROSS
## Point - Scatter
p_scatter_gross = ggplot(df_cleaned) +
  geom_point(aes(x = Worldwide.Gross , y = Audience..score.., colour = Genre), size = 3, alpha = .8) +
  labs(x = "Worldwide Gross") +
  scale_colour_manual(values = my_colors) +
  theme_minimal() +
  theme(
    axis.title.x = element_text(face = "bold", size = 12),
    axis.text.y = element_blank(),
    axis.title.y = element_blank(),
    panel.grid.major.x = element_line(color = "grey", size = 0.1, linetype = "dashed"),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.y = element_line(color = "grey", size = 0.1, linetype = "dashed"), 
    panel.grid.minor.y = element_blank(),
    panel.background = element_blank(),
    legend.position = "none"
  )

p_scatter_aud

## Combine plots
p_all <- (p_box_aud | p_bar_aud) / (p_scatter_aud | p_scatter_gross) 
p_all + plot_layout(guides = 'collect')
p_all & theme(legend.position = 'none')


## WORLDWIDE GROSS | PROFITABILITY
## Boxplot
p_box_gross = ggplot(df_cleaned, aes(x = Worldwide.Gross, y = Genre, fill = Genre)) +
  geom_boxplot(alpha = 0.8) +
  scale_fill_manual(values = my_colors) +
  theme_minimal() +
  theme(
    text = element_text(family = "Helvetica", size = 12),
    axis.title.x = element_blank(),
    axis.text.x = element_text(face = "bold"),
    axis.title.y = element_blank(),
    axis.text.y = element_text(face = "bold"),
    panel.grid.major.x = element_line(color = "grey", size = 0.1, linetype = "dashed"),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.y = element_blank(), 
    panel.grid.minor.y = element_blank(),
    panel.background = element_blank(),
    legend.position = "none"
  )

p_box_gross

## Point - Scatter
p_scatter_gross_prof <- ggplot(df_cleaned) +
  geom_point(aes(x = Worldwide.Gross , y = Profitability, colour = Genre), size = 3, alpha = .8) +
  labs(x = "Worldwide Gross", y = "Profitability") +
  scale_colour_manual(values = my_colors) +
  theme_minimal() +
  theme(
    axis.title.x = element_text(face = "bold", size = 12),
    axis.text.x = element_text(face = "bold"),
    axis.title.y = element_text(face = "bold", size = 12),
    axis.text.y = element_text(face = "bold"),
    panel.grid.major.x = element_line(color = "grey", size = 0.1, linetype = "dashed"),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.y = element_line(color = "grey", size = 0.1, linetype = "dashed"), 
    panel.grid.minor.y = element_blank(),
    panel.background = element_blank(),
    legend.position = "none"
  )

p_scatter_gross_prof

p_all_2 <- (p_box_gross) / (p_scatter_gross_prof) 
p_all_2 + plot_layout(guides = 'collect')
p_all_2 & theme(legend.position = 'none')

names(df_cleaned)

# CIRCLE
## New dataframe summarizing number of movies by Studio
df_studio_summary <- df_cleaned %>%
  filter(!is.na(Lead.Studio) & Lead.Studio != "") %>%
  count(Lead.Studio) %>%
  rename(Count = n) %>%
  arrange(desc(Count))

max_count <- max(df_studio_summary$Count, na.rm = TRUE)

# Generate a color gradient based on your base color
number_of_colors <- n_distinct(df_studio_summary$Lead.Studio)
color_base <- "#2E3F8B"
color_palette <- colorRampPalette(colors = c(color_base, "white"))(number_of_colors)

# Line
line_data <- df_studio_summary %>%
  mutate(end = max(Count) * 1.1)

df_studio_summary$Lead.Studio <- str_wrap(df_studio_summary$Lead.Studio, width = 10)


# Polar Plot
p_polar <- ggplot(df_studio_summary, aes(x = reorder(Lead.Studio, Count), y = Count, fill = Lead.Studio)) +
  geom_bar(stat = "identity", aes(fill = Lead.Studio), show.legend = FALSE) +
  geom_segment(data = line_data, 
               aes(x = reorder(Lead.Studio, Count), y = 0, xend = reorder(Lead.Studio, Count), yend = end),
               linetype = "dashed", color = "grey50") +
  coord_polar() +
  scale_fill_brewer(palette = "Set3") +
  theme_void() +
  theme(
    text = element_text(color = "gray12", family = "merriweather"),
    plot.title = element_text(face = "bold", size = 25, hjust = 0.5, color = "grey12"),
    plot.subtitle = element_text(size = 14, hjust = 0.5, color = "grey12"),
    plot.caption = element_text(size = 10, hjust = 0.5, color = "grey12"),
    # Adjust the background and the grid
    panel.background = element_rect(fill = "white", color = "white"),
    panel.grid.major.y = element_line(color = "grey92", linetype = "solid"),
    axis.text.x = element_text(color = "grey30", size = 10, face = "bold", hjust=1, vjust=1),
    axis.text.y = element_blank(),
    axis.title = element_blank(),
    legend.position = "bottom"
  ) 

# Print the final plot
p_polar


# Studio Histogram by Year Animation
## plot
df_studio_year_summary <- df_cleaned %>%
  group_by(Lead.Studio, Year) %>%
  summarise(Count = n(), .groups = 'drop') %>%
  filter(!is.na(Lead.Studio) & Lead.Studio != "") %>%
  arrange(Lead.Studio, Year)

df_studio_year_summary$Year <- as.integer(df_studio_year_summary$Year)

p_animation <- ggplot(df_studio_year_summary, aes(x = Lead.Studio, y = Count, group = Lead.Studio, fill = Lead.Studio)) +
  geom_col(show.legend = FALSE) +
  scale_fill_viridis_d(option = "mako") +
  transition_time(Year) +
  enter_grow() +
  exit_fade() +
  labs(title = 'Movies by Studio: Year {as.integer(frame_time)}', x = NULL, y = 'Number of Movies') +
  theme_minimal() +
  theme(
    panel.background = element_blank(),
    panel.grid.major.y = element_line(color = "grey85", linetype = "dotted"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.minor.y = element_blank(),
    plot.title = element_text(family = "merriweather", face = "bold", size = 20),
    axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1, size = 12),
    axis.text.y = element_text(hjust = 1, vjust = 1, size = 12),
    axis.title.y = element_blank()
  )

animate(p_animation, width = 800, height = 600, renderer = gifski_renderer(), duration = 10)

