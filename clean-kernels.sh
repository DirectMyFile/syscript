#!/usr/bin/env bash
set -e

# shellcheck source=common.sh
source "$(dirname $0)/common.sh"

syshook pre-clean-kernels-calculate

CURRENT=$(uname -r)
BUILT=$(strings ${KERNEL_DIR}/vmlinux | grep "Linux version" | awk '{print $3}')

# shellcheck disable=SC2010
REMOVE=$(ls /lib/modules | grep -v -e "${CURRENT}" -e "${BUILT}" -e "extramodules" | grep "\-DC" || true)

syshook pre-clean-kernels-remove

echo "Removing old kernels..."
for VERSION in ${REMOVE}
do
  echo "Removing ${VERSION}..."
  sudo rm -rf "/lib/modules/${VERSION}"
  sudo rm -rf "/usr/lib/modules/${VERSION}"
  syshook clean-kernels-remove-version "${VERSION}"
done

syshook post-clean-kernels-remove
