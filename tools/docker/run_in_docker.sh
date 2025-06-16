#!/bin/bash
# Wrapper for backward compatibility. Uses LXD implementation.
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
exec "$SCRIPT_DIR/../lxd/run_in_lxd.sh" "$@"
