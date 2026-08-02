<div align="center">

<p>
    <!-- Keep docling-serve upstream branding -->
  <a href="https://github.com/docling-project/docling-serve">
    <img loading="lazy" alt="Docling" src="https://github.com/muslimpribadi/docling-serve-strix-halo/raw/main/assets/docling-serve-pic.webp" width="15%"/>
  </a>

  <!-- Add ROCM logo -->
  <a href="https://github.com/ROCm/ROCm">
    <img loading="lazy" alt="ROCm" src="https://github.com/muslimpribadi/docling-serve-strix-halo/raw/main/assets/amd-rocm-logo.webp" width="15%"/>
  </a>
</p>

[![][github-action-shield]][github-action-link]
[![][github-ghcr-shield]][github-ghcr-link]
[![][github-upstream-shield]][github-upstream-link]
[![][github-license-shield]][github-license-link]
<br>
[![][github-ghcr-downloads-shield]][github-ghcr-link]

[github-action-shield]: https://github.com/muslimpribadi/docling-serve-strix-halo/actions/workflows/build-and-push.yml/badge.svg
[github-ghcr-shield]: https://img.shields.io/badge/GHCR-Ready-blue?logo=docker
[github-upstream-shield]: https://img.shields.io/badge/Upstream-Docling_Serve-purple?logo=github
[github-license-shield]: https://img.shields.io/badge/License-MIT-green.svg
[github-ghcr-downloads-shield]: https://ghcr-badge.elias.eu.org/shield/muslimpribadi/docling-serve-strix-halo
[github-upstream-link]: https://github.com/docling-project/docling-serve
[github-license-link]: https://github.com/muslimpribadi/docling-serve-strix-halo/blob/main/LICENSE
[github-action-link]: https://github.com/muslimpribadi/docling-serve-strix-halo/actions
[github-ghcr-link]: https://github.com/muslimpribadi/docling-serve-strix-halo/pkgs/container/docling-serve-strix-halo
  
</div>

# 🚀 Docling Serve with ROCm for AMD Strix Halo

