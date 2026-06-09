library(brms)
library(cmdstanr)
library(rstan)
library(loo)


# Get the number of cores and task ID from the environment variables
options(mc.cores = as.numeric(Sys.getenv("SLURM_CPUS_PER_TASK")))
task_id <- as.numeric(Sys.getenv("SLURM_ARRAY_TASK_ID"))


# model_names <- c("sample1_zoib", "sample1_betagate", "sample1_choco")
model_names <- c("sample1_chocoattractiveness", "sample1_chocobeauty")
model_name <- model_names[task_id]

combine_and_save <- function(name) {
  print(paste0(name, ": ", Sys.time()))
  files <- list.files(".", pattern = paste0(name, '_.*rds$'), full.names = TRUE)
  m <- brms::combine_models(mlist = lapply(files, readRDS))

  # Add criterion and save
  # set.seed(1)
  # dat <- insight::get_data(m)
  # dat <- dat[sample(1:nrow(dat), 100), ]
  m <- brms::add_criterion(m, "waic", ndraws = 1500, file = name)

  # saveRDS(m, paste0(name, ".rds"))
}

combine_and_save(model_name)
print(paste0("Completed: ", Sys.time()))
