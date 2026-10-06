#!/bin/sh
#
# Setup script for garmin-connect-export
# Creates a Python 2 virtual environment and verifies the script
# can be loaded (gcexport.py uses the Python 2 standard library only,
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

find_python2() {
    if command -v python2 >/dev/null 2>&1; then
        command -v python2
    elif command -v python >/dev/null 2>&1; then
        PY="$(command -v python)"
        if "$PY" -c 'import sys; sys.exit(0 if sys.version_info[0] == 2 else 1)'; then
            echo "$PY"
        fi
    fi
}

PYTHON2="$(find_python2)"

if [ -z "$PYTHON2" ]; then
    echo "Error: no Python 2 interpreter found."
    echo "gcexport.py requires Python 2 (it uses urllib2, cookielib and the sets module)."
    echo "Install Python 2, e.g. on Debian/Ubuntu: sudo apt-get install python2 python2-virtualenv"
    exit 1
fi

echo "Using Python 2 interpreter: $PYTHON2"

if [ -d "$SCRIPT_DIR/$VENV_DIR" ]; then
    echo "Virtual environment '$VENV_DIR' already exists, reusing it."
else
    echo "Creating virtual environment '$VENV_DIR'..."
    if "$PYTHON2" -m virtualenv "$SCRIPT_DIR/$VENV_DIR" 2>/dev/null; then
        :
    elif "$PYTHON2" -m pip >/dev/null 2>&1 && "$PYTHON2" -m pip install --user virtualenv >/dev/null 2>&1; then
        "$PYTHON2" -m virtualenv "$SCRIPT_DIR/$VENV_DIR"
    else
        echo "Error: virtualenv is not available for Python 2."
        echo "Install it with: $PYTHON2 -m pip install virtualenv"
        exit 1
    fi
fi

# gcexport.py only uses the Python 2 standard library, so there is
# nothing to pip-install. Verify the script compiles instead.
echo "Verifying gcexport.py..."
"$SCRIPT_DIR/$VENV_DIR/bin/python" -m py_compile "$SCRIPT_DIR/gcexport.py"

cat <<EOF

Setup complete.

To use gcexport.py, activate the virtual environment first:

    . $VENV_DIR/bin/activate
    python gcexport.py --help

EOF
