#!/usr/bin/env bash
set -euo pipefail

echo "=== Preparing evaluation datasets ==="

# 1) GSM8K test
echo "- Downloading GSM8K test set…"
mkdir -p data/gsm8k
if [ ! -s data/gsm8k/test.jsonl ]; then
  wget https://github.com/openai/grade-school-math/raw/master/data/test.jsonl \
       -O data/gsm8k/test.jsonl
else
  echo "  → data/gsm8k/test.jsonl already exists, skipping"
fi

# 2) ShareGPT (Vicuna unfiltered)
echo "- Downloading ShareGPT dump (Vicuna unfiltered)…"
mkdir -p data/sharegpt
if [ ! -s data/sharegpt/ShareGPT.json ]; then
  wget https://huggingface.co/datasets/anon8231489123/ShareGPT_Vicuna_unfiltered/resolve/main/ShareGPT_V3_unfiltered_cleaned_split_no_imsorry.json \
       -O data/sharegpt/ShareGPT.json
else
  echo "  → data/sharegpt/ShareGPT.json already exists, skipping"
fi

# 3) Reverse-curse experiments
echo "- Fetching reverse-curse experiments…"
if [ ! -d data/reverse_experiments ]; then
  # shallow‐clone entire repo, copy only the needed folder, then clean up
  git clone --depth 1 https://github.com/lukasberglund/reversal_curse.git tmp_rev
  mkdir -p data/reverse_experiments
  cp -r tmp_rev/data/reverse_experiments/* data/reverse_experiments/
  rm -rf tmp_rev
  echo "  → reverse_experiments downloaded"
else
  echo "  → data/reverse_experiments already exists, skipping"
fi

# 4) FineWeb temporal-shift
echo "- Running FineWeb prep script…"
mkdir -p data/fineweb
python scripts/prepare_fineweb.py

echo "✅  All evaluation datasets are ready under data/*"
