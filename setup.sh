#!/bin/sh
#
# Setup script for garmin-connect-export
# Creates a Python 3 virtual environment and verifies the script
# compiles (gcexport.py uses the Python 3 standard library only,
# so no additional packages need to be installed).
#
# Usage:
#   ./setup.sh [venv-directory]
#
# After running, activate the environment with:
#   . <venv-directory>/bin/activate

set -e

VENV_DIR="${1:-venv}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

find_python3() {
    if command -v python3 >/dev/null 2>&1; then
        command -v python3
    elif command -v python >/dev/null 2>&1; then
        PY="$(command -v python)"
        if "$PY" -c 'import sys; sys.exit(0 if sys.version_info[0] == 3 else 1)'; then
            echo "$PY"
        fi
    fi
}

PYTHON3="$(find_python3)"

if [ -z "$PYTHON3" ]; then
    echo "Error: no Python 3 interpreter found."
    echo "gcexport.py requires Python 3 (it uses urllib.request and http.cookiejar)."
    echo "Install Python 3, e.g. on Debian/Ubuntu: sudo apt-get install python3 python3-venv"
    exit 1
fi

echo "Using Python 3 interpreter: $PYTHON3"

if [ -d "$SCRIPT_DIR/$VENV_DIR" ]; then
    echo "Virtual environment '$VENV_DIR' already exists, reusing it."
else
    echo "Creating virtual environment '$VENV_DIR'..."
    "$PYTHON3" -m venv "$SCRIPT_DIR/$VENV_DIR"
fi

# gcexport.py only uses the Python 3 standard library, so there is
# nothing to pip-install. Verify the script compiles instead.
echo "Verifying gcexport.py..."
"$SCRIPT_DIR/$VENV_DIR/bin/python" -m py_compile "$SCRIPT_DIR/gcexport.py"

cat <<EOF

Setup complete.

To use gcexport.py, activate the virtual environment first:

    . $VENV_DIR/bin/activate
    python gcexport.py --login   # interactive login (with 2FA support), stores the session token
    python gcexport.py --help

EOF
