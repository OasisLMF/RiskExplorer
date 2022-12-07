library(data.table)
library(tidyverse)
library(lubridate)
library(dplyr)
library(zoo)

# 0.SPECIFY DOWNLOAD PARAMETERS: Allows the user to specify when data
# was last downloaded and whether they want to re-download the 
# data. If data needs to be re-downloaded, set update_data to 
# 'yes' and change lastdownloaddate to today's date.

update_data <- "yes"
lastdownloaddate <- as.Date("2022-07-15")

# R defaults to allowing 60 seconds for downloads before timing out.
# Default is changed to 300 secs here given the size of the file.
# This can be further increased by the user if they are
# are still running into issues with the download timing out.

options(timeout = 300)

# 1.READ IN REQUIRED DATA: IBTrACS data is downloaded from the NOAA 
# website and read into a csv.

if (update_data == "yes") {
  URL <- "https://www.ncei.noaa.gov/data/international-best-track-archive-for-climate-stewardship-ibtracs/v04r00/access/csv/ibtracs.ALL.list.v04r00.csv"
  download.file(URL, paste0("./data/ibtracs/ibtracs_raw_data_", lastdownloaddate,
                            ".csv"), method = "libcurl", mode = "wb", timeout = )
}

ibtracs_data <- read.csv(paste0("./data/ibtracs/ibtracs_raw_data_",
                                lastdownloaddate, ".csv"), header = TRUE, na.strings = "")[-1, ]

# 2.FILTERING DATA: This section specifies the required columns to
# keep from the IBTrACS data, assigns suitable data classes to these
# and filters for only the rows we require.

selected_vars <- c("SID", "SEASON", "NUMBER", "BASIN", "SUBBASIN", "NAME",
                   "ISO_TIME", "NATURE", "LAT", "LON", "WMO_WIND", "WMO_PRES", "WMO_AGENCY",
                   "USA_LAT", "USA_LON", "USA_WIND", "USA_PRES", "USA_RMW", "TOKYO_LAT",
                   "TOKYO_LON", "TOKYO_WIND", "TOKYO_PRES", "CMA_LAT", "CMA_LON", "CMA_WIND",
                   "CMA_PRES", "NEWDELHI_LAT", "NEWDELHI_LON", "NEWDELHI_WIND", "NEWDELHI_PRES",
                   "REUNION_LAT", "REUNION_LON", "REUNION_WIND", "REUNION_PRES", "BOM_LAT",
                   "BOM_LON", "BOM_WIND", "BOM_PRES", "BOM_RMW", "NADI_LAT", "NADI_LON",
                   "NADI_WIND", "NADI_PRES", "WELLINGTON_LAT", "WELLINGTON_LON", "WELLINGTON_WIND",
                   "WELLINGTON_PRES")

ibtracs_data <- select(ibtracs_data, selected_vars)

ibtracs_data$ISO_TIME <- as.POSIXct(strptime(ibtracs_data$ISO_TIME, "%Y-%m-%d %H:%M:%S",
                                             tz = "UTC"))

ibtracs_data[, selected_vars[c(1, 3:6, 8, 13)]] <- lapply(ibtracs_data[,
                                                                       selected_vars[c(1, 3:6, 8, 13)]], as.factor)

ibtracs_data[, selected_vars[c(2, 9:12, 14:ncol(ibtracs_data))]] <- sapply(ibtracs_data[,
                                                                                        selected_vars[c(2, 9:12, 14:ncol(ibtracs_data))]], as.numeric)

ibtracs_data <- ibtracs_data %>%
  filter((SEASON >= 1978 | (BASIN == "NA" & SEASON >= 1948))) %>%
  arrange(SID, ISO_TIME)

# 3.SELECTING AGENCY MEASURES BY BASIN: Generates a mappings table
# of the relevant agencies for each region. Columns are generated
# allowing the user to pull in up to three different alternatives for
# each region. All measures that are not for one of the specified
# agencies are dropped. Wind speeds are also converted from knots to
# metric here with metric used as the default throughout the app

basin_agency <- data.frame(BASIN = c("NA", "EP", "WP", "NI", "SI", "SP","SA"), 
                           AGENCY1 = c("USA", "USA", "USA", "NEWDELHI", "REUNION", "WELLINGTON","USA"), 
                           AGENCY2 = c(NA, NA, "TOKYO","USA", "BOM", "BOM", NA), 
                           AGENCY3 = c(NA, NA, "CMA", NA, NA, "NADI", NA))

measure_types <- c("LAT", "LON", "WIND", "PRES", "RMW")

ibtracs_data <- merge(ibtracs_data, basin_agency)

for (i in 1:length(measure_types)) {
  ibtracs_data <- ibtracs_data %>%
    rowwise %>%
    mutate(across(matches("\\bAGENCY[0-9]\\b"), ~as.numeric(get0(paste(.x,
                                                                       measure_types[i], sep = "_"), ifnotfound = NA)), .names = paste("{col}",
                                                                                                                                       measure_types[i], sep = "_")))
}

ibtracs_data <- ibtracs_data %>%
  mutate(across(AGENCY1_WIND:AGENCY3_WIND, ~.x * 1.852)) %>%
  select(BASIN:NATURE, AGENCY1:AGENCY3_RMW) %>%
  ungroup()

