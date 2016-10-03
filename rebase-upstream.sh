#!/usr/bin/env bash
set -e

source "$(dirname $0)/common.sh"

cd ${KERNEL_DIR}

git fetch --all
git checkout master
git reset --hard linus/master
git push origin master --force