Containerized deployment of [Docling Serve](https://github.com/docling-project/docling-serve) with ROCm 7.2 support, optimized for **AMD Strix Halo (gfx1151)** hardware.

## 📖 Overview

This repository provides a hardened, production-ready container image that runs Docling as an API service. It is specifically tuned for the AMD Radeon 8060S GPU found in Strix Halo systems (`gfx1151`), utilizing ROCm kernel pruning and architecture-specific optimizations to minimize footprint and maximize performance.

## ✨ Key Features

* **Strix Halo Optimized:** Built exclusively for `gfx1151` (AMD Radeon 8060S).


* **Kernel Pruning:** Removes unused ROCm kernels, reducing image size from ~19+GB down to ~16GB.


* **mimalloc Integration:** Preloaded memory allocator for improved throughput.


* **Multi-stage Dockerfile:** Build/runtime separation for lean final images.


* **Automated CI/CD:** Automated pipeline publishing directly to the GitHub Container Registry (GHCR).



## ⚡ Quick Start

Note: You can use `docker` or `podman` interchangeably for the commands below.

**1. Pull the container**

```bash
docker pull ghcr.io/muslimpribadi/docling-serve-strix-halo:latest

```

**2. Download initial models**

```bash
docker run -it --rm \
  -v /mnt/docling-models:/opt/app-root/src/.cache/docling/models \
  --name docling-serve \
  ghcr.io/muslimpribadi/docling-serve-strix-halo:latest

# Run from inside the container:
docling-tools models download layout tableformer picture_classifier rapidocr easyocr

```

**3. Run the server**

```bash
docker run \
  -p 5001:5001 \
  -e DOCLING_SERVE_ENABLE_UI=true \
  -v /mnt/docling-models:/opt/app-root/src/.cache/docling/models \
  --name docling-serve \
  ghcr.io/muslimpribadi/docling-serve-strix-halo:latest

```

**Service Endpoints:**

* **API:** [http://127.0.0.1:5001](https://www.google.com/search?q=http://127.0.0.1:5001)
* **API Documentation:** [http://127.0.0.1:5001/docs](https://www.google.com/search?q=http://127.0.0.1:5001/docs)
* **UI Playground:** [http://127.0.0.1:5001/ui](https://www.google.com/search?q=http://127.0.0.1:5001/ui)

<img loading="lazy" alt="fastapi UI" src="https://github.com/muslimpribadi/docling-serve-strix-halo/raw/main/assets/fastapi-ui.webp" />

Try it out with a simple conversion:

```bash
curl -X 'POST' \
  'http://localhost:5001/v1/convert/source' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
    "sources": [{"kind": "http", "url": "https://arxiv.org/pdf/2501.17887"}]
  }'

```

**Demonstration UI**

<img loading="lazy" alt="UI input" src="https://github.com/muslimpribadi/docling-serve-strix-halo/raw/main/assets/ui-input.webp" />

<img loading="lazy" alt="UI output" src="https://github.com/muslimpribadi/docling-serve-strix-halo/raw/main/assets/ui-output.webp" />

## 🛠️ Build Locally

To build the image yourself, run the following using Docker or Podman:

```bash
docker build -f Dockerfile.gfx1151 -t docling-serve-strix-halo .

```

## ⚙️ Configuration

### Environment Variables

Strix Halo default environment variables:

| Variable | Default | Description |
| --- | --- | --- |
| `OMP_NUM_THREADS` | 4 | OpenMP thread count |
| `HSA_OVERRIDE_GFX_VERSION` | 11.5.1 | Strix Halo GPU override |
| `PYTORCH_ROCM_ARCH` | gfx1151 | PyTorch ROCm target architecture |
| `DOCLING_SERVE_ARTIFACTS_PATH` | `/opt/app-root/src/.cache/docling/models` | Model cache location |

* Full Docling Serve [configuration](https://www.google.com/search?q=https://github.com/docling-project/docling-serve/blob/main/docs/configuration.md).
* `docling-tools` [reference](https://www.google.com/search?q=https://docling-project.github.io/docling/reference/cli/%23docling-tools-models).

### Volume Mounts

It is recommended to mount volumes to persist your downloaded models:

| Host Path | Container Path | Purpose |
| --- | --- | --- |
| `/mnt/docling-models` | `/opt/app-root/src/.cache/docling/models` | Your models cache directory (`DOCLING_SERVE_ARTIFACTS_PATH`) |

## 🔧 Troubleshooting

When updating docling-serve to version [1.27.0](https://www.google.com/search?q=https://github.com/docling-project/docling-serve/releases/tag/v1.27.0)+, the default model cache may only contain `PP-OCRv4` weights. This can result in a `FileNotFoundError` crash when the engine attempts to load the v6 `det_small` and `rec_small` ONNX files.

To restore functionality for document extraction pipelines, download the missing models from the huggingface repository [mpribadi/Docling-RapidOcr](https://www.google.com/search?q=https://huggingface.co/mpribadi/Docling-RapidOcr), which consolidates these specific files.

Use `docling-tools` to download them from Hugging Face (use `HF_TOKEN` for a higher rate [limit](https://huggingface.co/docs/hub/en/rate-limits)):

```bash
# Run from inside the container
docling-tools models download-hf-repo mpribadi/Docling-RapidOcr -o /opt/app-root/src/.cache/docling/models/RapidOcr/

```

## 🔄 Upstream & CI/CD

* **CI/CD:** Images are automatically built and published to [GHCR](https://www.google.com/search?q=https://github.com/muslimpribadi/docling-serve-strix-halo/pkgs/container/docling-serve-strix-halo) upon new official docling-serve [releases](https://www.google.com/search?q=https://github.com/docling-project/docling-serve/releases).


* **Upstream:** Built on top of [docling-project/docling-serve](https://github.com/docling-project/docling-serve). See their docs for full API reference.

## 🙌 Acknowledgements

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

## License

MIT License — see [LICENSE](LICENSE) for details.
