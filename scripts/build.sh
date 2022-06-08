#!/bin/bash

# Source Configs
source $CONFIG

# Change to the Source Directry
cd $SYNC_PATH

# Set-up ccache
if [ -z "$CCACHE_SIZE" ]; then
    ccache -M 10G
else
    ccache -M ${CCACHE_SIZE}
fi

# Prepare the Build Environment
source build/envsetup.sh

# Run the Extra Command
$EXTRA_CMD

# export some Basic Vars
export ALLOW_MISSING_DEPENDENCIES=true

#Neutron Clang 15
if [[ $OF_USE_NEUTRON_CLANG = "true" || $OF_USE_NEUTRON_CLANG = "1" ]]; then
    echo "Using the Latest Release Neutron Clang to build kernel..."
fi

# lunch the target
    lunch twrp_${DEVICE}-eng || { echo "ERROR: Failed to lunch the target!" && exit 1; }

# Build the Code
if [ -z "$J_VAL" ]; then
    mka -j$(nproc --all) $TARGET || { echo "ERROR: Failed to Build TWRP!" && exit 1; }
elif [ "$J_VAL"="0" ]; then
    mka $TARGET || { echo "ERROR: Failed to Build TWRP!" && exit 1; }
else
    mka -j${J_VAL} $TARGET || { echo "ERROR: Failed to Build TWRP!" && exit 1; }
fi

# Exit
exit 0
