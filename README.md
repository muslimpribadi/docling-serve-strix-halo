<p align="center">
  <a href="https://github.com/docling-project/docling-serve">
    <img loading="lazy" alt="Docling" src="https://github.com/muslimpribadi/docling-serve-strix-halo/raw/main/assets/docling-serve-pic.webp" width="15%"/>
  </a>
  <a href="https://github.com/ROCm/ROCm">
    <img loading="lazy" alt="ROCm" src="https://github.com/muslimpribadi/docling-serve-strix-halo/raw/main/assets/amd-rocm-logo.webp" width="15%"/>
  </a>
</p>

# Docling Serve with ROCm for AMD Strix Halo

Containerized deployment of [Docling Serve](https://github.com/docling-project/docling-serve) with ROCm 7.2 support, optimized for **AMD Strix Halo (gfx1151)** hardware.

## Overview

This repository provides a hardened, production-ready container image that runs Docling as an API service. It is specifically tuned for the AMD Radeon 8060S GPU found in Strix Halo systems, with ROCm kernel pruning and architecture-specific optimizations to minimize footprint and maximize performance.

## Key Features

- **Strix Halo Optimized**: Built exclusively for `gfx1151` (AMD Radeon 8060S)
- **Kernel Pruning**: Removes unused ROCm kernels (~19+GB~ ~16GB image size)
- **mimalloc Integration**: Preloaded memory allocator for improved throughput
- **Multi-stage Dockerfile**: Build/runtime separation for lean final images
- **GitHub Container Registry (GHCR)**: Automated CI/CD pipeline

## Quick Start

### Docker

```bash
# Pull and run the container
docker pull ghcr.io/muslimpribadi/docling-serve-strix-halo:latest
docker run -p 5001:5001 ghcr.io/muslimpribadi/docling-serve-strix-halo:latest
```

### Podman

```bash
# Pull and run the container
podman pull ghcr.io/muslimpribadi/docling-serve-strix-halo:latest
podman run -p 5001:5001 ghcr.io/muslimpribadi/docling-serve-strix-halo:latest
```

The API is available at `http://localhost:5001` with auto-generated docs at `http://localhost:5001/docs`.

## Build Locally

### Docker

```bash
docker build -f Dockerfile.gfx1151 -t docling-serve-strix-halo .
```

### Podman

```bash
podman build -f Dockerfile.gfx1151 -t docling-serve-strix-halo .
```

## Example Conversion

```bash
curl -X POST 'http://localhost:5001/v1/convert/source' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{"sources": [{"kind": "http", "url": "https://arxiv.org/pdf/2501.17887"}]}'
```

## Configuration

### Environment variables

Strix halo default environment variables.

| Variable | Default | Description |
|----------|---------|-------------|
| `OMP_NUM_THREADS` | 4 | OpenMP thread count |
| `HSA_OVERRIDE_GFX_VERSION` | 11.5.1 | Strix Halo GPU override |
| `PYTORCH_ROCM_ARCH` | gfx1151 | PyTorch ROCm target architecture |
| `DOCLING_SERVE_ARTIFACTS_PATH` | /opt/app-root/src/.cache/docling/models | Model cache location |

Here are the full Docling Serve [configuration](https://github.com/docling-project/docling-serve/blob/main/docs/configuration.md).

### Volume Mounts

These mounts are recommended to persist your models:

| Host Path | Container Path | Purpose |
|-----------|----------------|---------|
| `/mnt/docling-models` | `/opt/app-root/src/.cache/docling/models` | Your models cache directory (`DOCLING_SERVE_ARTIFACTS_PATH`) |

## Troubleshooting

When updating docling-serve to version [1.27.0](https://github.com/docling-project/docling-serve/releases/tag/v1.27.0)+, the default model cache may only contain `PP-OCRv4` weights, resulting in `FileNotFoundError` crashes when the engine attempts to load the v6 det_small and rec_small ONNX files.

The missing `PP-OCRv4` models can be downloaded from huggingface [mpribadi/Docling-RapidOcr](https://huggingface.co/mpribadi/Docling-RapidOcr) this repo consolidates these specific files to restore functionality for document extraction pipelines.

## CI/CD

Images are automatically built and published to [GHCR](https://github.com/muslimpribadi/docling-serve-strix-halo/pkgs/container/docling-serve-strix-halo) when there is new docling-serve release.

## Acknowledgements

This project was assisted by **Qwen3.6 35B A3B** in its development and documentation.

```bibtex
@misc{qwen36_35b_a3b,
    title = {{Qwen3.6-35B-A3B}: Agentic Coding Power, Now Open to All},
    url = {https://qwen.ai/blog?id=qwen3.6-35b-a3b},
    author = {{Qwen Team}},
    month = {April},
    year = {2026}
}
```

## Upstream

Built on top of [docling-project/docling-serve](https://github.com/docling-project/docling-serve). See their docs for full API reference.
