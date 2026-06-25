# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Docker images for [SmartMet Server](https://github.com/fmidev/smartmet-server), FMI's high-capacity MetOcean data server. Images are published to Docker Hub (`fmidev/smartmetserver`) and GHCR (`ghcr.io/fmidev/smartmetserver`). Two variants exist: Rocky Linux 9 (`Dockerfile`) and Rocky Linux 10 (`Dockerfile.rocky10`).

## Build & Test Commands

```bash
# Build and test Rocky 9 image
make build && make test

# Build and test Rocky 10 image
make build10 && make test10

# Build Rocky 9 manually
docker build -t smartmetserver:test --no-cache .

# Run locally with MEPS data downloader
docker compose up -d

# Test the running container
curl "http://localhost:8080/wms?service=WMS&version=1.3.0&request=GetCapabilities"
curl "http://localhost:8080/timeseries?..."
```

The `make test` target starts the container and polls the WMS GetCapabilities endpoint to confirm the server is up (startup takes ~45 seconds).

## Architecture

### Image Build

1. Installs SmartMet RPMs from FMI's open-source repository into a Rocky Linux base
2. Copies configuration from `smartmetconf/` to `/etc/smartmet/`
3. Copies WMS resources from `share/wms/` to `/smartmet/share/wms/`
4. Creates the data directory tree at build time (all models under `/smartmet/data/`)
5. Runs as UID 101010 (non-root); uses jemalloc via `LD_PRELOAD` for memory performance

### Configuration Layout

```
smartmetconf/
  smartmet.conf          # Main config: port 8080, thread pools, engines/plugins list
  engines/               # One .conf per engine (querydata, gis, observation, grid, ...)
  plugins/               # One .conf per plugin (timeseries, wms, download, edr, ...)
share/wms/
  customers/             # WMS product definitions per weather model (JSON)
  legends/               # Legend rendering templates
  resources/layers/      # Isoband/isoline/arrow layer definitions
  resources/symbols/     # SVG symbols
  resources/styles/      # CSS for visualization styling
```

### Key Configurations

- **`smartmetconf/smartmet.conf`**: Loads engines (`avi, sputnik, contour, geonames, gis, querydata, grid, observation`) and plugins (`autocomplete, download, edr, timeseries, wms, q3`). Admin UI at `/admin` (credentials: smartmet/smartmet).
- **`smartmetconf/engines/querydata.conf`**: Defines 17 weather model data sources. Each model needs data mounted at `/smartmet/data/{model}/{leveltype}/`.
- **`smartmetconf/plugins/wms.conf`**: Large file (457 lines) defining WMS capabilities, supported EPSG codes, and presentation attributes.
- **`docker-compose.yml`**: Runs SmartMet Server + an FMI downloader sidecar (`fmidev/fmidownloader`) that fetches live MEPS forecast data.

### CI/CD

- **`.github/workflows/docker-image.yml`**: Builds Rocky 9 image. On schedule/merge to master, tags with date derived from newest RPM's build timestamp and pushes to both Docker Hub and GHCR.
- **`.github/workflows/docker-image-rhel10.yml`**: Same for Rocky 10, pushes only to Docker Hub as `fmidev/smartmetserver-rocky10`.

Images are tagged with the RPM build date (not the current date) so the tag reflects the SmartMet version, not when the CI ran.

## Common Change Patterns

- **Adding a plugin/engine**: Install its RPM in the Dockerfile, add its `.conf` to `smartmetconf/`, add it to the engines/plugins list in `smartmet.conf`, and add it to both Dockerfiles if the Rocky 10 variant should have it too (see PR #18 adding `smartmet-plugin-avi` as an example).
- **Adding a new weather model**: Add data directory creation in the Dockerfile (`mkdir -p /smartmet/data/{model}/...`), add a stanza in `smartmetconf/engines/querydata.conf`, and add WMS product JSON under `share/wms/customers/{model}/`.
- **Updating RPM versions**: The Dockerfiles install RPMs from FMI's repository without pinning versions, so a rebuild picks up the latest available packages automatically.
