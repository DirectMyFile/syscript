#!/usr/bin/env bash
set -e

source "$(dirname $0)/common.sh"

CONFIG_TARGET="nconfig"

if [[ "${@}" == *"-g"* ]]
then
  CONFIG_TARGET="gconfig"
fi

goto-kernel-dir
syscript apply-kernel-patches.sh
cp "${USER_CFG_DIR}/configs/kernel-config" .config
make ${CONFIG_TARGET}
cp .config "${USER_CFG_DIR}/configs/kernel-config"

if [[ "${@}" != *"-d"* ]]
then
  syscript update-kernel.sh
fi
