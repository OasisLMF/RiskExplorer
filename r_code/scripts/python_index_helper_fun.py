import warnings
warnings.filterwarnings('ignore')

import xarray as xr
import numpy as np
import copy
import sys
import argparse


def calc_index_user_season(window_start, window_end, lonmin, lonmax, latmin, latmax, file_full, year_length, year_start, year_end, threshold):
    '''
    Function to derive a simple index based on rainfall deficit during the 
    first rainy season to start during a user specified seasonal window. If no rainy season starts within the window, the function returns nans.
    This function is a rough and ready function for quickly looking at indices. It needs tidying up. 
    :param window_start: pentad over which the user defined seasonal window will start
    :param window_end: pentad over which the user defined seasonal window will end
    :param lonmin: minimum longitude of the region of interset
    :param lonmax: maximum longitude of the region of interset
    :param latmin: minimum latitude of the region of interset
    :param lonmax: maximum latitude of the region of interset
    :param file_full: path to the netcdf file containing the full resolution CHIRPS pentad data 
    :param year_length: length of year (72 for pentads)
    :param year_start: first year of the data
    :param year_end: last year of the data
    :param threshold: threshold for which a pentad anomaly (expressed as % climatology) or season is considered dry. [Units %]
    :returns precip_index: a numpy array of the percent climatology of the rainy season in question. The data are returned as a grid of 
    [year,latitude,longitude], where year is the start year of the rainy season.

    
    
    '''
    datain_xr = xr.open_dataset(file_full)
    datain_xr = datain_xr.sel(longitude=slice(lonmin, lonmax), latitude=slice(latmin, latmax))

    precip = datain_xr['precip'].values
    precip_reshape = np.reshape(precip, newshape=(
        int(precip.shape[0] / year_length), year_length, precip.shape[1], precip.shape[2]))
    precip_clim = np.nanmean(precip_reshape, axis=0)
    precip_clim_twoyears = np.concatenate([precip_clim, precip_clim], axis=0)

    indices = np.arange(precip_clim_twoyears.shape[0])[:, None, None]
    rainy_season_mask = np.where((indices > window_start) & (indices < window_end) & np.isfinite(precip_clim_twoyears),
                                 1, 0)

    precip_twoyears = np.concatenate([precip_reshape[:-1], precip_reshape[1:]], axis=1)

    ds_full = xr.Dataset(data_vars=dict(
        precip=(['year', 'pentad', 'latitude', 'longitude'], precip_twoyears),
        rainy_season_mask=(['pentad', 'latitude', 'longitude'], rainy_season_mask)),
        coords=dict(
            longitude=datain_xr['longitude'].values,
            latitude=datain_xr['latitude'].values,
            pentad=np.arange(1, 145),
            year=np.arange(year_start, year_end + 1))
    )

    precip = ds_full['precip'].values
    # precip_ann = np.nansum(precip, axis=1)

    clim_mean = np.mean(precip, axis=0)[None, :, :, :]
    clim_mean_repeated = np.repeat(clim_mean, precip.shape[0], axis=0)

    rainy_mask_repeated = np.repeat(ds_full['rainy_season_mask'].values[None, :, :, :], precip.shape[0], axis=0)
    precip_rainy_season = np.where(rainy_mask_repeated == 0, np.nan, precip)
    clim_rainy_season = np.where(rainy_mask_repeated == 0, np.nan, clim_mean_repeated)

    precip_index = 100 * np.nansum(precip_rainy_season, axis=1) / np.nansum(clim_rainy_season, axis=1)
    precip_index_categorical = np.where(precip_index < threshold, 1, 0)

    precip_pentad_anom = 100 * precip / clim_mean_repeated
    precip_pentad_anom_rainyseason = np.where(rainy_mask_repeated == 0, np.nan, precip_pentad_anom)
    precip_pentad_drypentad = np.where(precip_pentad_anom_rainyseason < threshold, 1, 0)

    precip_index_xr = xr.Dataset(data_vars=dict(
        insured_metric=(['year', 'latitude', 'longitude'], precip_index),
        precip_dryseason=(['year', 'latitude', 'longitude'], precip_index_categorical),
        precip_drypentad=(['year', 'pentad', 'latitude', 'longitude'], precip_pentad_drypentad),
        rainy_season_mask=(['pentad', 'latitude', 'longitude'], rainy_season_mask)),
        coords=dict(
            longitude=datain_xr['longitude'].values,
            latitude=datain_xr['latitude'].values,
            pentad=np.arange(1, 145),
            year=np.arange(year_start, year_end + 1))
    )

    return precip_index_xr