## Script to create each interval entries and exits for all files
## Script will pick-up and read all files that are placed in the /data/raw_data folder

library(data.table)
source(file.path(getwd(),'src','helper_functions.R'))

starts <- c(4, 9, 14, 19, 24, 29, 34, 39) ## values used to re-format pre 10/12/14 files
interval <- c("00:00:00", "00:30:00", "01:00:00", "01:30:00", "02:00:00", "02:30:00", "03:00:00", "03:30:00", "04:00:00", "04:30:00",
              "05:00:00", "05:30:00", "06:00:00", "06:30:00", "07:00:00", "07:30:00", "08:00:00", "08:30:00", "09:00:00", "09:30:00",
              "10:00:00", "10:30:00", "11:00:00", "11:30:00", "12:00:00", "12:30:00", "13:00:00", "13:30:00", "14:00:00", "14:30:00",
              "15:00:00", "15:30:00", "16:00:00", "16:30:00", "17:00:00", "17:30:00", "18:00:00", "18:30:00", "19:00:00", "19:30:00",
              "20:00:00", "20:30:00", "21:00:00", "21:30:00", "22:00:00", "22:30:00", "23:00:00", "23:30:00")
max_interval <- c("20:30:00", "21:00:00", "21:30:00", "22:00:00", "22:30:00", "23:00:00", "23:30:00")

raw_data_path <- file.path(getwd(),"data","raw_data")
file_list <- list.files(raw_data_path)[grepl("(?=.*turnstile)(?=.*txt)", list.files(raw_data_path), perl =TRUE)]
file_list <- file_list[order(file_list)]

last_reading <- format_data(file_list[1]) ## for first file process and create data of last reading

for (file_name in file_list[2:length(file_list)]){
  last_reading <- format_data(file_name, last_reading)
  print(paste("Finished file:", file_name))
}
