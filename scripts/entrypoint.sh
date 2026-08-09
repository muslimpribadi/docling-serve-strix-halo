#!/bin/bash
set -e

# Define required models
MODELS_LIST=${MODELS_LIST:-"layout tableformer picture_classifier rapidocr easyocr"}

echo "[System] Validating model cache in: ${DOCLING_SERVE_ARTIFACTS_PATH}"

# Native ETAG checks will skip existing files and only download missing/updated ones
export HF_HUB_DOWNLOAD_TIMEOUT="90"
export HF_HUB_ETAG_TIMEOUT="90"

# Execute the download validation using the virtual environment binary
/opt/app-root/bin/docling-tools models download -o "${DOCLING_SERVE_ARTIFACTS_PATH}" ${MODELS_LIST}

echo "[System] Model validation complete. Starting application..."

# Handoff process control to docling-serve so systemd can track it properly
exec "$@"
