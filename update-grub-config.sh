#!/usr/bin/env bash
set -e

# shellcheck source=common.sh
source "$(dirname $0)/common.sh"

syshook pre-update-grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
syshook post-update-grub
