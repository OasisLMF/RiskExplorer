# setup_python.R

# Define the function to set up the Python environment
setup_python_environment <- function(version, 
                                     env_name, 
                                     packages) {
  reticulate::install_python(version)
  reticulate::virtualenv_create(env_name, version = version)
  reticulate::use_virtualenv(env_name)
  reticulate::py_install(packages, envname = env_name)
}

# List of Python packages to install
packages <- c(
  "dask",
  "h5netcdf",
  "netcdf4",
  "numpy",
  "packaging",
  "pandas",
  "xarray",
  "scipy"
)

# Set up the Python environment
setup_python_environment(
  version = "3.9.13", 
  env_name = "chirps",
  packages = packages
)

