library(tidyverse)

# 02_finaldemand_change ---------------------------------------------------

finaldemand_change <- function(file) {
  file |>
    read_csv(col_types = cols(.default = "c",
                              value_M = "n")) |>
    filter(input_type == "industry") |>
    distinct(input_type, input_name) |>
    add_column(value_M = 0)
}

finaldemand_change_13sector_ja <- finaldemand_change("iotable_13sector_2011_ja.csv")
finaldemand_change_13sector <- finaldemand_change("iotable_13sector_2011.csv")
finaldemand_change_3sector <- finaldemand_change("iotable_3sector_2011.csv")

write_excel_csv(finaldemand_change_13sector_ja, "finaldemand_change_13sector_ja.csv")
write_excel_csv(finaldemand_change_13sector, "finaldemand_change_13sector.csv")
write_excel_csv(finaldemand_change_3sector, "finaldemand_change_3sector.csv")
