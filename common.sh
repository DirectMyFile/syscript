#!/usr/bin/env bash
set -e

SCRIPTS=$(realpath $(dirname $0))

########################################
# System Scripts Default Configuration #
########################################
BUILD_JOBS="16"
KERNEL_DIR="$(dirname ${SCRIPTS})/Kernel"
KERNEL_SUFFIX="dc"

echo "Kernel Directory: ${KERNEL_DIR}"

if [ -f ${SCRIPTS}/configs/syscript.sh ]
then
  source ${SCRIPTS}/syscript.sh
fi

########################################
#    System Scripts Common Library     #
########################################

syscript() {
  SCRIPT="${1}"
  shift
  ${SCRIPTS}/${SCRIPT} "${@}"
}

syshook() {
  HOOK="${1}"
  shift
  if [ -x "${SCRIPTS}/hooks/${HOOK}" ]
  then
    ${SCRIPTS}/hooks/${HOOK} "${@}"
  fi
}

export SCRIPTS KERNEL_DIR BUILD_JOBS KERNEL_SUFFIX
