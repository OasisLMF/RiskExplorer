import warnings
warnings.filterwarnings('ignore')

import xarray as xr
import numpy as np
import copy
import sys
import argparse
from python_index_helper_fun import calc_index_user_season


def return_chirps_nc(window_start,window_end,lonmin,lonmax,latmin,latmax,file_full,year_length,year_start,year_end,threshold,file_intermediate):
    window_start = int(window_start)
    window_end = int(window_end)
    lonmin = float(lonmin)
    lonmax = float(lonmax)
    latmin = float(latmin)
    latmin = float(latmin)
    year_length = int(year_length)
    year_start = int(year_start)
    year_end = int(year_end)
    threshold = float(threshold)

    precip_index_xr = calc_index_user_season(window_start,window_end,lonmin,lonmax,latmin,latmax,file_full,year_length,year_start,year_end,threshold)
    precip_index_allyears_xr=precip_index_xr.sel(longitude=slice(lonmin,lonmax),latitude=slice(latmin,latmax)).load()
    precip_index_allyears_xr.to_netcdf(file_intermediate,engine='scipy')
    return(file_intermediate)

