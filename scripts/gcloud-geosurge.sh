#!/usr/bin/env bash
# gcloud-geosurge: Run gcloud with Chrome profile for muhamad@geosurge.ai

export BROWSER="chrome-by-email muhamad@geosurge.ai"
exec gcloud "$@"
