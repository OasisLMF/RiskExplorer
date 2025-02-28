setup_python_environment <- function(version, 
                                     env_name, 
                                     packages){

  reticulate::install_python(version)
  reticulate::virtualenv_create(env_name, version = version)
  reticulate::use_virtualenv(env_name)
  reticulate::py_install(packages, envname = env_name)  
  
} 
