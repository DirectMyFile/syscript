#!/usr/bin/env bash
set -e

# shellcheck source=common.sh
source "$(dirname $0)/common.sh"

goto-kernel-dir

git fetch --all
git checkout "${KERNEL_BRANCH}"
git reset --hard "upstream/${KERNEL_BRANCH}"
git push origin "${KERNEL_BRANCH}" --force
