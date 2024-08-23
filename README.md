# Jupyter Lab app for Open OnDemand

This app configuration provides access to a Jupyter Lab environment running inside of an Apptainer container.

## Requirements

This app uses [Spack](https://spack.io/) for package management to load an
[Apptainer](https://apptainer.org/) container. If this software is already
configured on your compute nodes, you can remove this load step. Otherwise,
ensure that the script will load your spack environment, and that you have an
environment configured for apptainer. Spack environments are preferred over
loading modules directly. Environments provide consistency by articulating the
concretized stack of packages to load, and they provide flexibility in that one
can update the environment to update packages without needing to update the app
configuration to load new packages. A sample configuration is included at
`spack-environment/apptainer/spack.yml`

The `form.yml` file provides a list of valid apptainer containers that a user
can select from. The containers in the `form.yml` correspond to the apptainer
definition files in the `build` directory. The location where `.sif` files are
stored is defined in the [template/script.sh.erb] file.

These images can be built with apptainer commands, such as

```bash
apptainer build /shared/sif/scipy-notebook.sif build/scipy-notebook.def
```
