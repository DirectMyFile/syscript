#!/usr/bin/env bash
set -e

source "$(dirname $0)/common.sh"

CURRENT=$(uname -r)
BUILT=$(strings ${KERNEL_DIR}/vmlinux | grep "Linux version" | awk '{print $3}')
REMOVE=$(ls /lib/modules | grep -v -e "${CURRENT}" -e "${BUILT}" -e "extramodules" | grep "\-DC" || true)

echo "Removing old kernels..."
for VERSION in ${REMOVE}
do
  echo "Removing ${VERSION}..."
  sudo rm -rf "/lib/modules/${VERSION}"
  sudo rm -rf "/usr/lib/modules/${VERSION}"
done
