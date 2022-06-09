#!/bin/bash

# Source Vars
source $CONFIG

# Make Required Sync Folders
cd ~
mkdir work
cd work
mkdir twrp

# Sync TWRP sources
cd $SYNC_PATH
repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp -b $TWRP_BRANCH  || { echo "ERROR: Failed to Sync TWRP Sources!" && exit 1; }

#Clone TWRP source
repo sync

#Clone required patches for twrp-12.1
if [ "$TWRP_BRANCH" = "twrp-12.1" ]; then
    echo "Cloning required patches for twrp to build..."
    cd system/vold 
	git fetch https://gerrit.twrp.me/android_system_vold refs/changes/40/5540/3 && git cherry-pick FETCH_HEAD
	cd $SYNC_PATH/bootable/recovery
	git fetch https://gerrit.twrp.me/android_bootable_recovery refs/changes/05/5405/20 && git cherry-pick FETCH_HEAD    
fi

# Change to the Source Directory
cd $SYNC_PATH

# Clone Trees
git clone $DT_LINK $DT_PATH || { echo "ERROR: Failed to Clone the Device Trees!" && exit 1; }

# Clone the Kernel Sources
# only if the Kernel Source is Specified in the Config
[ ! -z "$KERNEL_SOURCE" ] && git clone --depth=1 --single-branch $KERNEL_SOURCE $KERNEL_PATH

# Neutron Clang
if [[ $OF_USE_NEUTRON_CLANG = "true" || $OF_USE_NEUTRON_CLANG = "1" ]]; then
	echo "Downloading the Latest Release of Neutron Clang..."
    cd $SYNC_PATH/prebuilts/clang/host/linux-x86
    git clone https://gitlab.com/dakkshesh07/neutron-clang.git -b Neutron-15 $CUSTOM_CLANG_FOLDER
    echo "Neutron Clang Downloaded Successfully"
	cd $SYNC_PATH >/dev/null
	echo "Done!"
fi


# Proton Clang
if [[ $OF_USE_PROTON_CLANG = "true" || $OF_USE_PROTON_CLANG = "1" ]]; then
	echo "Downloading the Latest Release of Proton Clang..."
    cd $SYNC_PATH/prebuilts/clang/host/linux-x86
    git clone https://github.com/kdrag0n/proton-clang.git -b master $CUSTOM_CLANG_FOLDER
    echo "Proton Clang Downloaded Successfully"
	cd $SYNC_PATH >/dev/null
	echo "Done!"
fi

# Exit
exit 0
