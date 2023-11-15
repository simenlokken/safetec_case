library(tidyverse)

# Data cleaning

traffic_data <- readxl::read_excel("C:/Users/simen/Desktop/safetec_case/trafikkulykker.xlsx")

traffic_data_cleaned <- traffic_data |> 
  janitor::clean_names() |>
  mutate(alvorligste_skadegrad = as.factor(alvorligste_skadegrad)) |> 
  filter(alvorligste_skadegrad != "Ikke registrert") |> 
  mutate(
    ulykkestype = as.factor(case_when(
      alvorligste_skadegrad %in% c("Drept, Meget alvorlig skadd", "Alvorlig skadd") ~ 1,
      alvorligste_skadegrad %in% c("Lettere skadd", "Uskadd") ~ 0)),
  )

# Flipped bar chart with logarithmic X axis

flipped_bar_chart <- traffic_data_cleaned |> 
  filter(fartsgrense != 110 & fartsgrense != 100 & fartsgrense != 20) |> 
  drop_na() |> 
  filter(
    stedsforhold != "Ukjent" 
    & stedsforhold != "Vegstrekning utenfor kryss/avkjørsel" 
    & stedsforhold != "Annet kryss" 
    & stedsforhold != "Bru"
    & stedsforhold != "Bomstasjon"
    & stedsforhold != "Undergang (gang- og sykkelveg)"
    & stedsforhold != "Planovergang"
  ) |>
  group_by(fartsgrense, stedsforhold) |> 
  count() |> 
  ggplot(aes(x = stedsforhold, y = n, fill = fartsgrense)) +
  geom_col(alpha = 0.8) +
  coord_flip() +
  labs(
    x = NULL,
    y = "Antall ulykker",
    fill = "Fartsgrense"
  ) +
  theme(
    axis.title.x = element_text(size = 12),
    axis.title.y = element_text(size = 12),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank()
  ) +
  scale_y_continuous(breaks = seq(0, 1500, 250))

# Bar chart

bar_chart <- traffic_data_cleaned |> 
  drop_na() |> 
  filter(stedsforhold != "Ukjent" 
         & stedsforhold != "Vegstrekning utenfor kryss/avkjørsel" 
         & stedsforhold != "Annet kryss" 
         & stedsforhold != "Bru"
         & stedsforhold != "Bomstasjon"
         & stedsforhold != "Undergang (gang- og sykkelveg)"
         & stedsforhold != "Planovergang"
         ) |> 
  filter(fartsgrense != 20 & fartsgrense != 110 & fartsgrense != 100 & fartsgrense != 90) |> 
  group_by(fartsgrense, stedsforhold) |> 
  count() |> 
  ggplot(aes(x = factor(fartsgrense), y = n, fill = fct_reorder(stedsforhold, n, .desc = T))) +
  geom_col(position = "dodge", color = "black", alpha = 0.7) +
  theme_minimal() +
  labs(
    x = "Fartsgrense",
    y = "Antall ulykker",
    fill = "Stedsforhold"
  ) +
  scale_fill_brewer(palette = "Set1") +
  theme(
    axis.title.x = element_text(size = 12),
    axis.title.y = element_text(size = 12),
    panel.grid.minor.x = element_blank(),
    panel.grid.minor.y = element_blank(),
    panel.grid.major.x = element_blank()
  )

# Bar chart with highlight on tunnels

highlighted_bar_chart <- traffic_data_cleaned |> 
  drop_na() |> 
  filter(
    stedsforhold != "Ukjent" 
    & stedsforhold != "Vegstrekning utenfor kryss/avkjørsel" 
    & stedsforhold != "Annet kryss" 
    & stedsforhold != "Bru"
    & stedsforhold != "Bomstasjon"
    & stedsforhold != "Undergang (gang- og sykkelveg)"
    & stedsforhold != "Planovergang"
  ) |> 
  filter(
    fartsgrense != 20 & fartsgrense != 110 & fartsgrense != 100 & fartsgrense != 90
  ) |> 
  group_by(fartsgrense, stedsforhold) |> 
  count() |> 
  arrange(fartsgrense, desc(n)) |> 
  ggplot(aes(x = factor(fartsgrense), y = n, fill = fct_reorder(stedsforhold, n, .desc = T))) +
  geom_col(position = "dodge", color = "black", alpha = 0.8) +
  theme_minimal() +
  labs(
    x = "Fartsgrense",
    y = "Antall ulykker",
    fill = "Stedsforhold"
  ) +
  scale_fill_manual(values = c(
    "Tunnel (primært for motorkjøretøy)" = "dodgerblue",  # Highlighted color
    "Other Categories" = "gray20"  # Adjust the color for other categories as needed
  )) +
  theme(
  axis.title.x = element_text(size = 12),
  axis.title.y = element_text(size = 12),
  panel.grid.minor.y = element_blank(),
  panel.grid.major.x = element_blank()
  )
  

path = c("C:/Users/simen/Desktop/safetec_case")

ggsave(plot = flipped_bar_chart, filename = "flipped_bar_chart.jpg", path = path, dpi = 300, height = 7, width = 10)
ggsave(plot = bar_chart, filename = "bar_chart.jpg", path = path, dpi = 300, height = 7, width = 10)
ggsave(plot = highlighted_bar_chart, filename = "highlighted_bar_chart.jpg", path = path, dpi = 300, height = 7, width = 10)