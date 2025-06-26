.ONESHELL:
.DELETE_ON_ERROR:
.SHELLFLAGS     := -eu -o pipefail -c
MAKEFLAGS       += --warn-undefined-variables
MAKEFLAGS       += --no-builtin-rules
SHELL           := bash

export

.DEFAULT_GOAL   := daily
ROOT_DIR        != dirname $(realpath $(firstword $(MAKEFILE_LIST)))
BACKUP_LIST     ?= backup-database backup-linkwarden backup-repos

include $(ROOT_DIR)/backup.mk


daily: hc-start info daily-backup daily-verify
	$(MAKE) -f $(ROOT_DIR)/daily.mk stop-services hc-stop
.PHONY: daily

daily-backup: sync-backup backup-journal upload-backup
	rm -r "$${BACKUP_FOLDER}"
.PHONY: daily-backup

info:
	time info.sh
.PHONY: info

daily-verify: start-services wait
	time esperoj daily_verify
.PHONY: daily-verify

hc-start:
	curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/$${PING_UUID}/daily/start"
.PHONY: hc-start

hc-stop:
	curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/${PING_UUID}/daily/0"
.PHONY: hc-stop

start-services:
	start.sh esperoj_storage caddy
.PHONY: start-services

stop-services:
	stop.sh esperoj_storage caddy
.PHONY: stop-services

wait:
	sleep 5
.PHONY: wait
