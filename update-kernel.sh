#!/usr/bin/env bash
set -e

source "$(dirname $0)/common.sh"

cd ${KERNEL_DIR}
git checkout master
git pull
 
syscript apply-kernel-patches.sh
cp ${SCRIPTS}/configs/kernel-config .config

git add .
git commit -m "Prepare for Kernel Build"

make -j ${BUILD_JOBS}

git reset --hard origin/master

KERNEL_VERSION=$(strings vmlinux | grep "Linux version" | awk '{print $3}')

sudo make modules_install
sudo make headers_install
sudo cp -v arch/x86/boot/bzImage /boot/vmlinuz-linux-${KERNEL_SUFFIX}
sudo mkinitcpio -p linux-${KERNEL_SUFFIX}
sudo cp System.map /boot/System.map-${KERNEL_SUFFIX}
syscript update-grub-config.sh
sudo dkms autoinstall

echo "Built kernel ${KERNEL_VERSION}"

