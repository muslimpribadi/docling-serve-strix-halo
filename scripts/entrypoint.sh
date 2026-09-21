#!/bin/bash
set -e

# 1. Isolate and prioritize the virtual environment PATH
export VIRTUAL_ENV="/opt/app-root/src/.venv"
export PATH="${VIRTUAL_ENV}/bin:${PATH}"

# Define required models with a fallback default
MODELS_LIST=${MODELS_LIST:-"layout tableformer picture_classifier rapidocr easyocr"}

if [ -n "${DOCLING_SERVE_ARTIFACTS_PATH}" ]; then
    echo "[System] DOCLING_SERVE_ARTIFACTS_PATH is set to: ${DOCLING_SERVE_ARTIFACTS_PATH}"
    
    # 2. Ensure output directory exists before writing
    mkdir -p "${DOCLING_SERVE_ARTIFACTS_PATH}"

    # 3. Configure Hugging Face network tolerances
    export HF_HUB_DOWNLOAD_TIMEOUT="90"
    export HF_HUB_ETAG_TIMEOUT="90"
    
    if [ -n "${HF_TOKEN}" ]; then
        echo "[System] HF_TOKEN detected. Using authenticated Hugging Face Hub connection."
    fi

    echo "[System] Validating and syncing models: ${MODELS_LIST}"

    # 4. Graceful execution check: Verify tool exists and prevent network crashes
    if command -v docling-tools &> /dev/null; then
        if docling-tools models download -o "${DOCLING_SERVE_ARTIFACTS_PATH}" ${MODELS_LIST}; then
            echo "[System] Model sync complete."
        else
            echo "[Warning] Model download command encountered an error (e.g., timeout). Continuing startup..."
        fi
    else
        echo "[Error] docling-tools binary not found in ${VIRTUAL_ENV}/bin. Skipping sync."
    fi
else
    echo "[System] DOCLING_SERVE_ARTIFACTS_PATH is not set. Skipping pre-download phase."
fi

echo "[System] Starting application..."
# 5. Handoff process control to the container's CMD
exec "$@"