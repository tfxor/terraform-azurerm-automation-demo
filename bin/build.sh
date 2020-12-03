#!/usr/bin/env bash

aws --version > /dev/null 2>&1 || { echo >&2 "[ERROR]: aws is missing. aborting..."; exit 1; }
npm --version > /dev/null 2>&1 || { echo >&2 "[ERROR]: npm is missing. aborting..."; exit 1; }
terrahub --version > /dev/null 2>&1 || { echo >&2 "[ERROR]: terrahub is missing. aborting..."; exit 1; }

## Node configs
export NODE_PATH="$(npm root -g)"
export npm_config_unsafe_perm="true"

if [[ "${CODEBUILD_WEBHOOK_EVENT}" =~ "PULL_REQUEST_MERGED" ]]; then THUB_STATE="approve"; fi
if [[ "${CODEBUILD_WEBHOOK_EVENT}" =~ "PULL_REQUEST" ]]; then THUB_STATE="${THUB_STATE}&build"; fi
if [[ ! -z "${CODEBUILD_WEBHOOK_BASE_REF}" ]]; then BRANCH_TO="${CODEBUILD_WEBHOOK_BASE_REF/refs\/heads\//}"; fi
if [[ ! -z "${CODEBUILD_WEBHOOK_HEAD_REF}" ]]; then BRANCH_FROM="${CODEBUILD_WEBHOOK_HEAD_REF/refs\/heads\//}"; fi
if [[ -z "${BRANCH_TO}" ]]; then BRANCH_TO="dev"; fi
if [[ -z "${BRANCH_FROM}" ]]; then BRANCH_FROM="dev"; fi

CICD_OPTS=""
CICD_BUILD_OPTS=""
CICD_MIGRATIONS_OPTS=""
if [[ "${BRANCH_TO}" != "dev" ]]; then
  CICD_OPTS="${CICD_OPTS} -e ${BRANCH_TO}";
  CICD_BUILD_OPTS="${CICD_BUILD_OPTS} -e ${BRANCH_TO}";
  CICD_MIGRATIONS_OPTS="${CICD_MIGRATIONS_OPTS} -e ${BRANCH_TO}";
fi
if [[ "${BRANCH_TO}" != "${BRANCH_FROM}" ]]; then
  if [[ "${CODEBUILD_WEBHOOK_EVENT}" =~ "PULL_REQUEST_MERGED" ]]; then
    git checkout ${BRANCH_TO}
    PREVIOUS_HEAD=$(git log -n 1 --pretty | grep "Merge" | head -1 | awk '{print $2}')
    git checkout ${BRANCH_FROM}

    echo "INFO: Pull Request was merged. Using previous head ==> ${PREVIOUS_HEAD}"
    CICD_OPTS="${CICD_OPTS} -g ${PREVIOUS_HEAD}...${BRANCH_FROM}";
    CICD_BUILD_OPTS="${CICD_BUILD_OPTS} -g ${PREVIOUS_HEAD}...${BRANCH_FROM}";
  else
    echo "INFO: Pull Request was not merged. Using current head ==> ${BRANCH_TO}"
    CICD_OPTS="${CICD_OPTS} -g ${BRANCH_TO}...${BRANCH_FROM}";
    CICD_BUILD_OPTS="${CICD_BUILD_OPTS} -g ${BRANCH_TO}...${BRANCH_FROM}";
  fi;
fi

# if [[ "${THUB_STATE}" =~ "build" ]]; then CICD_OPTS="${CICD_OPTS} -b"; fi
if [[ "${THUB_STATE}" =~ "approve" ]]; then
  CICD_OPTS="${CICD_OPTS} -a";
  CICD_MIGRATIONS_OPTS="${CICD_MIGRATIONS_OPTS} -a";
fi
if [[ "${THUB_STATE}" =~ "destroy" ]]; then CICD_OPTS="${CICD_OPTS} -d"; fi
if [[ ! -z "${THUB_INCLUDE}" ]]; then CICD_OPTS="${CICD_OPTS} -I \"^(${THUB_INCLUDE})\""; fi
if [[ ! -z "${THUB_EXCLUDE}" ]]; then CICD_OPTS="${CICD_OPTS} -X \"^(${THUB_EXCLUDE})\""; fi

echo "EXEC: aws sts get-caller-identity"
AWS_ACCOUNT_ID="$(aws sts get-caller-identity --output=text --query='Account')"
terrahub configure -c template.locals.account_id="${AWS_ACCOUNT_ID}"

echo "EXEC: yarn install --production --frozen-lockfile"
yarn install --production --frozen-lockfile || { echo >&2 'failed yarn install in .'; exit 1; }

echo "EXEC: yarn run lint-all"
yarn run lint-all || { echo >&2 'failed yarn run lint-all'; exit 1; }

echo "EXEC: terrahub build ${CICD_BUILD_OPTS}"
terrahub build ${CICD_BUILD_OPTS} -X "^(lambda_rds_mysql|route53|rds_|redis_subnet|gateway_igw|security_group|ses_email|subnet|route_table|vpc)" \
  || { echo >&2 "terrahub build ${CICD_BUILD_OPTS}"; exit 1; }

echo "EXEC: export THUB_TOKEN"
export THUB_TOKEN="b29b3980-fef5-11e8-a520-1bd8e8cf7cb2"

echo "EXEC: terrahub configure"
terrahub configure -c project.distributor="lambda" \
  && terrahub configure -c terraform.backendAccount="cloudready" \
  && terrahub configure -c terraform.cloudAccount="cloudready" \
  || { echo >&2 "terrahub configure"; exit 1; }

echo "EXEC: terrahub run -y -p ignore ${CICD_OPTS}"
terrahub run -y -p ignore ${CICD_OPTS} -X "^(lambda_rds_mysql|route53|rds_|redis_subnet|gateway_igw|security_group|ses_email|subnet|route_table|vpc)" \
  || { echo >&2 "terrahub run -y -p ignore ${CICD_OPTS}"; exit 1; }

echo "EXEC: terrahub configure -D"
terrahub configure -c project.distributor -D -y \
  && terrahub configure -c terraform.cloudAccount -D -y \
  && terrahub configure -c terraform.backendAccount -D -y \
  || { echo >&2 "terrahub configure -D"; exit 1; }

echo "EXEC: terrahub run -y -b -p ignore ${CICD_MIGRATIONS_OPTS} -I lambda_rds_mysql_migrations"
terrahub run -y -b -p ignore ${CICD_MIGRATIONS_OPTS} -I "lambda_rds_mysql_migrations" \
  || { echo >&2 "terrahub run -y -b -p ignore ${CICD_MIGRATIONS_OPTS}"; exit 1; }
