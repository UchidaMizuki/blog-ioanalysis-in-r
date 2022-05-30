library(tidyverse)
library(jpstat)

appId <- keyring::key_get("estat-api")

# iotable_ja, 13 sectors, 2011
iotable_ja <- estat(appId, "https://www.e-stat.go.jp/dbview?sid=0003119272")
iotable_ja <- iotable_ja |>
  activate(tab) |>
  # unit: 1 million yen

  select() |>

  activate(cat01) |>
  rekey("output") |>
  select(name) |>

  activate(cat02) |>
  rekey("input") |>
  select(name) |>

  collect("value_M")

iotable_ja <- iotable_ja |>
  filter(!input_name %in% c("70_内生部門計",
                            "96_粗付加価値部門計",
                            "97_国内生産額"),
         !output_name %in% c("70_内生部門計",
                             "78_国内最終需要計",
                             "79_国内需要合計",
                             "82_最終需要計",
                             "83_需要合計",
                             "87_（控除）輸入計",
                             "88_最終需要部門計",
                             "97_国内生産額")) |>
  mutate(input_type = case_when(str_starts(input_name, "[01]") ~ "industry",
                                str_starts(input_name, "[79]") ~ "valueadded"),
         output_type = case_when(str_starts(output_name, "[01]") ~ "industry",
                                 str_starts(output_name, "7") ~ "finaldemand",
                                 str_starts(output_name, "81") ~ "export",
                                 str_starts(output_name, "8[4-6]") ~ "import"),
         value = parse_number(value_M) * 1e6) |>
  select(!value_M) |>
  relocate(input_type, input_name, output_type, output_name)

input_name <- iotable_ja |>
  distinct(input_name) |>
  add_column(input_name_to = c("01_Agriculture,forestry and fishery",
                               "02_Mining",
                               "03_Manufacturing",
                               "04_Construction",
                               "05_Electricity,gas and water supply",
                               "06_Commerce",
                               "07_Finance and insurance",
                               "08_Real estate",
                               "09_Transport and postal services",
                               "10_Information and communication",
                               "11_Public administration",
                               "12_Services",
                               "13_Activities not elsewhere classified",

                               "71_Consumption expenditure outside households (row)",
                               "91_Compensation of employees",
                               "92_Operating surplus",
                               "93_Consumption of fixed capital",
                               "94_Indirect taxes",
                               "95_(less) Current subsidies"))

output_name <- iotable_ja |>
  distinct(output_name) |>
  add_column(output_name_to = c("01_Agriculture,forestry and fishery",
                                "02_Mining",
                                "03_Manufacturing",
                                "04_Construction",
                                "05_Electricity,gas and water supply",
                                "06_Commerce",
                                "07_Finance and insurance",
                                "08_Real estate",
                                "09_Transport and postal services",
                                "10_Information and communication",
                                "11_Public administration",
                                "12_Services",
                                "13_Activities not elsewhere classified",

                                "71_Consumption expenditure outside households (column)",
                                "72_Consumption expenditure (private)",
                                "73_Consumption expenditure of general government",
                                "74_Gross domestic fixed capital formation",
                                "76_Increase in stocks",
                                "77_Balancing sector",
                                "81_Exports total",
                                "84_(less) Imports",
                                "85_(less) Custom duties",
                                "86_(less) Commodity taxes on imported goods"))

iotable <- iotable_ja |>
  left_join(input_name,
            by = "input_name") |>
  left_join(output_name,
            by = "output_name") |>
  select(!c(input_name, output_name)) |>
  rename(input_name = input_name_to,
         output_name = output_name_to) |>
  relocate(input_type, input_name, output_type, output_name)

iotable_wider <- iotable |>
  unite("input", input_type, input_name,
        sep = "/") |>
  unite("output", output_type, output_name,
        sep = "/") |>
  pivot_wider(names_from = output,
              values_from = value)

iotable_wider_ja <- iotable_ja |>
  unite("input", input_type, input_name,
        sep = "/") |>
  unite("output", output_type, output_name,
        sep = "/") |>
  pivot_wider(names_from = output,
              values_from = value)

write_excel_csv(iotable, "iotable.csv")
write_excel_csv(iotable_wider, "iotable_wider.csv",
                na = "")
write_excel_csv(iotable_ja, "iotable_ja.csv")
write_excel_csv(iotable_wider_ja, "iotable_wider_ja.csv",
                na = "")
