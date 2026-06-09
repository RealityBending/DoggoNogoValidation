# Storage Locations

- `/mnt/lustre/scratch/psych/dmm56/`  (fast storage)
- `/mnt/lustre/users/psych/dmm56/`  (long-term storage)
- `/mnt/nfs2/psych/dmm56/` (home directory)

# ARTEMIS

- Open GlobalProtect VPN
  - portal: `bond.sussex.ac.uk`
  - username: `dmm56`
  - password: sussex pwd followed by auth code (app)
- Help: https://artemis-docs.hpc.sussex.ac.uk/artemis/
- Go to Open OnDemand (OOD): https://ood.artemis.hrc.sussex.ac.uk/
  - username: `dmm56`
  - password: sussex pwd
- Jobs -> Jobs Composer
- From specified path: 
  - `/mnt/lustre/users/psych/dmm56/FictionChoco/`
  - `/mnt/lustre/scratch/psych/dmm56/FictionChoco/`
  - File: `run.slurm`
- To install a package:
  - Clusters -> Artemis Shell Access
  - Pwd
  - `module load R/4.4.1-gfbf-2023b`
  - `R` (to open R)
  - `install.packages("package_name")` (to install a package)
- See files: 
  - `https://ood.artemis.hrc.sussex.ac.uk/pun/sys/dashboard/files/fs//mnt/lustre/users/psych/dmm56/FictionChoco`
  - `https://ood.artemis.hrc.sussex.ac.uk/pun/sys/dashboard/files/fs//mnt/lustre/scratch/psych/dmm56/FictionChoco`