#!/bin/bash

content=$(
	cat <<EOL
{
  "branch": "main",
  "variables": {
    "WORKFLOW": "run-command",
    "COMMAND": "${1}"
  }
}
EOL
)

result=$(curl -s -X POST "${WOODPECKER_SERVER}/api/repos/12554/pipelines" \
	-H "Authorization: Bearer ${WOODPECKER_TOKEN}" \
	-H "Content-type: application/json" \
	-d "${content}")

number=$(echo "${result}" | jq .number)
echo "https://ci.codeberg.org/repos/12554/pipeline/${number}"
