library(data.table)

source(file.path(getwd(),'src','helper_functions.R'))

## Function to determine previous file
prev_date <- function(x) format(7 * floor(as.numeric(x-8+4) / 7) + as.Date(1-4,origin = "1970-01-01"), "%y%m%d")

raw_data_list <- list.files(file.path(getwd(), "data", "raw_data"))
processed_data_list <- list.files(file.path(getwd(), "data", "processed"))

raw_data_list <- raw_data_list[!(substring(raw_data_list,11,16) %in% substring(processed_data_list, 1,6))]
raw_data_list <- raw_data_list[order(raw_data_list)]
  
for (file_name in raw_data_list) {
  prev_file_name <- paste(as.character(prev_date(file_name[11:16])),"_processed_data.csv", sep='')
  prev_file_path <- file.path(getwd(),"data","raw_data",prev_file_name)
  if (file.exists(prev_file_path)) {
    prev_data <- fread(prev_file_path)
    last_reading <- prev_data[DATE==max(all[,DATE])][TIME %in% max_interval]
    last_reading <- format_data(file_name, last_reading)
  } else {
    print(paste("Previous File:", prev_file_name, "not found.", sep = ' '))
  }
}