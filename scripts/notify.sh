#!/bin/bash
data=${1@Q}
CURL_OPTS='-H "Content-Type: text/plain"'
shift 1
for header in "$@"; do
	CURL_OPTS="${CURL_OPTS} -H ${header@Q}"
done
eval "curl -SsfL \
	-d ${data} \
  ${CURL_OPTS} \
	${NTFY_URL@Q}
"
