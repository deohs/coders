# Use OneDrive & SharePoint folders, synced locally with OneDrive app or rclone

# Tested on Ubuntu 24.04 LTS and 20.04 LTS, as well as macOS Sequoia 15.0.1 
# and Windows 11 Enterprise and Windows 10 Enterprise LTSC 2021.

# Attach packages, installing as needed
if(!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")
pacman::p_load(folders)

# -----------------
# Define functions
# -----------------

# Return home path from environment variable
get_home <- function () {
  Sys.getenv(ifelse(.Platform$OS.type == "windows", "USERPROFILE", "HOME"))
}

# Create Office365 paths for OneDrive and SharePoint folders
o365.folders <- function(org = "UW", 
                         names = c('onedrive', 'sharepoint'),
                         prefix = c("OneDrive - ", ""), 
                         home = get_home()) {
  setNames(as.list(normalizePath(file.path(home, paste0(prefix, org)))), names)
}

# -------------
# Main routine
# -------------

# Create paths for OneDrive and SharePoint folders
my.o365 <- o365.folders()

# Create folders if missing
res <- sapply(my.o365, dir.create, showWarnings = FALSE, recursive = TRUE)

# List the folders in the top-level of the OneDrive and SharePoint folders
list.dirs(my.o365$onedrive, recursive = FALSE, full.names = FALSE)
list.dirs(my.o365$sharepoint, recursive = FALSE, full.names = FALSE)

# Sync files from remote
remote_path <- paste(c(shQuote('og_sphtech'), shQuote('SPH HPC Service')), 
                     collapse = ':')
local_path <- shQuote(normalizePath(file.path(my.o365$sharepoint, 
                                              'og_sphtech', 'Documents', 'SPH HPC Service'),
                                    mustWork = FALSE))
rclone_conf <- 
  tail(system2("rclone", args = c("config", "file"), stdout = TRUE), 1)
if(file.exists(rclone_conf)) {
  rclone_args <- c('sync', '--update', remote_path, local_path)
  system2(command = 'rclone', args = rclone_args)
}

# Setup folders
conf <- here::here('conf', 'folders.yml')
folders <- get_folders(conf)
data_dir <- normalizePath(file.path(my.o365$sharepoint, 
                                    'og_sphtech/Documents/SPH HPC Service', 'data'), 
                          mustWork = FALSE)

# Edit the default configuration file to save the modification
sysname <- Sys.info()[['sysname']]
folders_list <- list(default = folders)
folders_list[[sysname]]$data = data_dir
conf <- here::here('conf', 'folders_sp.yml')
yaml::write_yaml(folders_list, file = conf)

# Read edited configuration file
folders <- get_folders(conf, conf_name = sysname)
data_folder <- folders$data

# Compare results
all.equal(data_dir, data_folder)

# Create data folder if missing
dir.create(data_folder, showWarnings = FALSE, recursive = TRUE)

# Save a file to the data folder
write.csv(iris, file = file.path(data_folder, 'iris.csv'), row.names = FALSE)

# Show contents of data folder
normalizePath(list.files(data_folder, recursive = TRUE, full.names = TRUE))

# Sync files to remote
if(file.exists(rclone_conf)) {
  rclone_args <- c('sync', '--update', local_path, remote_path)
  system2(command = 'rclone', args = rclone_args)
}
