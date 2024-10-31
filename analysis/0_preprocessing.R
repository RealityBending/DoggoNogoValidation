library(tidyverse)
library(easystats)
library(jsonlite)

path <- "C:/Users/dmm56/Box/Data/DoggoNogoValidation"
path <- "C:/Users/domma/Box/Data/DoggoNogoValidation"



# JsPsych experiment ------------------------------------------------------

files <- list.files(path, pattern = "*.csv")

alldata <- data.frame()
alldata_rt <- data.frame()
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


# DoggoNogo Data ----------------------------------------------------------
files <- list.files(path, pattern = "*.json")

alldata_dog <- data.frame()
for (file in files) {
  dog <- jsonlite::read_json(paste0(path, "/", file))

  dog_ppt <- data.frame(Participant = dog$metadata$participantName,
                        DoggoNogo_ID = dog$metadata$randomID,
                        DoggoNogo_Study = dog$metadata$studyName,
                        DoggoNogo_Start = dog$metadata$start,
                        DoggoNogo_End = dog$metadata$end,
                        DoggoNogo_Level1_N = dog$metadata$l1n,
                        DoggoNogo_L1_Start = dog$metadata$startL1,
                        DoggoNogo_L1_End = dog$metadata$endL1
  )


  dog_l1 <- do.call(rbind, lapply(dog$level1, as.data.frame))
  dog_l1
}


# Quick Check
# library(tidyverse)
#
# cumulative_median <- function(x) {
#   sapply(seq_along(x), function(i) median(x[1:i], na.rm=TRUE))
# }
#
# dog_l1 |>
#   mutate(rt = ifelse(responseType %in% c("early"), NA, rt)) |>
#   mutate(medianRT = c(NA, cumulative_median(rt)[1:(length(rt)-1)])) |>
#   select(trialNumber, responseType, rt, threshold, medianRT) |>
#   ggplot(aes(x=trialNumber)) +
#   geom_line(aes(y=threshold), color="black") +
#   geom_line(aes(y=medianRT), color="blue")


# Anonymize ---------------------------------------------------------------




# Save --------------------------------------------------------------------

write.csv(alldata, "../data/rawdata.csv", row.names = FALSE)

