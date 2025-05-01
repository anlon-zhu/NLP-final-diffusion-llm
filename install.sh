#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------------------
# setup_mdm_env.sh
# Creates a 'mdm' env on scratch and installs all deps for SMDM experiments.
# ------------------------------------------------------------------------------

# 1) Tell conda to put its package cache on scratch, not in your home dir
export CONDA_PKGS_DIRS=/n/fs/vl/anlon/conda_pkgs
mkdir -p "$CONDA_PKGS_DIRS"

# 2) Initialize conda in this script
eval "$(conda shell.bash hook)"

# 3) Create & activate the env on scratch
ENV_DIR=/n/fs/vl/anlon/envs/mdm
mkdir -p "$(dirname "$ENV_DIR")"
conda create --prefix "$ENV_DIR" python=3.9 -y
conda activate "$ENV_DIR"

# 4) Core PyTorch install (no cache)
pip install --no-cache-dir torch torchvision torchaudio

# 5) flash-attention from source
pip uninstall ninja -y
pip install --no-cache-dir ninja -U
git clone https://github.com/Dao-AILab/flash-attention
cd flash-attention
pip install --no-cache-dir packaging
python setup.py install

# install the individual kernels
cd csrc/rotary && pip install --no-cache-dir .
cd ../layer_norm && pip install --no-cache-dir .
cd ../xentropy && pip install --no-cache-dir .
cd ../../..
rm -rf flash-attention

# 6) xFormers
pip install --no-cache-dir xformers

# 7) TinyLlama dependencies
git clone https://github.com/jzhang38/TinyLlama.git
cd TinyLlama
pip install --no-cache-dir -r requirements.txt tokenizers sentencepiece
cd .. && rm -rf TinyLlama

# 8) bitsandbytes with CUDA support
pip uninstall bitsandbytes -y
# pick the wheel matching your CUDA version: e.g. cuda117, cuda118, cuda119, etc.
pip install --no-cache-dir bitsandbytes-cuda117

# 9) Evaluation toolkits
pip install --no-cache-dir \
    lm-eval==0.4.4 \
    numpy==1.25.0 \
    openai==0.28 \
    fschat==0.2.34 \
    anthropic

echo
echo "✅  Done! To start using this env, run:"
echo "    conda activate $ENV_DIR"
