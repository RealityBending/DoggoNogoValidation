library(tidyverse)
library(easystats)
library(jsonlite)

path <- "C:/Users/dmm56/Box/Data/DoggoNogoValidation"

files <- list.files(path, pattern = "*.csv")

alldata <- data.frame()
for (file in files) {
  rawdata <- read.csv(paste0(path, "/", file))
  data_ppt <- data.frame(Participant = file)

  # Post-task questionnaires
  dat <- rawdata[rawdata$screen == "task_postquestionnaire",]
  responses <- as.data.frame(jsonlite::fromJSON(dat$response))
  data_ppt <- cbind(data_ppt, responses)

  # Merge everything
  alldata <- rbind(alldata, data_ppt)
}


write.csv(alldata, "../data/rawdata.csv", row.names = FALSE)
