#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------------------
# install.sh
#
# Creates a conda env "mdm" on your scratch and installs all deps
# without ever filling up your home disk.
# ------------------------------------------------------------------------------

# 1) Define paths on scratch
# ---------------------------
ENV_PATH=/n/fs/vl/anlon/envs/mdm
PKG_CACHE=/n/fs/vl/anlon/conda_pkgs

mkdir -p "$ENV_PATH" "$PKG_CACHE"

# 2) Clean out any old cache in your home dir (frees up space for conda metadata)
# -------------------------------------------------------------------------------
eval "$(conda shell.bash hook)"
conda clean --yes --packages --tarballs

# 3) Configure conda to use scratch for its package cache
# --------------------------------------------------------
conda config --append pkgs_dirs "$PKG_CACHE"

# 4) Create & activate the env on scratch
# ----------------------------------------
conda create --prefix "$ENV_PATH" python=3.9 -y
conda activate "$ENV_PATH"

# 5) Core PyTorch install (no cache)
# -----------------------------------
pip install --no-cache-dir torch torchvision torchaudio

# 6) Install flash-attention from source
# --------------------------------------
pip uninstall ninja -y
pip install --no-cache-dir ninja -U

git clone https://github.com/Dao-AILab/flash-attention
cd flash-attention
pip install --no-cache-dir packaging
python setup.py install

# install only the custom kernels
cd csrc/rotary && pip install --no-cache-dir .
cd ../layer_norm && pip install --no-cache-dir .
cd ../xentropy && pip install --no-cache-dir .
cd ../../..
rm -rf flash-attention

# 7) xFormers for efficient attention
# -----------------------------------
pip install --no-cache-dir xformers

# 8) TinyLlama requirements
# --------------------------
git clone https://github.com/jzhang38/TinyLlama.git
cd TinyLlama
pip install --no-cache-dir -r requirements.txt tokenizers sentencepiece
cd .. && rm -rf TinyLlama

# 9) bitsandbytes with GPU support
# --------------------------------
pip uninstall bitsandbytes -y
# Change cuda117 to cuda118 or cuda119 if your system uses a different CUDA
pip install --no-cache-dir bitsandbytes-cuda117

# 10) Evaluation toolkits
# -----------------------
pip install --no-cache-dir \
    lm-eval==0.4.4 \
    numpy==1.25.0 \
    openai==0.28 \
    fschat==0.2.34 \
    anthropic

echo
echo "✅  Setup complete!"
echo "👉  Activate your env with:"
echo "      conda activate $ENV_PATH"