# 4.FIXING LAT-LONGS: Transforms lat-longs that skip the date-line to
# prevent issues with interpolation/map display later in the code.
# Selection of 165 is somewhat arbitrary but was taken to be on the
# cautious side in case there were gaps in the data

ibtracs_data_ll_correction <- ibtracs_data %>%
  group_by(SID) %>%
  filter(any(AGENCY1_LON > 165) & any(AGENCY1_LON < (-165)) | 
         any(AGENCY2_LON > 165) & any(AGENCY2_LON < (-165)) | 
         any(AGENCY3_LON > 165) & any(AGENCY3_LON < (-165))) %>%
  ungroup() %>%
  mutate(AGENCY1_LON = ifelse(AGENCY1_LON < 0, AGENCY1_LON + 360, AGENCY1_LON),
         AGENCY2_LON = ifelse(AGENCY2_LON < 0, AGENCY2_LON + 360, AGENCY2_LON),
         AGENCY3_LON = ifelse(AGENCY3_LON < 0, AGENCY3_LON + 360, AGENCY3_LON))

SID_correct_list <- unique(ibtracs_data_ll_correction$SID)

`%!in%` <- Negate(`%in%`)


ibtracs_data <- ibtracs_data %>%
  mutate(AGENCY1_LON = ifelse(AGENCY1_LON < (-180), AGENCY1_LON + 360,AGENCY1_LON),
         AGENCY2_LON = ifelse(AGENCY2_LON < (-180), AGENCY2_LON + 360,AGENCY2_LON),
         AGENCY3_LON = ifelse(AGENCY3_LON < (-180), AGENCY3_LON + 360,AGENCY3_LON)) %>%
  filter(SID %!in% SID_correct_list) %>%
  rbind(ibtracs_data_ll_correction) %>%
  arrange(SID, ISO_TIME)

# 5.INTERPOLATING THE DATA INTO 15 MINUTE INCREMENTS: Sets up a data
# frame at 15 minute increments for the date/time variable.
# Non-measure variables are taken from the preceding row and measure
# variables are interpolated based on the original data intervals.

value_vars <- names(ibtracs_data)[grepl(paste(measure_types, collapse = "|"),
                                        names(ibtracs_data))]
exclude_vars <- setdiff(names(ibtracs_data), c(value_vars, "ISO_TIME",
                                               "SID"))
min_max_times <- merge(ibtracs_data %>%
                         group_by(SID) %>%
                         dplyr::summarise(output_time_min = min(ISO_TIME)), ibtracs_data %>%
                         group_by(SID) %>%
                         dplyr::summarise(output_time_max = max(ISO_TIME)))

output_times <- mapply(function(x, y, z) {
  seq(from = x, to = y, by = dminutes(15))
}, x = min_max_times$output_time_min, y = min_max_times$output_time_max,
SIMPLIFY = FALSE)

output_SID <- mapply(function(x, y) {
  rep(x, y)
}, x = min_max_times$SID, y = lapply(output_times, length))


output <- data.frame(ISO_TIME = reduce(output_times, c), SID = unlist(output_SID))

ibtracs_data <- merge(output, select(ibtracs_data, c("ISO_TIME", "SID",
                                                     c(value_vars, exclude_vars))), by = c("ISO_TIME", "SID"), all.x = TRUE) %>%
  arrange(SID, ISO_TIME) %>%
  tidyr::fill(exclude_vars) %>%
  group_by(SID)

for (value_var in value_vars) {
  ibtracs_data <- ibtracs_data %>%
    mutate(`:=`(!!paste0(value_var), na.approx(!!as.name(paste0(value_var)),
                                               na.rm = FALSE)))
}

ibtracs_data <- ungroup(ibtracs_data) 

# 6.SAVING DOWN CLEANED OUTPUT FILES: Saves down overall and basin 
# specific output files in the data directory. This function has
# some flexibility for extracting different yearly intervals too.

basins <- c("NA", "SP", "SI", "WP", "EP", "NI", "SA")
start_years <- c(1948, rep(1978, 6))
end_year<-2021
  
mapply(function(x, y, z) {
  write.csv(filter(ibtracs_data, BASIN == x & SEASON >= y & SEASON <=z),
                      paste0(paste("./data/ibtracs/ibtracs_data", x, y,lastdownloaddate, sep = "_"),".csv"))
}, x = basins, y = start_years,z=end_year)

write.csv(ibtracs_data,paste("./data/ibtracs/ibtracs_data_ALL_",lastdownloaddate,".csv"))

# APPENDIX:

# Checks mean deviation by SID. check_data is
# just ibtracs_data after the third section of code
# write.csv(cbind(check_data%>%group_by(SID)%>%summarise(across(AGENCY1_LAT:AGENCY3_RMW,mean)),
# ibtracs_data%>%group_by(SID)%>%summarise(across(AGENCY1_LAT:AGENCY3_RMW,mean))),
# 'SID_Check.csv') tic()
# test<-read.csv('ibtracs_data_NA_1948_2022-03-19') toc()
