#!/bin/bash

echo "🐍 Setting up Clarvynn Flask Demo Environment"
echo "============================================="

# Check Python version
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed."
    echo "   Please install Python 3.8+ and try again."
    exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
echo "✅ Found Python $PYTHON_VERSION"

# Create virtual environment
if [ -d "clarvynn-demo-env" ]; then
    echo "📁 Virtual environment already exists"
    read -p "   Remove and recreate? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf clarvynn-demo-env
        echo "   🗑️  Removed existing environment"
    else
        echo "   ℹ️  Using existing environment"
    fi
fi

if [ ! -d "clarvynn-demo-env" ]; then
    echo "🔧 Creating virtual environment..."
    python3 -m venv clarvynn-demo-env
    echo "   ✅ Virtual environment created"
fi

# Activate virtual environment
echo "🔌 Activating virtual environment..."
source clarvynn-demo-env/bin/activate

# Upgrade pip
echo "📦 Upgrading pip..."
pip install --upgrade pip > /dev/null 2>&1

# Install Flask dependencies
echo "📦 Installing Flask dependencies..."
pip install -r clarvynn_examples/requirements.txt

echo ""
echo "✅ Setup completed successfully!"
echo ""
echo "🚀 Next steps:"
echo "   1. Activate the environment: source clarvynn-demo-env/bin/activate"
echo "   2. Install Clarvynn binary (download from Clarvynn releases)"
echo "   3. Start the LGTM stack: ./run-clarvynn-demo.sh"
echo "   4. Run the Flask services with Clarvynn instrumentation"
echo ""
echo "📖 See CLARVYNN_DEMO.md for complete instructions" 