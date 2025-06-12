#!/bin/bash

print_help() {
    cat <<EOF_HELP
Usage:
run_in_lxd.sh [-h] <ubuntu|ubuntu18|centos> <command_to_run>
    -h, --help: Displays this help text

Runs a command inside the Service Fabric LXD container. If the container image
is not found it will be created automatically using an upstream distribution
image and the Service Fabric preparation scripts.
EOF_HELP
}

if [ "$#" -lt 2 ]; then
    echo -e "Missing parameters.\n"
    print_help
    exit 1
fi

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    print_help
    exit 0
fi

TARGET_OS="$1"
CMD="$2"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$SCRIPT_DIR/../../"
CAPS_OS_NAME=$(echo "$TARGET_OS" | awk '{print toupper($0)}')
IMAGE_VERSION=$(cat "$REPO_ROOT/tools/build/${CAPS_OS_NAME}IMAGE_VERSION")
IMAGE_NAME="microsoft/service-fabric-build-${TARGET_OS}"
CONTAINER_NAME="sf-build-${TARGET_OS}-$$"
OUT_DIR="$REPO_ROOT/out.${TARGET_OS}"
mkdir -p "$OUT_DIR"

# Ensure LXD is installed and initialized
if ! command -v lxc >/dev/null 2>&1; then
    if command -v apt-get >/dev/null 2>&1; then
        echo "LXD not found. Installing via apt-get..."
        sudo apt-get update && sudo apt-get install -y lxd || {
            echo "Failed to install LXD" >&2
            exit 1
        }
    else
        echo "LXD is required but not installed." >&2
        exit 1
    fi
fi

if ! lxc info >/dev/null 2>&1; then
    echo "Initialising LXD..."
    sudo lxd init --auto || {
        echo "Failed to initialise LXD" >&2
        exit 1
    }
fi

build_image() {
    local base_image prep_script build_container
    case "$TARGET_OS" in
        ubuntu)
            base_image="images:ubuntu/16.04"
            prep_script="$REPO_ROOT/tools/build/sf-prep.sh"
            ;;
        ubuntu18)
            base_image="images:ubuntu/18.04"
            prep_script="$REPO_ROOT/tools/build/sf-prep-1804.sh"
            ;;
        centos)
            base_image="images:centos/7"
            prep_script=""
            ;;
        *)
            echo "Unsupported OS $TARGET_OS" >&2
            exit 1
            ;;
    esac

    build_container="sf-image-${TARGET_OS}-$$"
    echo "Creating build image $IMAGE_NAME:$IMAGE_VERSION from $base_image..."
    lxc launch "$base_image" "$build_container" || exit 1

    if [ -n "$prep_script" ]; then
        lxc file push "$prep_script" "$build_container"/root/ || exit 1
        lxc exec "$build_container" -- bash "/root/$(basename $prep_script)" || {
            echo "Failed to prepare container" >&2
            lxc delete "$build_container" --force
            exit 1
        }
    fi

    lxc exec "$build_container" -- apt-get clean >/dev/null 2>&1 || true
    lxc snapshot "$build_container" clean
    lxc publish "$build_container/clean" --alias "$IMAGE_NAME:$IMAGE_VERSION" >/dev/null
    lxc delete "$build_container" --force
}

# Build image if missing
if ! lxc image info "$IMAGE_NAME:$IMAGE_VERSION" >/dev/null 2>&1; then
    build_image
fi

# Launch ephemeral container for the build
lxc launch "$IMAGE_NAME:$IMAGE_VERSION" "$CONTAINER_NAME" --ephemeral >/dev/null

lxc config device add "$CONTAINER_NAME" out disk source="$OUT_DIR" path=/out >/dev/null
lxc config device add "$CONTAINER_NAME" external disk source="$REPO_ROOT/external" path=/external >/dev/null
lxc config device add "$CONTAINER_NAME" deps disk source="$REPO_ROOT/deps" path=/deps >/dev/null
lxc config device add "$CONTAINER_NAME" src disk source="$REPO_ROOT/src" path=/src >/dev/null
lxc config device add "$CONTAINER_NAME" config disk source="$REPO_ROOT/.config" path=/.config >/dev/null
lxc config device add "$CONTAINER_NAME" scripts disk source="$REPO_ROOT/tools/ci/scripts" path=/scripts >/dev/null

echo -e "Running command:\n\t'$CMD'\n" "in LXD container $CONTAINER_NAME using image $IMAGE_NAME:$IMAGE_VERSION"
lxc exec "$CONTAINER_NAME" -- bash -c "$CMD"
# Container will be removed automatically when command exits
