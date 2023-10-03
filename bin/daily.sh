#!/bin/bash

set -Exeo pipefail
ssh ct8 "devil info account"
ssh serv00 "devil info account"
