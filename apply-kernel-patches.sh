#!/usr/bin/env bash
set -e

cd ${KERNEL_DIR}

syshook pre-kernel-patch
git checkout master
git reset --hard origin/master
for PATCH in $(ls ${SCRIPTS}/patches)
do
  echo "[Apply Patch] ${PATCH}"
  syshook pre-apply-kernel-patch ${PATCH}
  git apply ${SCRIPTS}/patches/${PATCH}
  syshook post-apply-kernel-patch ${PATCH}
done
syshook kernel-patch
syshook post-kernel-patch

