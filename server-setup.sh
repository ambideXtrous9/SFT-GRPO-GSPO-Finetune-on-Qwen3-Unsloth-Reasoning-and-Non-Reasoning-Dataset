#!/usr/bin/env bash

set -e

echo "=========================================="
echo " GRPO Environment Setup"
echo "=========================================="

# --------------------------------------------------
# 0. Check sudo
# --------------------------------------------------

if ! command -v sudo &> /dev/null; then
    echo "ERROR: sudo is required."
    exit 1
fi

# --------------------------------------------------
# 1. Update system packages
# --------------------------------------------------

echo ""
echo "[1/7] Updating apt packages..."

sudo apt update

# --------------------------------------------------
# 2. Install NVIDIA Driver
# --------------------------------------------------

echo ""
echo "[2/7] Installing NVIDIA driver..."

if command -v nvidia-smi &> /dev/null; then
    echo "NVIDIA driver already installed."
else
    sudo apt install -y nvidia-driver-595
fi

echo ""
echo "Checking NVIDIA GPU..."

if nvidia-smi; then
    echo "NVIDIA driver is working."
else
    echo "WARNING: nvidia-smi failed."
    echo "You may need to reboot the machine and run:"
    echo "    nvidia-smi"
fi

# --------------------------------------------------
# 3. Install prerequisites
# --------------------------------------------------

echo ""
echo "[3/7] Installing Python prerequisites..."

sudo apt install -y software-properties-common

# --------------------------------------------------
# 4. Add deadsnakes PPA
# --------------------------------------------------

echo ""
echo "[4/7] Adding deadsnakes PPA..."

if grep -R "deadsnakes/ppa" /etc/apt/sources.list.d/ &> /dev/null; then
    echo "deadsnakes PPA already exists."
else
    sudo add-apt-repository -y ppa:deadsnakes/ppa
fi

sudo apt update

# --------------------------------------------------
# 5. Install Python 3.12
# --------------------------------------------------

echo ""
echo "[5/7] Installing Python 3.12..."

sudo apt install -y \
    python3.12 \
    python3.12-venv \
    python3.12-dev

echo ""
echo "Python version:"
python3.12 --version

# --------------------------------------------------
# 6. Create virtual environment
# --------------------------------------------------

echo ""
echo "[6/7] Creating .grpo virtual environment..."

if [ -d ".grpo" ]; then
    echo ".grpo already exists."
else
    python3.12 -m venv .grpo
fi

# Activate environment for THIS script
source .grpo/bin/activate

echo ""
echo "Virtual environment:"
echo "Python: $(python --version)"
echo "Path:   $(which python)"

# --------------------------------------------------
# 7. Install Python packages
# --------------------------------------------------

echo ""
echo "[7/7] Installing Python packages..."

python -m pip install --upgrade \
    pip \
    setuptools \
    wheel

python -m pip install \
    jupyter \
    nbconvert

echo ""
echo "Jupyter version:"
jupyter nbconvert --version

# --------------------------------------------------
# Done
# --------------------------------------------------

echo ""
echo "=========================================="
echo " GRPO SETUP COMPLETE"
echo "=========================================="

echo ""
echo "Python:"
python --version

echo ""
echo "Python location:"
which python

echo ""
echo "NVIDIA:"
nvidia-smi --query-gpu=name,driver_version,memory.total \
    --format=csv,noheader || true

echo ""
echo "To activate the environment in your shell:"
echo ""
echo "    source .grpo/bin/activate"
echo ""

echo "Then verify:"
echo ""
echo "    python --version"
echo "    which python"
echo "    nvidia-smi"
echo ""
