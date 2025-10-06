#!/bin/bash

PREFIX="/home/aghosn/Documents/Programs/openvmm/.packages/"
BINARIES="${PREFIX}/underhill-deps-private/x64/"
disk_path="C:\Users\adrienghosn\Documents\VirtualMachines\Ubuntu\VHDs\Ubuntu.vhdx"


#/mnt/c/openhcl/openvmm.exe -m 4GB -p 2 \
#  --uefi --uefi-firmware "${PREFIX}/hyperv.uefi.mscoreuefi.x64.RELEASE/MsvmX64/RELEASE_VS2022/FV/MSVM.fd" \
#  --disk file:$disk_path \
#  --halt-on-reset
#  --kernel "${BINARIES}/vmlinux" \
#  --initrd "${BINARIES}/initrd" \

#\
#  --uefi --uefi-firmware "${PREFIX}/hyperv.uefi.mscoreuefi.x64.RELEASE/MsvmX64/RELEASE_VS2022/FV/MSVM.fd"



/mnt/c/openhcl/openvmm.exe -m 4GB -p 2 \
  --disk 'file:C:\Users\adrienghosn\Documents\VirtualMachines\Ubuntu\VHDs\Ubuntu.vhdx' \
  --gfx --vmbus-com1-serial term --uefi-console-mode com1 \
  --uefi  --uefi-firmware "${PREFIX}/hyperv.uefi.mscoreuefi.x64.RELEASE/MsvmX64/RELEASE_VS2022/FV/MSVM.fd" \
  --halt-on-reset --log-file 'C:\openhcl\workers.log' --hv \
  --virtio-net dio 

# This works and uses the virtio_net:   --virtio-net dio
# This works and give hv_netvsc driver : --net dio 

## This works and give hv_netvsc driver: --nic
