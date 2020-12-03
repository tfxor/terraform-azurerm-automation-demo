#!/usr/bin/env bash

npm --version > /dev/null 2>&1 || { echo >&2 "[ERROR]: npm is missing. aborting..."; exit 1; }
terrahub --version > /dev/null 2>&1 || { echo >&2 "[ERROR]: terrahub is missing. aborting..."; exit 1; }

export NODE_PATH="$(npm root -g)"
export npm_config_unsafe_perm="true"

if [[ "${CODEBUILD_WEBHOOK_EVENT}" =~ "PULL_REQUEST_MERGED" ]]; then THUB_STATE="approve"; fi
if [[ "${CODEBUILD_WEBHOOK_EVENT}" =~ "PULL_REQUEST" ]]; then THUB_STATE="${THUB_STATE}&build"; fi
if [[ ! -z "${CODEBUILD_WEBHOOK_BASE_REF}" ]]; then BRANCH_TO="${CODEBUILD_WEBHOOK_BASE_REF/refs\/heads\//}"; fi
if [[ ! -z "${CODEBUILD_WEBHOOK_HEAD_REF}" ]]; then BRANCH_FROM="${CODEBUILD_WEBHOOK_HEAD_REF/refs\/heads\//}"; fi
if [[ -z "${BRANCH_TO}" ]]; then BRANCH_TO="dev"; fi
if [[ -z "${BRANCH_FROM}" ]]; then BRANCH_FROM="dev"; fi

CICD_OPTS=""
if [[ "${BRANCH_TO}" != "dev" ]]; then CICD_OPTS="${CICD_OPTS} -e ${BRANCH_TO}"; fi
if [[ "${BRANCH_TO}" != "${BRANCH_FROM}" ]]; then CICD_OPTS="${CICD_OPTS} -g ${BRANCH_TO}..${BRANCH_FROM}"; fi
if [[ "${THUB_STATE}" =~ "build" ]]; then CICD_OPTS="${CICD_OPTS} -b"; fi
if [[ "${THUB_STATE}" =~ "approve" ]]; then CICD_OPTS="${CICD_OPTS} -a"; fi
if [[ "${THUB_STATE}" =~ "destroy" ]]; then CICD_OPTS="${CICD_OPTS} -d"; fi
if [[ ! -z "${THUB_INCLUDE}" ]]; then CICD_OPTS="${CICD_OPTS} -I \"^(${THUB_INCLUDE})\""; fi
if [[ ! -z "${THUB_EXCLUDE}" ]]; then CICD_OPTS="${CICD_OPTS} -X \"^(${THUB_EXCLUDE})\""; fi

echo "EXEC: terrahub run -y -p include ${CICD_OPTS}"
terrahub run -y -p include ${CICD_OPTS}
