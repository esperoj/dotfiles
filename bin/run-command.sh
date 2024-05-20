#!/bin/bash

DEFAULT_HOST="codeberg"

usage() {
  echo "Usage: ${0} -c <command> [-h <host>]"
  echo "  -c: Specify the command to run on the host"
  echo "  -h: Specify the host where the command will be run (default: ${DEFAULT_HOST})"
  exit 1
}

host="${DEFAULT_HOST}"

while getopts "c:h:" opt; do
  case "${opt}" in
  c) command="${OPTARG}" ;;
  h) host="${OPTARG}" ;;
  \?)
    echo "Invalid option: -${OPTARG}" >&2
    usage
    ;;
  esac
done

if [ -z "${command}" ]; then
  echo "Error: Command must be specified."
  usage
fi

content=$(
  jq -n \
    --arg command "${command}" \
    '{
       "branch": "main",
       "variables": {
         "WORKFLOW": "run-command",
         "COMMAND": $command
       }
     }'
)

case "${host}" in
codeberg)
  server=ci.codeberg.org
  repo_id=12554
  token="${WOODPECKER_TOKEN}"
  ;;
cezeri)
  server=build.cezeri.tech
  repo_id=9
  token="${CEZERI_WOODPECKER_TOKEN}"
  ;;
esac

result=$(curl -s -X POST "https://${server}/api/repos/${repo_id}/pipelines" \
  -H "Authorization: Bearer ${token}" \
  -H "Content-type: application/json" \
  -d "${content}")

number=$(echo "${result}" | jq .number)

echo "https://${server}/repos/${repo_id}/pipeline/${number}"
