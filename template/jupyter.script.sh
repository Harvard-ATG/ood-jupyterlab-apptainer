#!/bin/bash

# Run pyppeteer install to fix issue with exporting to pdf
# pyppeteer-install

jupyter lab \
           --ip='0.0.0.0' \
           --port="${MY_JUP_PORT}" \
           --port-retries=0 \
           --NotebookApp.password="${MY_JUP_PASSWD}" \
           --NotebookApp.base_url="${MY_JUP_BASEURL}" \
           --no-browser \
           --NotebookApp.allow_origin='*' \
           --NotebookApp.disable_check_xsrf=True \
           --WebPDFExporter.disable_sandbox=True
