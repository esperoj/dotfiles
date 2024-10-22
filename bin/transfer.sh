#!/bin/bash

FILENAME=$(basename "$1")

rclone copy -P "$1" "cache:"
rclone link "cache:${FILENAME}"
