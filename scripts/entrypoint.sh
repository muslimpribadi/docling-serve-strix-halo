#!/bin/bash
set -e

# Define required models
MODELS_LIST=${MODELS_LIST:-"layout tableformer picture_classifier rapidocr easyocr"}

# Check if DOCLING_SERVE_ARTIFACTS_PATH is set and non-empty
if [ -n "${DOCLING_SERVE_ARTIFACTS_PATH}" ]; then
    echo "[System] DOCLING_SERVE_ARTIFACTS_PATH is set to: ${DOCLING_SERVE_ARTIFACTS_PATH}"
    echo "[System] Validating and syncing models..."

    # Ensure output directory exists
    mkdir -p "${DOCLING_SERVE_ARTIFACTS_PATH}"

    export HF_HUB_DOWNLOAD_TIMEOUT="90"
    export HF_HUB_ETAG_TIMEOUT="90"

    # Execute the download validation using the virtual environment binary
    /opt/app-root/bin/docling-tools models download -o "${DOCLING_SERVE_ARTIFACTS_PATH}" ${MODELS_LIST}

    echo "[System] Model sync complete."
else
    echo "[System] DOCLING_SERVE_ARTIFACTS_PATH is not set. Skipping model download."
fi

echo "[System] Starting application..."
# Handoff process control to the container command
exec "$@"
