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
  "dask == 2024.8.0",
  "h5netcdf == 1.3.0",
  "netcdf4 == 1.7.1.post1",
  "numpy == 1.26.4",
  "packaging == 24.1",
  "pandas == 2.2.2",
  "xarray == 2024.7.0",
  "scipy == 1.13.1"
)

# Set up the Python environment
setup_python_environment(
  version = "3.9.13", 
  env_name = "chirps",
  packages = packages
)

# Explicitly add the directory containing the Python module to the Python path
reticulate::py_run_string("import sys")
reticulate::py_run_string("sys.path.append('/srv/shiny-server/scripts')")
