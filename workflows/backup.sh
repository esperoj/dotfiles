#!/bin/bash

cd ~
rclone sync -v gdrive:working .
restic 
