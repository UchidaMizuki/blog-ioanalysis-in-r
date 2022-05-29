library(tidyverse)

iotable_wider <- read_csv("iotable_wider.csv",
                          col_types = cols(.default = "c"))

iotable <- iotable_wider |>
  separate(input, c("input_type", "input_name"),
           sep = "/") |>
  pivot_longer(!c(input_type, input_name),
               names_to = c("output_type", "output_name"),
               names_sep = "/",
               values_to = "value",
               values_transform = list(value = parse_number))

iotable
