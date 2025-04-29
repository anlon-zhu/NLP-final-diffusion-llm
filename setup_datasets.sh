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

# 2) ShareGPT dialogues
echo "- Downloading ShareGPT dump…"
mkdir -p data/sharegpt
if [ ! -s data/sharegpt/sharegpt.json ]; then
  # TODO: replace <ShareGPT-URL> with the actual download link
  wget <ShareGPT-URL> -O data/sharegpt/sharegpt.json
else
  echo "  → data/sharegpt/sharegpt.json already exists, skipping"
fi

# 3) Reverse-curse experiments
echo "- Preparing reverse-curse data…"
mkdir -p data/reverse_experiments
echo "  → please unzip or copy the provided reverse_experiments folder into data/reverse_experiments"

# 4) FineWeb temporal-shift
echo "- Running FineWeb prep script…"
mkdir -p data/fineweb
python scripts/prepare_fineweb.py

echo "✅  All evaluation datasets are ready in data/*"
