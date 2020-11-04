#! /bin/bash

set -e
set -o nounset
set -o pipefail

PREFIXES_TO_CLEAN=$AMENT_PREFIX_PATH
FW_TARGETDIR=$(pwd)/firmware
PREFIX=$(ros2 pkg prefix micro_ros_setup)

# Parse cli arguments
UROS_FAST_BUILD=off
UROS_VERBOSE_BUILD=off
for param in "$@"
do
  case $param in
    "-f")
        echo "Fast-Build active, ROS workspace will not be re-built!"
        UROS_FAST_BUILD=on
        shift
        ;;
      "-v")
        echo "Building in verbose mode"
        UROS_VERBOSE_BUILD=on
        shift
        ;;
  esac
done

export UROS_FAST_BUILD
export UROS_VERBOSE_BUILD

# Checking if firmware exists
if [ -d $FW_TARGETDIR ]; then
    RTOS=$(head -n1 $FW_TARGETDIR/PLATFORM)
    PLATFORM=$(head -n2 firmware/PLATFORM | tail -n1)
    if [ -f $FW_TARGETDIR/TRANSPORT ]; then
        TRANSPORT=$(head -n1 firmware/TRANSPORT)
    fi
else
    echo "Firmware folder not found. Please use ros2 run micro_ros_setup create_firmware_ws.sh to create a new project."
    exit 1
fi

# clean paths
. $(dirname $0)/clean_env.sh

# source dev_ws
if [ $RTOS != "host" ]; then
    set +o nounset
    . $FW_TARGETDIR/dev_ws/install/setup.bash
    set -o nounset
fi

# Building specific firmware folder
echo "Building firmware for $RTOS platform $PLATFORM"

if [ $PLATFORM != "generic" ] && [ -d "$PREFIX/config/$RTOS/generic" ]; then
    . $PREFIX/config/$RTOS/generic/build.sh
else
    . $PREFIX/config/$RTOS/$PLATFORM/build.sh
fi
