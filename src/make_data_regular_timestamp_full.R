## Script to create each interval entries and exits for all files
## Script will pick-up and read all files that are placed in the /data/raw_data folder

library(data.table)

starts <- c(4, 9, 14, 19, 24, 29, 34, 39) ## values used to re-format pre 10/12/14 files
interval <- c("00:00:00", "00:30:00", "01:00:00", "01:30:00", "02:00:00", "02:30:00", "03:00:00", "03:30:00", "04:00:00", "04:30:00",
              "05:00:00", "05:30:00", "06:00:00", "06:30:00", "07:00:00", "07:30:00", "08:00:00", "08:30:00", "09:00:00", "09:30:00",
              "10:00:00", "10:30:00", "11:00:00", "11:30:00", "12:00:00", "12:30:00", "13:00:00", "13:30:00", "14:00:00", "14:30:00",
              "15:00:00", "15:30:00", "16:00:00", "16:30:00", "17:00:00", "17:30:00", "18:00:00", "18:30:00", "19:00:00", "19:30:00",
              "20:00:00", "20:30:00", "21:00:00", "21:30:00", "22:00:00", "22:30:00", "23:00:00", "23:30:00")
max_interval <- c("20:30:00", "21:00:00", "21:30:00", "22:00:00", "22:30:00", "23:00:00", "23:30:00")

format_data <- function(file_name, last_reading=NULL) {
  file_path <- file.path(getwd(),"data","raw_data",file_name)
  if (as.Date(substring(file_name, 11,16),"%y%m%d") < as.Date("141012", "%y%m%d")) { ##data format changes at 10/12/2014
    dt <- read.csv(file_path, header=FALSE)
    
    ## This section collapses the unusual data format and turns it into a format that makes it easier to process 
    dt <- apply(dt, 1, paste, collapse=",")
    all <- rbindlist(lapply(strsplit(dt, ","), function(x) {
      rbindlist(lapply(starts, function(y) {
        as.list(x[c(1:3, y:(y+4))]) }))
    })) 
    
    setnames(all, colnames(all), c("C.A", "UNIT", "SCP", "DATE",  "TIME","DESC", "ENTRIES", "EXITS"))  
    all[,DATE:=format(as.Date(DATE,format="%m-%d-%y"),"%m/%d/%Y")]
  }  
  else {
    all <- try(fread(file_path), silent = TRUE) ##handle files with missing data with read.csv instead
    if("try-error" %in% class(all)) {
        all <- data.table(read.csv(file_path, header = TRUE))
      } 
    all <- all[, c("C/A", "UNIT", "SCP", "DATE",  "TIME","DESC", "ENTRIES", "EXITS")]
  }
  all <- all[ENTRIES!="NA"][!is.na(ENTRIES)]
  
  ## reformat char to numeric and dates
  all[,`:=`(ENTRIES=as.numeric(ENTRIES), EXITS=as.numeric(EXITS), DATE=as.Date(DATE,format="%m/%d/%Y"))]
  all <- unique(all[,c("UNIT", "SCP", "DATE", "TIME", "ENTRIES", "EXITS")])[TIME %in% interval] ## Take unique in case there are duplicate readings
  if (!missing("last_reading")) { 
    all <- rbind(last_reading, all)
  }
  ## last regular reading of the file
  last_reading <- all[DATE==max(all[,DATE])][TIME %in% max_interval]
  
  all<-all[order(UNIT,SCP,DATE,TIME)]
  ## Take difference between rows next to each other and group by UNIT and SCP
  all[,`:=`(Diff1=c(NA,diff(ENTRIES)),Diff2=c(NA,diff(EXITS))),by=.(UNIT,SCP)][,TIME_SHIFT:=shift(TIME,1)] 
  all<-all[!is.na(TIME_SHIFT)] ## remove rows with NA
  all[,INTERVAL:=paste(TIME_SHIFT,TIME,sep='-')] ## Interval indication
  all[,`:=`(TIME_SHIFT=NULL, TIME=NULL)]
  
  ##get max first in case of duplicate, and then sum for total entrance by station
  all <- all[,.(ENTRIES=max(Diff1), EXITS=max(Diff2)),by=.(UNIT,SCP,DATE,INTERVAL)][,.(ENTRIES=sum(ENTRIES),EXITS=sum(EXITS),METER_COUNT=.N), by=.(UNIT,DATE,INTERVAL)] 
  processed_data_path <- file.path(getwd(), "data", "processed", paste(substring(file_name, 11,16), "_processed_data.csv", sep=''))
  write.csv(all, processed_data_path, row.names=FALSE, quote = FALSE)
  return(last_reading) ## return last_reading for next file
}

raw_data_path <- file.path(getwd(),"data","raw_data")
file_list <- list.files(raw_data_path)[grepl("(?=.*turnstile)(?=.*txt)", list.files(raw_data_path), perl =TRUE)]
file_list <- file_list[order(file_list)]

last_reading <- format_data(file_list[1]) ## for first file process and create data of last reading

for (file_name in file_list[2:length(file_list)]){
  last_reading <- format_data(file_name, last_reading)
  print(paste("Finished file:", file_name))
}
