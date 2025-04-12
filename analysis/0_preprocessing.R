library(jsonlite)
library(progress)

# path <- "C:/Users/dmm56/Box/Data/DoggoNogoValidation"
path <- "C:/Users/domma/Box/Data/DoggoNogoValidation"
# path <- "C:/Users/Benjamin Tribe/Box/DoggoNogoValidation"



# JsPsych experiment ------------------------------------------------------

files <- list.files(path, pattern = "*.csv")
# files <- files[!files %in% "Experiment_zg2w0dwcv7.csv"] # temporary fix for dodgy pilot - DELETE

# Progress bar
progbar <- progress_bar$new(total = length(files))

alldata <- data.frame()
alldata_rt <- data.frame()
for (file in files) {
  progbar$tick()

  rawdata <- read.csv(paste0(path, "/", file))
  # unique(rawdata$screen)


  # Initialize participant-level data
  dat <- rawdata[rawdata$screen == "browser_info",]

  if (!dat$researcher %in% c("SONA")) {
    next
  }

  data_ppt <- data.frame(Participant = dat$participantID,
                         Recruitment = dat$researcher,
                         Condition = dat$condition,
                         Experiment_StartDate = as.POSIXct(paste(dat$date, dat$time), format = "%d/%m/%Y %H:%M:%S"),
                         Experiment_Duration = rawdata[rawdata$screen == "debriefing", "time_elapsed"] / 1000 / 60,
                         SimpleRT_start = rawdata[rawdata$screen %in% c("SimpleRT_fixation", "tooFastMessage", "SimpleRT_stimulus", "SimpleRT_breakStop", "SimpleRT_break"), ]$time_elapsed[1],
                         SimpleRT_end = rawdata[rawdata$screen %in% c("SimpleRT_fixation", "tooFastMessage", "SimpleRT_stimulus", "SimpleRT_breakStop", "SimpleRT_break"), ]$time_elapsed[nrow(rawdata[rawdata$screen %in% c("SimpleRT_fixation", "tooFastMessage", "SimpleRT_stimulus", "SimpleRT_breakStop", "SimpleRT_break"), ])],
                         Browser_Version = paste(dat$browser, dat$browser_version),
                         Mobile = dat$mobile,
                         Platform = dat$os,
                         Screen_Width = dat$screen_width,
                         Screen_Height = dat$screen_height,
                         Refresh_Rate = dat$vsync_rate)

  # Demographics
  demog <- unlist(lapply(
    jsonlite::fromJSON(rawdata[rawdata$screen == "demographic_questions",]$response, simplifyDataFrame = FALSE),
    function(x) if (is.null(x)) NA else x))
  demog <- as.data.frame(t(demog))
  demog$GenderOther <- NULL
  demog$Gender <- ifelse(demog$Gender == "other", "Other", demog$Gender)
  demog$Education <- ifelse(demog$Education == "other", "Other", demog$Education)
  data_ppt <- cbind(data_ppt, demog)


  # RPM
  if ("ravens_trial" %in% rawdata$screen){
    rpm <- rawdata[rawdata$screen == "ravens_trial", ]
    rpm$item <- paste0("RPM_", rpm$item)
    rpm$error <- ifelse(rpm$error == "false", 1, 0) # recoding error var to 1 = correct, 0 = incorrect
    data_ppt <- cbind(data_ppt,
                      t(setNames(rpm$error, paste0(rpm$item, "_Error"))),
                      t(setNames(as.numeric(rpm$rt) / 1000, paste0(rpm$item, "_RT"))))
  }

  # Feedback
  feedback <- lapply(jsonlite::fromJSON(rawdata[rawdata$screen == "experiment_feedback", "response"]), function(x) if (is.null(x)) NA else x)
  data_ppt$Experiment_Enjoyment <- feedback$Feedback_Enjoyment
  data_ppt$Experiment_Feedback <- feedback$Feedback_Text

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
                        RT = as.numeric(ifelse(dat$rt == "null", NA, dat$rt)) / 1000,
                        ISI = rawdata[as.numeric(rownames(dat))-2, "trial_duration"] / 1000,
                        Stimulus_Size = as.numeric(gsub(".*width: (.*)px; opa.*", "\\1", dat$stimulus)),
                        Stimulus_X = as.numeric(gsub(".*left: (.*)px; top.*", "\\1", dat$stimulus)),
                        Stimulus_Y = as.numeric(gsub(".*top: (.*)px; width.*", "\\1", dat$stimulus)))


  # Merge everything
  if (!(nrow(alldata) == 0)){
    all_cols <- union(names(alldata), names(data_ppt))
    alldata[setdiff(all_cols, names(alldata))] <- NA
    data_ppt[setdiff(all_cols, names(data_ppt))] <- NA
  }
  alldata <- rbind(alldata, data_ppt)
  alldata_rt <- rbind(alldata_rt, data_rt)
}


# DoggoNogo Data ----------------------------------------------------------
files <- list.files(path, pattern = "*.json")

# Progress bar
progbar <- progress_bar$new(total = length(files))

alldata_dog <- data.frame()
alldata_dogRT <- data.frame()
for (file in files) {
  progbar$tick()

  dog <- jsonlite::read_json(paste0(path, "/", file))
  if (!dog$metadata$participantName %in% alldata$Participant) {
    next
  }

  dog_ppt <- data.frame(Participant = dog$metadata$participantName,
                        DoggoNogo_ID = dog$metadata$sessionID, # UNCOMMENT
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
                       ISI = dat$isi,
                       Response_Type = dat$responseType,
                       Trial_Score = dat$trialScore,
                       Total_Score = dat$totalScore,
                       Threshold = dat$threshold,
                       Valid_Trial = dat$validTrial,
                       Valid_Trial_Count = dat$validTrialCount,
                       Stimulus_Size = dat$stimulusScale,
                       Stimulus_X = dat$stimulusX,
                       Stimulus_Y = dat$stimulusY,
                       Stimulus_Orientation = dat$stimulusOrientation
                       )

  # Merge
  alldata_dog <- rbind(alldata_dog, dog_ppt)
  alldata_dogRT <- rbind(alldata_dogRT, dog_l1)

}



# Remove incomplete -------------------------------------------------------

incomplete <- setdiff(alldata$Participant, alldata_dog$Participant)

alldata <- alldata[!alldata$Participant %in% incomplete,]
alldata_rt <- alldata_rt[!alldata_rt$Participant %in% incomplete,]
alldata <- merge(alldata, alldata_dog, by="Participant")

# Award -------------------------------------------------------------------
# alldata[, c("Participant", "Gender", "Age", "Experiment_StartDate", "Experiment_Duration")]


# Anonymize ---------------------------------------------------------------
# Generate IDs
ids <- paste0("S", format(sprintf("%03d", 1:(nrow(alldata)))))
# Sort Participant according to date and assign new IDs
names(ids) <- alldata$Participant[order(alldata$Experiment_StartDate)]
# Replace IDs
alldata$Participant <- ids[alldata$Participant]
alldata_rt$Participant <- ids[alldata_rt$Participant]
alldata_dogRT$Participant <- ids[alldata_dogRT$Participant]


# Save --------------------------------------------------------------------

write.csv(alldata, "../data/rawdata_participants.csv", row.names = FALSE)
write.csv(alldata_rt, "../data/rawdata_simpleRT.csv", row.names = FALSE)
write.csv(alldata_dogRT, "../data/rawdata_doggonogo.csv", row.names = FALSE)

