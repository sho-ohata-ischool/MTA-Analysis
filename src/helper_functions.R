library(data.table)

format_data <- function(station_names, file_name) {
  
  if (as.Date(substring(file_name, 11,16),"%y%m%d") < as.Date("141012", "%y%m%d")) {
    file_name <- file.path(getwd(),"data","raw_data",file_name)
    dt <- read.csv(file_name, header=FALSE)
    dt <- subset(dt, V2 %in% station_names)
    dt <- apply(dt, 1, paste, collapse=",")
    
    all <- rbindlist(lapply(strsplit(dt, ","), function(x) {
      rbindlist(lapply(starts, function(y) {
        as.list(x[c(1:3, y:(y+4))]) }))
    })) 
    setnames(all, colnames(all), c("C.A", "UNIT", "SCP", "DATE",  "TIME","DESC", "ENTRIES", "EXITS"))  
    all[,DATE:=format(as.Date(DATE,format="%m-%d-%y"),"%m/%d/%Y")]
  }  
  else {
    file_name <- file.path(getwd(),"data","raw_data",file_name)
    all <- fread(file_name)
    all <- all[UNIT %in% station_names] 
    all <- all[, c("C/A", "UNIT", "SCP", "DATE",  "TIME","DESC", "ENTRIES", "EXITS")]
  }
  
  all <- all[ENTRIES!="NA"][!is.na(ENTRIES)]
  
  all[,`:=`(ENTRIES=as.numeric(ENTRIES), EXITS=as.numeric(EXITS))]
  all <- unique(all[,c("UNIT", "SCP", "DATE", "TIME", "ENTRIES", "EXITS")])[TIME %in% interval]
  all <- all[,`:=`(Diff1=diff(ENTRIES),Diff2=diff(EXITS),INTERVAL=paste(TIME,collapse="-")),by=.(UNIT,SCP,DATE)][!is.na(Diff1)]
  all <- all[,.(ENTRIES=max(Diff1), EXITS=max(Diff2)),by=.(UNIT,SCP,DATE,INTERVAL)][,.(ENTRIES=sum(ENTRIES),EXITS=sum(EXITS),METER_COUNT=.N), by=.(UNIT,DATE,INTERVAL)] ##get max in case of duplicate and then sum
  return(all)
}