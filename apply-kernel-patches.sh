#!/usr/bin/env bash
set -e

cd ${KERNEL_DIR}
git checkout master
git reset --hard origin/master
for PATCH in $(ls ${SCRIPTS}/patches)
do
  echo "[Apply Patch] ${PATCH}"
  git apply ${SCRIPTS}/patches/${PATCH}
done

