# Configure your directory paths
staging_directory <- "bin/data/raw_data"          # Where raw data will be stored
flagged_directory <- "bin/data/flagged_data"      # Where flagged data will be saved
temp_directory <- "bin/data/temp_files"          # Temporary processing files
final_directory <- "bin/data/final_output"       # Final processed data

# Configure your threshold files
sensor_thresholds_file <- "path/to/sensor_spec_thresholds.yml"
seasonal_thresholds_file <- "path/to/updated_seasonal_thresholds_2025.csv"

# Configure your credentials files
mwater_creds_file <- "path/to/mWaterCreds.yml"
hydrovu_creds_file <- "/mnt/src/bin/HydroVuCreds.yml"

# Configure date range for data retrieval
start_date <- "2025-07-01 00:00:00"  # MST
end_date <- "2025-07-01 23:59:59"    # MST

# Configure sites to process
sites_to_process <- c("archery", "bellvue", "boxcreek", "boxelder", "cbri", "chd", 
                      "cottonwood", "elc", "joei", "lbea", "legacy", "lincoln", 
                      "mtncampus", "pbd", "pbr", "penn", "pfal", "pman", "prospect", 
                      "river bluffs", "riverbluffs", "riverbend", "salyer", "sfm", 
                      "springcreek", "tamasag", "timberline", "udall")

# This is used to load the source code we are developing aka the fcw.qaqc package
devtools::load_all('/mnt/src')

# suppress scientific notation for consistent formatting
options(scipen = 999)


hv_creds <- yaml::read_yaml(hydrovu_creds_file)

hv_token <- hv_auth(client_id = as.character(hv_creds["client"]),
                    client_secret = as.character(hv_creds["secret"]))

hv_sites <- hv_locations_all(hv_token) %>%
  filter(!grepl("vulink", name, ignore.case = TRUE))

mst_start <- lubridate::ymd_hms(start_date, tz = "America/Denver")
mst_end <- lubridate::ymd_hms(end_date, tz = "America/Denver")

purrr::walk(sites_to_process,
     function(site) {
       message("Requesting HV data for: ", site)
       api_puller(
         site = site,
         start_dt = lubridate::with_tz(mst_start, tzone = "UTC"),
         end_dt = lubridate::with_tz(mst_end, tzone = "UTC"),
         api_token = hv_token,
         dump_dir = staging_directory
       )
     }
)
