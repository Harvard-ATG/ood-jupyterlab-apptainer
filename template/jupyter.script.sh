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
DISABLE_FLAGS=""
# DISABLE_FLAGS="--LabApp.disabled_extensions='@jupyterlab/extensionmanager-extension'"

jupyter lab \
           --ip='0.0.0.0' \
           --port="${MY_JUP_PORT}" \
           --port-retries=0 \
           --ServerApp.PasswordIdentityProvider.hashed_password="${MY_JUP_PASSWD}" \
           --ServerApp.base_url="${MY_JUP_BASEURL}" \
           --no-browser \
           --ServerApp.allow_origin='*' \
           --ServerApp.disable_check_xsrf=True \
           --WebPDFExporter.disable_sandbox=True
