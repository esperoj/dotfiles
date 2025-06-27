#!/bin/bash

. ~/.profile
time make --output-sync=target -j -f ~/recipes/daily.mk daily
EXIT_CODE=$? make -f ~/recipes/daily.mk hc-stop
