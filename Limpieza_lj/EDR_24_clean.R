library(foreign)
library(janitor)
library(dplyr)
library(readr)

dir23 <- "C:/Users/ramir/OneDrive/Documents/Luis/Trabajo/Data_Cívica/Segundo Ejercicio/2023EDR"
dir24 <- "C:/Users/ramir/OneDrive/Documents/Luis/Trabajo/Data_Cívica/Segundo Ejercicio/2024EDR"

path_defun23 <- file.path(dir23, "DEFUN23.dbf")
path_defun24 <- file.path(dir24, "DEFUN24.dbf")

stopifnot(file.exists(path_defun23), file.exists(path_defun24))

pres_homicidios <- function(path_defun, year) {
  df <- foreign::read.dbf(path_defun, as.is = TRUE) |>
    janitor::clean_names() |>
    mutate(
      anio = year,
      tipo_defun = suppressWarnings(as.integer(tipo_defun))
    ) |>
    filter(!is.na(tipo_defun) & tipo_defun == 2)
  
  df 
}

hom_2023 <- pres_homicidios(path_defun23, 2023)
hom_2024 <- pres_homicidios(path_defun24, 2024)


common_cols <- intersect(names(hom_2023), names(hom_2024))

homicidios_2023_2024 <- bind_rows(
  hom_2023 |> select(all_of(common_cols)),
  hom_2024 |> select(all_of(common_cols))
)

dir.create("data", showWarnings = FALSE)
saveRDS(homicidios_2023_2024, "data/homicidios_23_24_min.rds")
write_csv(homicidios_2023_2024, "data/homicidios_23_24_min.csv")

cat("Homicidios 2023:", nrow(hom_2023), "\n")
cat("Homicidios 2024:", nrow(hom_2024), "\n")
cat("Total unidos:", nrow(homicidios_2023_2024), "\n")