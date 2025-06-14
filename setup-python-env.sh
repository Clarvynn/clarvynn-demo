#!/bin/bash

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 is required but not installed."
    echo "Please install Python 3.8+ and try again."
    exit 1
fi

PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
echo "Found Python $PYTHON_VERSION"

# Check if virtual environment already exists
if [ -d "clarvynn-demo-env" ]; then
    echo "Virtual environment already exists."
    echo ""
    echo "To activate it, run:"
    echo "   source clarvynn-demo-env/bin/activate"
    echo ""
    echo "Then run Flask services as described in CLARVYNN_DEMO.md"
    exit 0
fi

# Create virtual environment
echo "Creating virtual environment..."
python3 -m venv clarvynn-demo-env
echo "   Virtual environment created"

# Activate virtual environment
source clarvynn-demo-env/bin/activate

# Check if activation worked
if [ -z "$VIRTUAL_ENV" ]; then
    echo "ERROR: Failed to activate virtual environment"
    exit 1
fi

echo "Upgrading pip..."
pip install --upgrade pip > /dev/null 2>&1

echo "Installing Flask dependencies..."
pip install flask gunicorn uwsgi > /dev/null 2>&1

echo "Setup completed successfully!"
echo ""
echo "Next steps:"
echo "   1. Activate the environment: source clarvynn-demo-env/bin/activate"
echo "   2. Install Clarvynn binary (see CLARVYNN_DEMO.md)"
echo "   3. Run Flask services with Clarvynn instrumentation"
echo ""
echo "See CLARVYNN_DEMO.md for complete instructions" 