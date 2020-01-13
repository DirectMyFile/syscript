#!/usr/bin/env bash
set -e

# shellcheck source=common.sh
source "$(dirname $0)/common.sh"

goto-kernel-dir

sudo make clean
sudo make mrproper

syshook pre-update-kernel
syshook pre-update-kernel-pull-changes
git checkout "${KERNEL_BRANCH}"
git pull
syshook post-update-kernel-pull-changes

syscript apply-kernel-patches.sh
sudo rm -rf .config
cp "${USER_CFG_DIR}/configs/kernel-config" .config

syshook post-update-kernel-copy-config

git add .
git commit -m "Prepare for Kernel Build" || true

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
make prepare
syshook post-update-kernel-update-config
cp "${USER_CFG_DIR}/configs/kernel-config" "${USER_CFG_DIR}/configs/kernel-config-bak"
cp .config "${USER_CFG_DIR}/configs/kernel-config"

syshook post-update-kernel-apply-config
make ARCH="$(uname -m)" CC="${KERNEL_CC}" -j ${BUILD_JOBS}
syshook post-update-kernel-make

git reset --hard "origin/${KERNEL_BRANCH}"

KERNEL_VERSION=$(strings vmlinux | grep "Linux version" | awk '{print $3}')

sudo make modules_install
#sudo make headers_install
sudo cp -v arch/x86/boot/bzImage "/boot/vmlinuz-linux-${KERNEL_SUFFIX}"
sudo mkinitcpio -p "linux-${KERNEL_SUFFIX}"
sudo cp System.map "/boot/System.map-${KERNEL_SUFFIX}"
syshook post-update-kernel-tasks

echo "[Updated Kernel] ${KERNEL_VERSION}"
syshook post-update-kernel
