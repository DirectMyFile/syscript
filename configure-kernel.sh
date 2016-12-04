#!/usr/bin/env bash
set -e

# shellcheck source=common.sh
source "$(dirname $0)/common.sh"

CONFIG_TARGET="nconfig"

if [[ "${@}" == *"-g"* ]]
then
  CONFIG_TARGET="gconfig"
fi

goto-kernel-dir
syscript apply-kernel-patches.sh
cp "${USER_CFG_DIR}/configs/kernel-config" .config

# shellcheck disable=SC2153
for BUNDLE in "${BUNDLES[@]}"
do
  BUNDLE_PATH="${SCRIPTS}/bundles/${BUNDLE}"
  if [ -f "${BUNDLE_PATH}/kernel-config-options" ]
  then
    echo "[Apply Bundle Kernel Options] ${BUNDLE}"
    cat "${BUNDLE_PATH}/kernel-config-options" >> .config
  fi
done

make olddefconfig

make ${CONFIG_TARGET}
cp .config "${USER_CFG_DIR}/configs/kernel-config"

if [[ "${@}" != *"-d"* ]]
then
  syscript update-kernel.sh
fi
