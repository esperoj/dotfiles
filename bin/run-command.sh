#!/bin/bash

content=$(
	jq -n \
		--arg command "${1}" \
		'{
       "branch": "main",
       "variables": {
         "WORKFLOW": "run-command",
         "COMMAND": $command
       }
     }'
)
result=$(curl -s -X POST "${WOODPECKER_SERVER}/api/repos/12554/pipelines" \
	-H "Authorization: Bearer ${WOODPECKER_TOKEN}" \
	-H "Content-type: application/json" \
	-d "${content}")
number=$(echo "${result}" | jq .number)
echo "https://ci.codeberg.org/repos/12554/pipeline/${number}"
