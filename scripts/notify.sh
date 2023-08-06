#!/bin/bash
data="${1}"
title=${2:-"Push from ${MACHINE_NAME:-unknown}"}
curl -SsfL \
	-H "Title: ${title}" \
	-d "${data}" \
	-H "Content-Type: text/plain" \
	${NTFY_URL}
