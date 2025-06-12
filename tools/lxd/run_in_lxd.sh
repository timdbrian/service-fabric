#!/bin/bash

print_help() {
    cat <<EOF2
Usage:
run_in_lxd.sh [-h] <ubuntu|ubuntu18|centos> <command_to_run>
    -h, --help: Displays this help text

Runs a command inside the Service Fabric LXD container

Example:
    run_in_lxd.sh ubuntu "/src/build.sh"
EOF2
}

if [ "$#" -lt 2 ]; then
    echo -e "Missing parameters.\n"
    print_help
    exit -1
fi

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    print_help
    exit 0
fi

CDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TARGET_OS="$1"
CAPS_OS_NAME=$(echo "$TARGET_OS" | awk '{print toupper($0)}')
REPOROOT="$CDIR/../../"
IMAGE_VERSION=$(cat "$REPOROOT/tools/build/${CAPS_OS_NAME}IMAGE_VERSION")
FULL_IMAGE_NAME="microsoft/service-fabric-build-${TARGET_OS}"

OUT_DIR="$REPOROOT/out.${TARGET_OS}"
mkdir -p "$OUT_DIR"

CONTAINER_NAME="sf-build-${TARGET_OS}-$$"
cmd=$2

# Ensure the required image exists locally
if ! lxc image info "$FULL_IMAGE_NAME:$IMAGE_VERSION" >/dev/null 2>&1; then
    echo "Image $FULL_IMAGE_NAME:$IMAGE_VERSION not found locally."
    echo "Checking Docker Hub via LXD's docker remote..."
    if ! lxc image copy "docker:$FULL_IMAGE_NAME:$IMAGE_VERSION" local: --alias "$FULL_IMAGE_NAME:$IMAGE_VERSION" >/dev/null 2>&1; then
        echo "Image not available on Docker Hub. Building locally..."
        if ! command -v docker >/dev/null 2>&1; then
            echo "Docker is required to build the container image locally but was not found." >&2
            echo "Install Docker or pre-load the image then retry." >&2
            exit 1
        fi
        # Ensure the docker remote exists for importing the built image
        if ! lxc remote list | grep -q '^docker\s'; then
            lxc remote add docker docker:// >/dev/null 2>&1 || {
                echo "Failed to add LXD docker remote." >&2
                exit 1
            }
        fi
        "$REPOROOT/tools/build/builddocker.sh" "$TARGET_OS"
        lxc image copy "docker:$FULL_IMAGE_NAME:latest" local: --alias "$FULL_IMAGE_NAME:$IMAGE_VERSION"
    fi
fi

# launch ephemeral container
lxc launch "$FULL_IMAGE_NAME:$IMAGE_VERSION" "$CONTAINER_NAME" --ephemeral >/dev/null

lxc config device add "$CONTAINER_NAME" out disk source="$OUT_DIR" path=/out >/dev/null
lxc config device add "$CONTAINER_NAME" external disk source="$REPOROOT/external" path=/external >/dev/null
lxc config device add "$CONTAINER_NAME" deps disk source="$REPOROOT/deps" path=/deps >/dev/null
lxc config device add "$CONTAINER_NAME" src disk source="$REPOROOT/src" path=/src >/dev/null
lxc config device add "$CONTAINER_NAME" config disk source="$REPOROOT/.config" path=/.config >/dev/null
lxc config device add "$CONTAINER_NAME" scripts disk source="$REPOROOT/tools/ci/scripts" path=/scripts >/dev/null

echo -e "Running command:\n\t'$cmd'\n" "in LXD container $CONTAINER_NAME using image $FULL_IMAGE_NAME:$IMAGE_VERSION"
lxc exec "$CONTAINER_NAME" -- bash -c "$cmd"

# container will be removed automatically because it is ephemeral
