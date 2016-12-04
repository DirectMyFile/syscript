#!/usr/bin/env bash
set -e

SCRIPTS=$(realpath $(dirname $0))

########################################
# System Scripts Default Configuration #
########################################

BUILD_JOBS="32"
KERNEL_DIR="$(dirname ${SCRIPTS})/Kernel"
KERNEL_SUFFIX="dc"
KERNEL_CC="gcc"
USE_CCACHE="true"
USER_CFG_DIR="${SCRIPTS}"
BUNDLES=()

if [ -f "${USER_CFG_DIR}/configs/syscript.sh" ]
then
  source "${USER_CFG_DIR}/configs/syscript.sh"
fi

echo "[Kernel Directory] ${KERNEL_DIR}"

if [ "${USE_CCACHE}" == "true" ] && which ccache > /dev/null 2>&1
then
  KERNEL_CC="ccache ${KERNEL_CC}"
  echo "[CCache] Configured."
fi

########################################
#    System Scripts Common Library     #
########################################

syscript() {
  SCRIPT="${1}"
  shift
  ${SCRIPTS}/${SCRIPT} "${@}"
}

fetch-apply-patch() {
  URL="${1}"
  shift
  FILE=$(mktemp /tmp/syscript-patch.XXXXXX)
  curl "${URL}" > ${FILE}
  echo "[Apply Patch] ${URL}"
  git apply "${FILE}" "${@}"
  rm "${FILE}"
}

source-if-exists() {
  SCRIPT="${1}"
  if [ -f "${SCRIPT}" ]
  then
    source "${SCRIPT}"
  fi
}

goto-dir() {
  DIR="${1}"
  if [ ! -d "${DIR}" ]
  then
    echo "[Change Directory] Directory at ${DIR} does not exist."
  fi
  pushd "${DIR}" > /dev/null
}

goto-kernel-dir() {
  goto-dir "${KERNEL_DIR}"
}

syshook() {
  HOOK="${1}"
  shift
  if [ -x "${USER_CFG_DIR}/hooks/${HOOK}" ]
  then
    echo "[Hook] ${HOOK}"
    "${USER_CFG_DIR}/hooks/${HOOK}" "${@}"
  fi

  for BUNDLE in ${BUNDLES[@]}
  do
    source-if-exists "${SCRIPTS}/bundles/bundle/${HOOK}"
  done
}

export SCRIPTS KERNEL_DIR BUILD_JOBS KERNEL_SUFFIX KERNEL_CC USER_CFG_DIR BUNDLES
