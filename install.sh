#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------------------
# install.sh
#
# Creates a 'mdm' env on scratch and installs all deps without filling your home.
# ------------------------------------------------------------------------------

# 1) Define paths on scratch
ENV_PATH=/n/fs/vl/anlon/envs/mdm
PKG_CACHE=/n/fs/vl/anlon/conda_pkgs

mkdir -p "$ENV_PATH" "$PKG_CACHE"

# 2) Initialize conda in this shell
eval "$(conda shell.bash hook)"

# 3) Clean any stale cache in home
conda clean --yes --packages --tarballs

# 4) Prepend scratch to conda's pkgs_dirs so it's used first
conda config --prepend pkgs_dirs "$PKG_CACHE"

# 5) Create & activate the env on scratch
conda create --prefix "$ENV_PATH" python=3.9 -y
conda activate "$ENV_PATH"

# 6) Core PyTorch install (no pip cache)
pip install --no-cache-dir torch torchvision torchaudio

# 7) flash-attention from source
pip uninstall ninja -y
pip install --no-cache-dir ninja -U
git clone https://github.com/Dao-AILab/flash-attention
cd flash-attention
pip install --no-cache-dir packaging
python setup.py install
cd csrc/rotary && pip install --no-cache-dir .
cd ../layer_norm  && pip install --no-cache-dir .
cd ../xentropy     && pip install --no-cache-dir .
cd ../../.. && rm -rf flash-attention

# 8) xFormers
pip install --no-cache-dir xformers

# 9) TinyLlama deps
git clone https://github.com/jzhang38/TinyLlama.git
cd TinyLlama
pip install --no-cache-dir -r requirements.txt tokenizers sentencepiece
cd .. && rm -rf TinyLlama

# 10) bitsandbytes with CUDA support
pip uninstall bitsandbytes -y
# adjust the cuda version suffix if needed (e.g. cuda118)
pip install --no-cache-dir bitsandbytes-cuda117

# 11) Evaluation toolkits
pip install --no-cache-dir \
    lm-eval==0.4.4 \
    numpy==1.25.0 \
    openai==0.28 \
    fschat==0.2.34 \
    anthropic

echo
echo "✅  Setup complete!"
echo "👉  Activate with: conda activate $ENV_PATH"
