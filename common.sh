#!/usr/bin/env bash
set -e

SCRIPTS=$(realpath "$(dirname $0)")

########################################
# System Scripts Default Configuration #
########################################

BUILD_JOBS="32"
KERNEL_DIR="$(dirname ${SCRIPTS})/Kernel"
KERNEL_SUFFIX="syscript"
KERNEL_CC="gcc"
USE_CCACHE="true"
USER_CFG_DIR="${SCRIPTS}"

if [ -d "$(dirname ${SCRIPTS})/Configs" ]
then
  USER_CFG_DIR="$(dirname ${SCRIPTS})/Configs"
fi

if [ -d "$(dirname ${SCRIPTS})/UserConfigs" ]
then
  USER_CFG_DIR="$(dirname ${SCRIPTS})/UserConfigs"
fi

if [ -d "$(dirname ${SCRIPTS}/KernelConfigs)" ]
then
  USER_CFG_DIR="$(dirname ${SCRIPTS})/KernelConfigs"
fi

BUNDLES=()

if [ -f "${USER_CFG_DIR}/configs/syscript.sh" ]
then
  # shellcheck disable=SC1090
  source "${USER_CFG_DIR}/configs/syscript.sh"
fi

if [ -f "${USER_CFG_DIR}/configs/syscript" ]
then
  # shellcheck disable=SC1090
  source "${USER_CFG_DIR}/configs/syscript"
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
  curl --silent "${URL}" > ${FILE}
  echo "[Apply Patch] ${URL}"
  git apply --ignore-whitespace "${FILE}" "${@}"
  rm "${FILE}"
}

source-if-exists() {
  SCRIPT="${1}"
  if [ -f "${SCRIPT}" ]
  then
    # shellcheck disable=SC1090
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

  for BUNDLE in "${BUNDLES[@]}"
  do
    source-if-exists "${SCRIPTS}/bundles/${BUNDLE}/${HOOK}"
  done
}

export SCRIPTS KERNEL_DIR BUILD_JOBS KERNEL_SUFFIX KERNEL_CC USER_CFG_DIR BUNDLES
