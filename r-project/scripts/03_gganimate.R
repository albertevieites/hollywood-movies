# Libraries
library(ggplot2)
library(gganimate)
library(RColorBrewer)

# Load data
df <- read.csv("data/HollywoodsMostProfitableStories.csv")
View(df)

table(df$Profitability)

df_filtered <- df %>%
  filter(Profitability <= 60) %>% # Ajusta el 60 si necesitas un límite diferente
  drop_na(Audience..score.., Profitability, Worldwide.Gross, Genre)

# Asegúrate de que Year es numérico para la animación
df_filtered$Year <- as.numeric(as.character(df_filtered$Year))

# Crear el scatter plot animado con el dataframe filtrado
p <- ggplot(df_filtered, aes(x = Audience..score.., y = Profitability, size = Worldwide.Gross, color = Genre)) +
  geom_point(alpha = 0.7) +
  scale_colour_brewer(palette = "Paired") +
  scale_size(range = c(1, 10), name = "Worldwide Gross\n(millions)") +
  labs(title = 'Year: {as.integer(frame_time)}', x = 'Audience Score', y = 'Profitability') +
  transition_time(Year) +
  enter_grow() +
  exit_fade() +
  theme_minimal() +
  theme(
    panel.background = element_blank(),
    panel.grid.major.x = element_line(color = "grey85", linetype = "dotted"),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.y = element_line(color = "grey85", linetype = "dotted"),
    panel.grid.minor.y = element_blank(),
    plot.title = element_text(face = "bold", size = 18),
    axis.title.x = element_text(face = "bold", size = 14), 
    axis.text.x = element_text(hjust = 1, vjust = 1, size = 12),
    axis.title.y = element_text(face = "bold", size = 14), 
    axis.text.y = element_text(hjust = 1, vjust = 1, size = 12)
  )

# Crear la animación
animate(p, width = 800, height = 600, duration = 20, fps = 5, renderer = gifski_renderer())
