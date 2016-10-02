#!/usr/bin/env bash
set -e

source "$(dirname $0)/common.sh"

CONFIG_TARGET="nconfig"

if [[ "${@}" == *"-g"* ]]
then
  CONFIG_TARGET="gconfig"
fi

cd ${KERNEL_DIR}
syscript apply-kernel-patches.sh
cp ${SCRIPTS}/configs/kernel-config .config
make ${CONFIG_TARGET}
cp .config ${SCRIPTS}/configs/kernel-config

if [[ "${@}" != *"-d"* ]]
then
  syscript update-kernel.sh
fi

