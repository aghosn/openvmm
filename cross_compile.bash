#!/bin/bash

# build & run script for openhcl testing with openvmm

set -e

args="-m 4GB -p 1"
copy_symbols=true
copy_remote=false
windows_temp="/mnt/c/openhcl/"
windows_temp_win="C:\openhcl"
remote_temp="\\\\<remote_computer>\\cross"
windows_enlistment="/mnt/c/openhcl/"
log_file="C:\openhcl\workers.log"

disk_path="C:\Users\adrienghosn\Documents\VirtualMachines\Ubuntu\VHDs\Ubuntu.vhdx"
uefi_firmware="$windows_temp_win\\MSVM.fd"

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <build|run|ohcldiag-dev> <x64|aarch64>..."
    exit 1
fi

if [[ $2 == "aarch64" ]]; then
    arch="aarch64"
    short_arch="aarch64"
elif [[ $2 == "x64" ]]; then
    arch="x86_64"
    short_arch="x64"
else
    echo "Unknown arch: $2"
    echo "Usage: $0 $1 <x64|aarch64>"
    exit 2
fi

uhdiag_path="$windows_temp_win\\uhdiag"
openvmm_path="$windows_temp/openvmm.exe"
windows_openvmm="$windows_temp/openvmm"
base_igvm="flowey-out/artifacts/build-igvm"
win_target="$arch-pc-windows-msvc"
base_win="target/$win_target/debug"

if [[ $1 == "build" || $1 == "run" ]]; then

    build_args="--target $arch-pc-windows-msvc"

    if [[ $3 == "vmm" ]]; then
        

        if [[ $4 == "uefi" ]]; then
            args+=" --uefi --uefi-firmware $uefi_firmware --disk file:$disk_path"
        elif [[ $4 == "linux" ]]; then
            args+=""
        else
            echo "Unknown load mode: $4"
            echo "Usage: $0 $1 $2 $3 <uefi|linux>"
            exit 2
        fi

    elif [[ $3 == "hcl" ]]; then

        if [[ $4 == "uefi" ]]; then
            recipe="$short_arch"
            args+=" --disk file:$disk_path --gfx --vmbus-com1-serial term --uefi-console-mode com1 --uefi"
        elif [[ $4 == "linux" ]]; then
            recipe="$short_arch-test-linux-direct"
            args+=" --vmbus-com1-serial term --vmbus-com2-serial term"
        else
            echo "Unknown load mode: $4"
            echo "Usage: $0 $1 $2 $3 <uefi|linux>"
            exit 2
        fi

        ohcl_name="openhcl-$recipe.bin"
        ohcl_path="$base_igvm/debug/$recipe"
        ohcl_symbols="openvmm_hcl"

        #--no-alias-map --net uh:consomme --vmbus-redirect
        # This works:  --no-alias-map --nic --vmbus-redirect
        # This works as well: --nic
        # --tpm doesn't work for some reason.
        # This works: --no-alias-map --nic --net vtl2:dio
        args+=" --halt-on-reset --log-file $log_file --hv --vtl2 --igvm $windows_temp_win\\$ohcl_name --virtio-net vtl2:dio --vmbus-redirect --vtl2-vsock-path $uhdiag_path --com3 term"

        echo "Building OpenHCL..."
        (
            set -x
            cargo xflowey build-igvm $recipe
        )

    else
        echo "Unknown package: $2"
        echo "Usage: $0 $1 <vmm|hcl>"
        exit 2
    fi

    echo

    if [[ $5 == "unstable" ]]; then
        build_args+=" --features unstable_whp"
    fi

    echo "Building openvmm..."
    (
        set -x
        cargo build $build_args
    )
    echo

    # Copy to Windows
    echo "Copying to windows"

    if [[ $3 == "hcl" ]]; then
        (
            set -x
            cp -u "$ohcl_path/$ohcl_name" "$windows_temp/$ohcl_name" -f
            mkdir -p "$windows_enlistment/$ohcl_path"
            cp -u "$ohcl_path/$ohcl_name" "$windows_enlistment/$ohcl_path/$ohcl_name" -f
        ) 
        if $copy_remote; then
            (
                set -x
                powershell.exe Copy-Item "$windows_temp_win\\$ohcl_name" "$remote_temp\\$ohcl_name" -Force
            )
        fi  
        if $copy_symbols; then
            (
                set -x
                cp -u "$ohcl_path/$ohcl_symbols" "$windows_temp/openvmm_hcl" -f
                cp -u "$ohcl_path/$ohcl_symbols.dbg" "$windows_temp/openvmm_hcl.dbg" -f
            )
        fi
    fi

    (
        set -x
        cp -u "$base_win/openvmm.exe" $openvmm_path -f
        mkdir -p "$windows_enlistment/$base_win"
        cp -u "$base_win/openvmm.exe" "$windows_enlistment/$base_win/openvmm.exe" -f
    )
    if $copy_remote; then
        (
            set -x
            powershell.exe Copy-Item "$windows_temp_win\\openvmm.exe" "$remote_temp\\openvmm.exe" -Force
        )
    fi
    if $copy_symbols; then
        (
            set -x
            cp -u "$base_win/openvmm.pdb" "$windows_temp/openvmm.pdb" -f
        )
    fi

    echo

    if [[ $1 == "run" ]]; then
        (
            set -x
            $openvmm_path $args
        )
    else
        echo $openvmm_path $args
    fi

elif [[ $1 == "ohcldiag-dev" ]]; then

    shift 2
    (
        set -x
        cargo build --target $arch-pc-windows-msvc -p ohcldiag-dev
        cp -u $base_win/ohcldiag-dev.exe "$windows_temp/ohcldiag-dev.exe" -f
        "$windows_temp/ohcldiag-dev.exe" "$uhdiag_path" "$@"
    )

else

    echo "Unknown command: $1"
    echo "Usage: $0 <build|run|ohcldiag-dev> <x64|aarch64>..."
    exit 1

fi
