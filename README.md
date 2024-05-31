# Jupyter Lab app for Open OnDemand

This app configuration provides access to a Jupyter Lab environment running inside of an Apptainer container.

## Requirements

This app uses [Spack](https://spack.io/) for package management to load an [Apptainer](https://apptainer.org/) container. If this software is already configured on your compute nodes, you can remove this load step. Otherwise, ensure that the script will load your spack environment, and that you have an environment configured for apptainer. Spack environments are preferred over loading modules directly. Environments provide consistency by articulating the concretized stack of packages to load, and they provide flexibility in that one can update the environment to update packages without needing to update the app configuration to load new packages.

The `.sif` image file name is defined in the [form.yml] file, and the location where `.sif` files are stored is defined in the [template/script.sh.erb] file. 
