#!/bin/bash

host="local"
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

"local")
  ~/.local/bin/chezmoi init --apply --force
  bash -lc "${command}"
  ;;

github | blacksmith | blacksmith-arm)
  runner=$([ "${host}" = "github" ] && echo "ubuntu-latest" || echo "${host}")
  content=$(
    jq -n \
      --arg command "${command}" \
      --arg runner "${runner}" \
      '{
       "ref": "main",
       "inputs": {
         "runner": $runner,
         "command": $command
       }
     }'
  )

  request() {
    curl -sLSo /dev/null -w "%{http_code}" \
      -X POST \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer ${GITHUB_TOKEN}" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      "https://api.github.com/repos/esperoj/dotfiles-private/actions/workflows/run-command.yml/dispatches" \
      -d "${content}"
  }

  response=$(request)
  if [ "${response}" -eq 204 ]; then
    echo "Succeed triggered. Visit https://github.com/esperoj/dotfiles-private/actions/workflows/run-command.yml"
  else
    echo "Failed with status code: ${response}"
  fi
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
  result=$(curl -sSX POST "https://${server}/api/repos/${repo_id}/pipelines" \
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
    project_id=108057
    token="${FRAMAGIT_DOTFILES_TRIGGER_TOKEN}"
    ;;
  esac
  result=$(curl -sSX POST \
    --fail \
    -F token="${token}" \
    -F "ref=main" \
    -F "variables[WORKFLOW]=run-command" \
    -F "variables[COMMAND]=${command}" \
    "${server}/api/v4/projects/${project_id}/trigger/pipeline" |
    jq .web_url)
  bash -c "echo ${result}"
  ;;

git-gay)
  case "${host}" in
  git-gay)
    runner="docker"
    server="https://git.gay"
    token="${GIT_GAY_ACCESS_TOKEN}"
    ;;
  esac
  content=$(
    jq -n \
      --arg command "${command}" \
      --arg runner "${runner}" \
      '{
       "ref": "main",
       "inputs": {
         "runner": $runner,
         "command": $command
       }
     }'
  )

  request() {
    curl -sLSo /dev/null -w "%{http_code}" \
      -X POST \
      -H "Accept: application/json" \
      -H "Content-type: application/json" \
      -H "Authorization: bearer ${token}" \
      "${server}/api/v1/repos/esperoj/dotfiles/actions/workflows/run-command.yml/dispatches" \
      -d "${content}"
  }

  response=$(request)
  if [ "${response}" -eq 204 ]; then
    echo "Succeed triggered. Visit ${server}/esperoj/dotfiles/actions/?workflow=run-command.yml&actor=0&status=0"
  else
    echo "Failed with status code: ${response}"
  fi
  ;;
esac
