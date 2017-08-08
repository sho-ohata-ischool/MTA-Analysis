library(data.table)

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
      setnames(all,"C.A","C/A")
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
