library(data.table)

source(file.path(getwd(),'src','helper_functions.R'))
max_interval <- c("20:30:00", "21:00:00", "21:30:00", "22:00:00", "22:30:00", "23:00:00", "23:30:00")
## Function to determine previous file
#prev_date <- function(x) format(7 * floor(as.numeric(x-8+4) / 7) + as.Date(1-4,origin = "1970-01-01"), "%y%m%d")
prev_date <- function(x) format(x-7, "%y%m%d")

raw_data_path <- file.path(getwd(), "data", "raw_data")
raw_data_list <- list.files(raw_data_path)[grepl("(?=.*turnstile)(?=.*txt)", list.files(raw_data_path), perl =TRUE)]
raw_data_list <- raw_data_list[order(raw_data_list)]
processed_data_path <- file.path(getwd(), "data", "processed")
processed_data_list <- list.files(processed_data_path)[grepl("(?=.*processed)(?=.*csv)", list.files(processed_data_path), perl =TRUE)]

unprocessed_list <- raw_data_list[!(substring(raw_data_list,11,16) %in% substring(processed_data_list, 1,6))]
unprocessed_list <- unprocessed_list[order(unprocessed_list)]
  
for (file_name in unprocessed_list) {
  prev_file_name <- paste(as.character(prev_date(as.Date(substring(file_name,11,16),"%y%m%d"))),"_processed_data.csv", sep='')
  prev_file_path <- file.path(getwd(),"data","processed",prev_file_name)
  if (file.exists(prev_file_path)) {
    prev_data <- fread(prev_file_path)
    last_reading <- prev_data[DATE==max(prev_data[,DATE])][INTERVAL %in% max_interval]
    last_reading <- format_data(file_name, last_reading)
  } else {
    print(paste("Previous File:", prev_file_name, "not found.", sep = ' '))
  }
}