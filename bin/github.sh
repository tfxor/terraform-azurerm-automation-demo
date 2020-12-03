#!/usr/bin/env bash

if [[ ! -z "${CODEBUILD_SOURCE_REPO_URL}" ]]; then
  if [[ -z "${GITHUB_ORGANIZATION}" ]]; then GITHUB_ORGANIZATION="$(echo ${CODEBUILD_SOURCE_REPO_URL} | cut -d/ -f4)"; fi
  if [[ -z "${GITHUB_REPO}" ]]; then GITHUB_REPO="$(echo ${CODEBUILD_SOURCE_REPO_URL} | cut -d/ -f5 | cut -d. -f1)"; fi
fi

# if [[ -z "${GITHUB_TOKEN}" ]]; then echo "[ERROR]: GITHUB_TOKEN is missing. aborting..."; exit 1; fi
# if [[ -z "${GITHUB_ORGANIZATION}" ]]; then echo "[ERROR]: GITHUB_ORGANIZATION is missing. aborting..."; exit 1; fi
# if [[ -z "${GITHUB_REPO}" ]]; then echo "[ERROR]: GITHUB_REPO is missing. aborting..."; exit 1; fi

# git --version > /dev/null 2>&1 || { echo >&2 "git is missing. aborting..."; exit 1; }
# git clone https://${GITHUB_TOKEN}:x-oauth-basic@github.com/${GITHUB_ORGANIZATION}/${GITHUB_REPO}.git
# cd $(echo ${GITHUB_REPO} | cut -d/ -f2)

echo "EXEC: rm -rf .git/refs/pull"
rm -rf .git/refs/pull

if [[ ! -z "${BRANCH_TO}" ]]; then
  echo "EXEC: git checkout ${BRANCH_TO}"
  git checkout ${BRANCH_TO}
elif [[ ! -z "${CODEBUILD_WEBHOOK_BASE_REF}" ]]; then
  echo "EXEC: git checkout ${CODEBUILD_WEBHOOK_BASE_REF/refs\/heads\//}"
  git checkout ${CODEBUILD_WEBHOOK_BASE_REF/refs\/heads\//}
fi

if [[ ! -z "${BRANCH_FROM}" ]]; then
  echo "EXEC: git checkout ${BRANCH_FROM}"
  git checkout ${BRANCH_FROM}
elif [[ ! -z "${CODEBUILD_WEBHOOK_HEAD_REF}" ]]; then
  echo "EXEC: git checkout ${CODEBUILD_WEBHOOK_HEAD_REF/refs\/heads\//}"
  git checkout ${CODEBUILD_WEBHOOK_HEAD_REF/refs\/heads\//}
fi
