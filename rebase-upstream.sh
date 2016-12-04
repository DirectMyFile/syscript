#!/usr/bin/env bash
set -e

# shellcheck source=common.sh
source "$(dirname $0)/common.sh"

goto-kernel-dir

git fetch --all
git checkout master
git reset --hard linus/master
git push origin master --force
