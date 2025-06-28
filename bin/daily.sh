#!/bin/bash

. ~/.profile
time make --output-sync=target -j -f ~/recipes/daily.mk daily &> ~/log/daily-cron/`date -I`.log
EXIT_CODE=$? make -f ~/recipes/daily.mk hc-stop
