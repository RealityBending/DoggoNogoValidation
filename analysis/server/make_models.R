# Fit model with 16 chains per task

library(brms)
library(cmdstanr)
library(cogmod)

options(brms.backend = "cmdstanr")

# Get array task ID from Slurm
task_id <- as.numeric(commandArgs(trailingOnly = TRUE)[1])

# Number of chains per task from Slurm (fixed at 16)
chains_per_task <- as.numeric(Sys.getenv("SLURM_CPUS_PER_TASK"))

# Calculate starting chain ID
start_chain <- (task_id - 1) * chains_per_task + 1

iter <- 1200 # 50% of that is warmup

# Test --------------------------------------------------------------------

# model <- brm(
#   formula = mpg ~ wt,
#   data = mtcars,
#   family = gaussian(),
#   chains = chains_per_task,    # 16 chains per task
#   cores = chains_per_task,     # Use all 16 CPUs
#   iter = 500,
#   seed = 1234 + start_chain,   # Unique seed per task
#   file = paste0("./modeltoy_task_", task_id, ".rds")
# )



# Sample 1 ----------------------------------------------------------------

df_simpleRT <- read.csv("https://github.com/RealityBending/DoggoNogoValidation/blob/main/data/data_simpleRT.csv")
df_dog <- read.csv("https://github.com/RealityBending/DoggoNogoValidation/blob/main/data/data_doggonogo.csv")



print("===== Gaussian =====")
print(Sys.time())

f <- bf(
  RT ~ 0 + Intercept + poly(ISI, 2) + (0 + Intercept + poly(ISI, 2) | Participant)
)

model <- brm(
  formula = f,
  data = df_simpleRT,
  family = gaussian(),
  init = 0,
  chains = chains_per_task,    # 16 chains per task
  cores = chains_per_task,     # Use all 16 CPUs
  iter = iter,  # Number of iterations and warmup must be equal (warmup is 50% iter)
  seed = 1234 + start_chain,   # Unique seed per task
  file = paste0("./gaussian_simpleRT_task_", task_id, ".rds")
)

model <- brm(
  formula = f,
  data = df_dog,
  family = gaussian(),
  init = 0,
  chains = chains_per_task,    # 16 chains per task
  cores = chains_per_task,     # Use all 16 CPUs
  iter = iter,  # Number of iterations and warmup must be equal (warmup is 50% iter)
  seed = 1234 + start_chain,   # Unique seed per task
  file = paste0("./gaussian_DoggoNogo_task_", task_id, ".rds")
)



print("===== ExGaussian =====")
print(Sys.time())

f <- bf(
  RT ~ 0 + Intercept + poly(ISI, 2) + (0 + Intercept + poly(ISI, 2) | Participant),
  sigma ~ 0 + Intercept + poly(ISI, 2) + (0 + Intercept + poly(ISI, 2) | Participant),
  beta ~ 0 + Intercept + poly(ISI, 2) + (0 + Intercept + poly(ISI, 2) | Participant),
  family = exgaussian(link_sigma = "softplus", link_beta = "softplus")
)

model <- brm(
  formula = f,
  data = df_simpleRT,
  init = 0,
  chains = chains_per_task,    # 16 chains per task
  cores = chains_per_task,     # Use all 16 CPUs
  iter = iter,  # Number of iterations and warmup must be equal (warmup is 50% iter)
  seed = 1234 + start_chain,   # Unique seed per task
  file = paste0("./exgaussian_simpleRT_task_", task_id, ".rds")
)

model <- brm(
  formula = f,
  data = df_dog,
  init = 0,
  chains = chains_per_task,    # 16 chains per task
  cores = chains_per_task,     # Use all 16 CPUs
  iter = iter,  # Number of iterations and warmup must be equal (warmup is 50% iter)
  seed = 1234 + start_chain,   # Unique seed per task
  file = paste0("./exgaussian_DoggoNogo_task_", task_id, ".rds")
)
