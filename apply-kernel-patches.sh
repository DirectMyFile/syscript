#!/usr/bin/env bash
set -e

source "$(dirname $0)/common.sh"

goto-kernel-dir

syshook pre-kernel-patch
git checkout master
git reset --hard origin/master
for PATCH in $(ls "${USER_CFG_DIR}"/patches/*.patch)
do
  PATCH="$(realpath --relative-to=${USER_CFG_DIR}/patches ${PATCH})"
  echo "[Apply Patch] ${PATCH}"
  syshook pre-apply-kernel-patch ${PATCH}
  git apply "${USER_CFG_DIR}/patches/${PATCH}"
  syshook post-apply-kernel-patch ${PATCH}
done

syshook kernel-patch
syshook post-kernel-patch
