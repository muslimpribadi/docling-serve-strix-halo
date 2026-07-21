# docling-serve ROCm for AMD Strix Halo

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

| Variable | Default | Description |
|----------|---------|-------------|
| `OMP_NUM_THREADS` | 4 | OpenMP thread count |
| `HSA_OVERRIDE_GFX_VERSION` | 11.5.1 | Strix Halo GPU override |
| `PYTORCH_ROCM_ARCH` | gfx1151 | PyTorch ROCm target architecture |
| `DOCLING_SERVE_ARTIFACTS_PATH` | /opt/app-root/src/.cache/docling/models | Model cache location |

## CI/CD

Images are automatically built and published to GHCR when `docling-serve_version.txt` or `Dockerfile.gfx1151` changes on `main`. Tags: `latest` and the version from `docling-serve_version.txt`.

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
