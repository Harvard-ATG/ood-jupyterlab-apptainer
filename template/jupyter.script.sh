#!/bin/bash

# Run pyppeteer install to fix issue with exporting to pdf
# pyppeteer-install

# This script was refined with the help of Gemini 3 Pro and Claude 4.5 Sonnet AI Models

# -------------------------------------------------------------------------
# OPTIONAL: DISABLE HEAVY EXTENSIONS (LEGACY CLI METHOD – NOW REPLACED)
# -------------------------------------------------------------------------
# The old approach used CLI flags (DISABLE_FLAGS) to disable extensions.
# We now prefer config files (page_config.json + jupyter_server_config.py)
# to control both frontend and backend extensions.
# -------------------------------------------------------------------------
# DISABLE_FLAGS=""
# DISABLE_FLAGS="--LabApp.disabled_extensions='@jupyterlab/extensionmanager-extension'"

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
# OPTIMIZED LAUNCH SCRIPT USING GENERATED CONFIG
# -------------------------------------------------------------------------

# Basic server parameters from the OOD/apptainer environment
PORT="${MY_JUP_PORT:-8888}"
BASE_URL="${MY_JUP_BASEURL:-/}"
PASSWORD="${MY_JUP_PASSWD}"

# -------------------------------------------------------------------------
# 1. FRONTEND: disable heavy JupyterLab extensions via page_config.json
#
# This controls the browser-side extensions (sidebars, icons, menus).
# Disabling high-I/O / external service integrations here reduces the
# number of small asset loads and API calls during startup.
# -------------------------------------------------------------------------
LABCONFIG_DIR="${HOME}/.jupyter/labconfig"
mkdir -p "${LABCONFIG_DIR}"

cat > "${LABCONFIG_DIR}/page_config.json" <<'EOF'
{
  "disabledExtensions": {
    "@jupyterlab/extensionmanager-extension": true,
    "@jupyterlab/git": true,
    "@jupyterlab/github": true,
    "@jupyterlab/google-drive": true,
    "dask-labextension": true,
    "jupyter-leaflet": true,
    "jupyterlab-code-formatter": true,
    "nbdime-jupyterlab": true
  }
}
EOF

# -------------------------------------------------------------------------
# 2. BACKEND: generate a temporary jupyter_server_config.py
#
# This replaces long CLI flag lists with a single config file that:
# - Sets the usual ServerApp network/security options.
# - Disables selected jpserver extensions that do heavy polling or I/O.
# -------------------------------------------------------------------------
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

# --- UI & PERFORMANCE OPTIMIZATIONS ---
# Disable backend extensions that cause extra polling or metadata scans.
c.ServerApp.jpserver_extensions = {
    'dask_labextension': False,
    'jupyter_server_xarray_leaflet': False,
    'jupyterlab_git': False,
    'nbgitpuller': False,
    'panel.io.jupyter_server_extension': False
}
EOF

# -------------------------------------------------------------------------
# 3. LAUNCH JUPYTERLAB USING THE CONFIG FILE
#
# Using 'exec' ensures the Jupyter process becomes PID 1 in the container
# so Slurm/OOD signals (TERM, INT) are delivered cleanly and jobs exit
# promptly when cancelled.
# -------------------------------------------------------------------------
echo "INFO: Launching JupyterLab with config file: ${CONF_FILE}"
exec jupyter lab --config "${CONF_FILE}"
