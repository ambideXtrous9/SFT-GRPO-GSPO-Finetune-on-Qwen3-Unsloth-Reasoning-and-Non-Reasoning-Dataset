#!/bin/bash

set -e

echo "=== GRPO Environment Setup ==="

# 1. NVIDIA Driver
echo ""
echo "[1/5] Setting up NVIDIA driver..."

sudo apt update

if ! command -v nvidia-smi &>/dev/null; then
    sudo apt install -y nvidia-driver-595
fi

# Try to load NVIDIA modules without reboot
sudo modprobe nvidia 2>/dev/null || true
sudo modprobe nvidia_uvm 2>/dev/null || true
sudo modprobe nvidia_modeset 2>/dev/null || true
sudo modprobe nvidia_drm 2>/dev/null || true

sleep 2

if nvidia-smi &>/dev/null; then
    echo "NVIDIA driver is working."
    nvidia-smi
else
    echo "WARNING: nvidia-smi is not working."
    echo "Driver may require a reboot."
fi


# 2. Python prerequisites
echo ""
echo "[2/5] Installing Python prerequisites..."

sudo apt install -y software-properties-common

# 3. Python 3.12
echo ""
echo "[3/5] Installing Python 3.12..."

if ! command -v python3.12 &>/dev/null; then
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    sudo apt update
    sudo apt install -y python3.12 python3.12-venv python3.12-dev
fi

python3.12 --version


# 4. Create virtual environment
echo ""
echo "[4/5] Creating .grpo environment..."

if [ ! -d ".grpo" ]; then
    python3.12 -m venv .grpo
fi

source .grpo/bin/activate

echo "Python: $(python --version)"
echo "Path:   $(which python)"


# 5. Install Python tools
echo ""
echo "[5/5] Installing Python packages..."

python -m pip install --upgrade pip setuptools wheel
python -m pip install jupyter nbconvert

echo ""
echo "=== Setup Complete ==="

echo ""
echo "To activate later:"
echo "source .grpo/bin/activate"

echo ""
echo "Verify:"
echo "python --version"
echo "nvidia-smi"
