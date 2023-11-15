library(tidyverse)

# Load data

traffic_data <- readxl::read_xlsx("C:/Users/simen/Desktop/trafikkulykker.xlsx")

# Clean names and add accident type column

traffic_data_cleaned <- traffic_data |> 
  janitor::clean_names() |>
  mutate(alvorligste_skadegrad = as.factor(alvorligste_skadegrad)) |> 
  filter(alvorligste_skadegrad != "Ikke registrert") |> 
  mutate(
    ulykkestype = as.factor(case_when(
      alvorligste_skadegrad %in% c("Drept, Meget alvorlig skadd", "Alvorlig skadd") ~ 1,
      alvorligste_skadegrad %in% c("Lettere skadd", "Uskadd") ~ 0)),
    fartsgrense = fartsgrense / 10
  )

# Regression

model <- glm(ulykkestype ~ fartsgrense +  vegbredde, data = traffic_data_cleaned, family = "binomial")

broom::tidy(model, exponentiate = TRUE)

# Stratified regression, only tunnels

traffic_data_cleaned_only_tunnel <- traffic_data_cleaned |> 
  filter(stedsforhold == "Tunnel (primært for motorkjøretøy)")

model_only_tunnel <- glm(ulykkestype ~ fartsgrense +  vegbredde, data = traffic_data_cleaned_only_tunnel, family = "binomial")

broom::tidy(model_only_tunnel, exponentiate = TRUE)

# Stratified regression, excluded tunnels

traffic_data_cleaned_not_tunnel <- traffic_data_cleaned |> 
  filter(stedsforhold != "Tunnel (primært for motorkjøretøy)")

model_not_tunnel <- glm(ulykkestype ~ fartsgrense +  vegbredde, data = traffic_data_cleaned_not_tunnel, family = "binomial")

broom::tidy(model_not_tunnel, exponentiate = TRUE)