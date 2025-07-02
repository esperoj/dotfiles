#!/bin/bash

. ~/.profile
time make --keep-going --output-sync=target -j -f ~/recipes/daily.mk daily &>~/log/daily-cron/$(date -I).log
EXIT_CODE=$? make -f ~/recipes/daily.mk stop-services hc-stop
