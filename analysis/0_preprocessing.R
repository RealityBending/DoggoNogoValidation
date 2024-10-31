library(tidyverse)
library(easystats)
library(jsonlite)

# path <- "C:/Users/dmm56/Box/Data/DoggoNogoValidation"
path <- "C:/Users/domma/Box/Data/DoggoNogoValidation"



# JsPsych experiment ------------------------------------------------------

files <- list.files(path, pattern = "*.csv")

alldata <- data.frame()
alldata_rt <- data.frame()
for (file in files) {
  rawdata <- read.csv(paste0(path, "/", file))
  # unique(rawdata$screen)

  # Initialize participant-level data
  dat <- rawdata[rawdata$screen == "browser_info",]

  data_ppt <- data.frame(Participant = dat$participantID,
                         Recruitment = dat$researcher,
                         Condition = dat$condition)  # TODO: add info



  # Demographics
  # TODO.

  # Post-task questionnaires
  dat <- rawdata[rawdata$screen == "task_assessment",]
  if (data_ppt$Condition == "DoggoFirst") {
    dat_doggo <- as.data.frame(jsonlite::fromJSON(dat$response[1]))
    dat_simple <- as.data.frame(jsonlite::fromJSON(dat$response[2]))
  } else {
    dat_doggo <- as.data.frame(jsonlite::fromJSON(dat$response[2]))
    dat_simple <- as.data.frame(jsonlite::fromJSON(dat$response[1]))
  }
  data_ppt$Assessment_Enjoyment_DoggoNogo <- dat_doggo$TaskFeedback_Enjoyment
  data_ppt$Assessment_Enjoyment_Simple <- dat_simple$TaskFeedback_Enjoyment
  data_ppt$Assessment_Duration_DoggoNogo <- dat_doggo$TaskFeedback_Duration
  data_ppt$Assessment_Duration_Simple <- dat_simple$TaskFeedback_Duration
  data_ppt$Assessment_Repeat_DoggoNogo <- dat_doggo$TaskFeedback_Repeat
  data_ppt$Assessment_Repeat_Simple <- dat_simple$TaskFeedback_Repeat

  # Simple reaction time task
  dat <- rawdata[rawdata$screen == "SimpleRT_stimulus",]

  data_rt <- data.frame(Participant=data_ppt$Participant,
                        Trial = 1:nrow(dat),
                        RT = dat$rt,
                        ISI = rawdata[as.numeric(rownames(dat))-2, "trial_duration"],
                        Stimulus_Size = as.numeric(gsub(".*width: (.*)px; opa.*", "\\1", dat$stimulus)))

  # Merge everything
  alldata <- rbind(alldata, data_ppt)
  alldata_rt <- rbind(alldata_rt, data_rt)
}


# DoggoNogo Data ----------------------------------------------------------
files <- list.files(path, pattern = "*.json")

alldata_dog <- data.frame()
alldata_dogRT <- data.frame()
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


  dat <- do.call(rbind, lapply(dog$level1, as.data.frame))
  dog_l1 <- data.frame(Participant = dog_ppt$Participant,
                       RT = dat$rt,
                       ISI = dat$isi)  # TODO: add rest

  # Merge
  alldata_dog <- rbind(alldata_dog, dog_ppt)
  alldata_dogRT <- rbind(alldata_dogRT, dog_l1)


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

}
alldata <- merge(alldata, alldata_dog, by="Participant")


# Award -------------------------------------------------------------------



# Anonymize ---------------------------------------------------------------




# Save --------------------------------------------------------------------

write.csv(alldata, "../data/rawdata_participants.csv", row.names = FALSE)
write.csv(alldata_rt, "../data/rawdata_simple.csv", row.names = FALSE)
write.csv(alldata_dog, "../data/rawdata_doggonogo.csv", row.names = FALSE)

