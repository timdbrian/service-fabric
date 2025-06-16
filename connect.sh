#!/bin/bash
# Creates a new container from the build environment image
# and drops you into an interactive prompt.
# From there you can run a build via the build script directly
# by going to /out and running /src/build.sh.

PrintUsage()
{
    cat <<EOF
This tool will launch a build container and drop you into a bash prompt.

connect.sh [-h]

  -h, --help: Show this help screen and exit
EOF
}

while (( "$#" )); do
    if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
        PrintUsage
        exit -1
    else
        echo "Unexpected option $1"
        PrintUsage
        exit -2
    fi
done

# change directory to the one containing this script and
# record this directories full path.
CDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
IMAGE_VERSION=$(cat "$CDIR"/tools/build/UBUNTUIMAGE_VERSION)
echo "Running container version $IMAGE_VERSION"

$CDIR/tools/lxd/run_in_lxd.sh ubuntu "bash -i"
