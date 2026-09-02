ARG BASE_IMAGE=quay.io/sclorg/python-312-c9s:c9s
ARG UV_IMAGE=ghcr.io/astral-sh/uv:0.8.19
ARG MIMALLOC_VERSION=v3.2.8
ARG UV_SYNC_EXTRA_ARGS="--no-group pypi --group rocm72 --no-extra flash-attn"
ARG DOCLING_REPO="https://github.com/docling-project/docling-serve.git"
ARG DOCLING_BRANCH="main"

###################################################################################################
# Fetch Source Layer
###################################################################################################
FROM ${BASE_IMAGE} AS source-fetcher
USER 0
ARG DOCLING_REPO
ARG DOCLING_BRANCH
RUN dnf install -y --best --nodocs --setopt=install_weak_deps=False git && \
    git clone --depth 1 --branch ${DOCLING_BRANCH} ${DOCLING_REPO} /workspace

###################################################################################################
# Build mimalloc
###################################################################################################
FROM ${BASE_IMAGE} AS mimalloc
ARG MIMALLOC_VERSION
USER 0
RUN dnf install -y --best --nodocs --setopt=install_weak_deps=False gcc gcc-c++ make cmake git
RUN git clone --depth 1 --branch ${MIMALLOC_VERSION} https://github.com/microsoft/mimalloc.git /opt/app-root/src/mimalloc
WORKDIR /opt/app-root/src/mimalloc
RUN mkdir -p out/release
WORKDIR /opt/app-root/src/mimalloc/out/release
RUN cmake ../.. && make

###################################################################################################
# OS Layer (Base Runtime Image)
###################################################################################################
FROM ${BASE_IMAGE} AS docling-base
USER 0
COPY --from=source-fetcher /workspace/os-packages.txt /tmp/os-packages.txt
RUN dnf -y install --best --nodocs --setopt=install_weak_deps=False dnf-plugins-core && \
    dnf config-manager --best --nodocs --setopt=install_weak_deps=False --save && \
    dnf config-manager --enable crb && \
    dnf -y update && \
    dnf install -y $(cat /tmp/os-packages.txt) && \
    dnf -y clean all && \
    rm -rf /var/cache/dnf

COPY --from=mimalloc /opt/app-root/src/mimalloc/out/release/libmimalloc.so /usr/local/lib/libmimalloc.so
RUN /usr/bin/fix-permissions /opt/app-root/src/.cache
ENV TESSDATA_PREFIX=/usr/share/tesseract/tessdata/

###################################################################################################
# Docling Build Layer
###################################################################################################
FROM ${UV_IMAGE} AS uv_stage
FROM docling-base AS docling-builder
USER 1001
WORKDIR /opt/app-root/src

# Strict architecture targeting to prevent multi-GPU compilation bloat
ENV AMDGPU_TARGETS=gfx1151 \
    PYTORCH_ROCM_ARCH=gfx1151 \
    OMP_NUM_THREADS=4 \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    PYTHONIOENCODING=utf-8 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT=/opt/app-root \
    DOCLING_SERVE_ARTIFACTS_PATH=/opt/app-root/src/.cache/docling/models

ARG UV_SYNC_EXTRA_ARGS

COPY --from=source-fetcher --chown=1001:0 /workspace/uv.lock /workspace/pyproject.toml ./

# Define the dedicated virtual environment path to prevent permission conflicts
ENV UV_PROJECT_ENVIRONMENT="/opt/app-root/src/.venv"
ENV PATH="/opt/app-root/src/.venv/bin:$PATH"

RUN --mount=from=uv_stage,source=/uv,target=/bin/uv \
    --mount=type=cache,target=/opt/app-root/src/.cache/uv,uid=1001 \
    umask 002 && \
    uv sync --frozen --no-install-project --no-dev --all-extras ${UV_SYNC_EXTRA_ARGS}

COPY --from=source-fetcher --chown=1001:0 /workspace/docling_serve ./docling_serve

RUN --mount=from=uv_stage,source=/uv,target=/bin/uv \
    --mount=type=cache,target=/opt/app-root/src/.cache/uv,uid=1001 \
    umask 002 && uv sync --frozen --no-dev --all-extras ${UV_SYNC_EXTRA_ARGS}

# -------------------------------------------------------------------------
# PRUNE UNUSED ROCM KERNELS
# -------------------------------------------------------------------------
RUN if [ -d "/opt/app-root/src/.venv/lib/python3.12/site-packages/torch/lib/hipblaslt/library/" ]; then \
        find /opt/app-root/src/.venv/lib/python3.12/site-packages/torch/lib/hipblaslt/library/ \
        -type f -name '*.dat' -not -name '*gfx11*' -delete; \
    fi && \
    if [ -d "/opt/app-root/src/.venv/lib/python3.12/site-packages/torch/lib/rocblas/library/" ]; then \
        find /opt/app-root/src/.venv/lib/python3.12/site-packages/torch/lib/rocblas/library/ \
        -type f -name '*.dat' -not -name '*gfx11*' -delete; \
    fi

###################################################################################################
# Final Lean Runtime Stage
###################################################################################################
FROM docling-base AS final

# OCI Metadata Labels
LABEL org.opencontainers.image.title="docling-serve-strix-halo" \
      org.opencontainers.image.description="Docling-serve container optimized for AMD Ryzen AI Strix Halo (ROCm 7.2 gfx1151) hardware, designed for high-performance document conversion and OCR." \
      org.opencontainers.image.source="https://github.com/muslimpribadi/docling-serve-strix-halo" \
      org.opencontainers.image.licenses="MIT"

USER 1001
WORKDIR /opt/app-root/src

# Copy ONLY the synchronized environment and code, entirely dropping uv caches
COPY --from=docling-builder --chown=1001:0 /opt/app-root /opt/app-root

# Copy the runtime entrypoint script
COPY --chown=1001:0 scripts/entrypoint.sh /opt/app-root/bin/entrypoint.sh
RUN chmod +x /opt/app-root/bin/entrypoint.sh

# Strix Halo specific runtime adjustments
ENV OMP_NUM_THREADS=4 \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    PYTHONIOENCODING=utf-8 \
    LD_PRELOAD=/usr/local/lib/libmimalloc.so \
    ROCR_VISIBLE_DEVICES=0 \
    HSA_OVERRIDE_GFX_VERSION=11.5.1 \
    PYTORCH_ROCM_ARCH=gfx1151 \
    TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1

EXPOSE 5001

ENTRYPOINT ["/opt/app-root/bin/entrypoint.sh"]
CMD ["/opt/app-root/bin/docling-serve", "run"]
