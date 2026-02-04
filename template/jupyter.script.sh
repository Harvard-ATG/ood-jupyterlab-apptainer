#!/bin/bash

# Run pyppeteer install to fix issue with exporting to pdf
# pyppeteer-install

# -------------------------------------------------------------------------
# OPTIONAL: DISABLE HEAVY EXTENSIONS [DEACTIVATED]
# -------------------------------------------------------------------------
# CONTEXT:
# The Jupyter Extension Manager attempts to fetch updates from the internet 
# every time the notebook starts. This consumes significant CPU cycles (100% core usage)
# for 2-4 seconds during startup.
#
# HOW TO ENABLE:
# Uncomment the line below. This is recommended if running on small nodes 
# (e.g., 1-2 CPUs) to prevent startup crashes or sluggishness.
# -------------------------------------------------------------------------
# DISABLE_FLAGS=""
# # DISABLE_FLAGS="--LabApp.disabled_extensions='@jupyterlab/extensionmanager-extension'"

# jupyter lab \
#            --ip='0.0.0.0' \
#            --port="${MY_JUP_PORT}" \
#            --port-retries=0 \
#            --ServerApp.PasswordIdentityProvider.hashed_password="${MY_JUP_PASSWD}" \
#            --ServerApp.base_url="${MY_JUP_BASEURL}" \
#            --no-browser \
#            --ServerApp.allow_origin='*' \
#            --ServerApp.disable_check_xsrf=True \
#            --WebPDFExporter.disable_sandbox=True


# -------------------------------------------------------------------------
# OPTIMIZED LAUNCH SCRIPT WITH SCRATCH/LUSTRE REDIRECTION
# -------------------------------------------------------------------------
# Optimized for Luster and High-Concurrency I/O Classes.

# --- 1. SET UP PARAMETERS ---
PORT="${MY_JUP_PORT:-8888}"
BASE_URL="${MY_JUP_BASEURL:-/}"
PASSWORD="${MY_JUP_PASSWD}"


# --- 2. GENERATE RUNTIME CONFIGURATION FILE ---
# MOVING AWAY FROM: Passing raw CLI flags (e.g., --ip, --port) which may be prone 
#                  to shell-escaping errors and cause "Missing Extension" popups.
#
# MOVING TOWARD:   A generated Python config file to 
#                  simultaneously disable Backend and Frontend components to 
#                  fix UI sluggishness and icon "lag."
# -----------------------------------------------------------------------------
CONF_FILE="${PWD}/jupyter_server_config.py"

cat <<EOF > "${CONF_FILE}"
c = get_config()

# --- NETWORK & SECURITY ---
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = ${PORT}
c.ServerApp.port_retries = 0
c.ServerApp.base_url = '${BASE_URL}'
c.ServerApp.PasswordIdentityProvider.hashed_password = '${PASSWORD}'
c.ServerApp.allow_origin = '*'
c.ServerApp.disable_check_xsrf = True
c.ServerApp.open_browser = False
c.WebPDFExporter.disable_sandbox = True

# --- UI & PERFORMANCE OPTIMIZATION (THE "ICON & POPUP" FIX) ---
# MOVING AWAY FROM: Default loading of all sidebar extensions.
# MOVING TOWARD:   Explicitly disabling high-I/O extensions. This prevents the 
#                  browser from "searching" for icons and status updates on 
#                  slow storage, which fixes the "Sluggish Icon" effect.

# A. BACKEND: Stop the Python server from loading these plugins (Saves RAM/CPU)
c.ServerApp.jpserver_extensions = {
    'dask_labextension': False,             # Constantly polls cluster status
    'jupyter_server_xarray_leaflet': False, # Heavy GIS metadata calls
    'jupyterlab_git': False,                # Crawls file tree for .git folders
    'nbgitpuller': False,                   # External sync service
    'panel.io.jupyter_server_extension': False # Dask-related, heavy JS load
}

# B. FRONTEND: Stop the Browser from requesting these icons (Fixes rendering lag)
# By matching this list with the backend above, we prevent "Extension Missing" popups.
c.LabConfig.disabled_extensions = [
    '@jupyterlab/extensionmanager-extension', # Goal to prevents CPU spike on startup
    '@jupyterlab/git',                        # Removes sidebar Git icon, git can be handled via terminal
    '@jupyterlab/github',                     # Removes sidebar GitHub icon, git can be handled via terminal
    '@jupyterlab/google-drive',                # Removes sidebar Drive icon, prevents heavy Google API calls
    'dask-labextension',                      # Removes sidebar Dask icon, Dask can still be used via terminal or code
    'jupyter-leaflet'                         # Prevents heavy GIS JS load, static maps can still be used in notebooks
]
EOF


# --- 3. LAUNCH JUPYTER ---
# MOVING AWAY FROM: 'jupyter lab [flags]'
# MOVING TOWARD:   'exec jupyter lab --config' 
# Using 'exec' ensures the container catches Slurm/OOD termination signals 
# immediately, leading to cleaner job exits and faster resource release.
# -----------------------------------------------------------------------------
echo "INFO: Launching Jupyter with config file: ${CONF_FILE}"
exec jupyter lab --config "${CONF_FILE}"
