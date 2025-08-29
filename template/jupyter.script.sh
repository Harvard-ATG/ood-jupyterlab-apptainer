#!/bin/bash

# Run pyppeteer install to fix issue with exporting to pdf
# pyppeteer-install

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
