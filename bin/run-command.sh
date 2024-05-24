#!/bin/bash

host="codeberg"
command="${COMMAND:-uptime}"

usage() {
  echo "Usage: ${0} -c <command> [-h <host>]"
  echo "  -c: Specify the command to run on the host"
  echo "  -h: Specify the host where the command will be run (default: ${host})"
  exit 1
}

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

case "${host}" in

local)
  ~/bin/entrypoint.sh "${command}"
  ;;

codeberg | cezeri)
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
  ;;

framagit | gitlab)
  case "${host}" in
  gitlab)
    server="https://gitlab.com"
    project_id=58158450
    token="${GITLAB_DOTFILES_TRIGGER_TOKEN}"
    ;;
  framagit)
    server="https://framagit.org"
    repo_id=107814
    token="${FRAMAGIT_DOTFILES_TRIGGER_TOKEN}"
    ;;
  esac
  result=$(curl -sX POST \
    --fail \
    -F token="${token}" \
    -F "ref=main" \
    -F "variables[WORKFLOW]=run-command" \
    -F "variables[COMMAND]=${command}" \
    "${server}/api/v4/projects/${project_id}/trigger/pipeline" |
    jq .web_url)
  bash -c "echo ${result}"
  ;;

esac
