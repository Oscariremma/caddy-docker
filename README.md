# Custom Caddy Docker Build

This repository automates the building and publishing of a custom [Caddy Server](https://caddyserver.com/) Docker image tailored with specific plugins.

## Included Plugins

- **[`caddy-docker-proxy`](https://github.com/lucaslorentz/caddy-docker-proxy)**: Enables configuration of Caddy via Docker labels.
- **[`cloudflare-dns`](https://github.com/caddy-dns/cloudflare)**: Enables solving the DNS challenge for Let's Encrypt using Cloudflare's API.

## Architecture

This project is designed with automatic dependency updates and minimal resulting image footprint in mind:

1. **Go Module approach**: The Caddy server and plugins are pinned in a standard Go module setup (`go.mod`). This makes the ecosystem fully transparent to bots like Dependabot.
2. **From Scratch**: The final Docker image uses `scratch` (distroless) rather than Alpine/Debian, containing purely the static binary and essential certificate/timezone data. This practically eliminates OS-level vulnerabilities and significantly reduces the final image size.
3. **Dynamic Tagging**: GitHub actions will dynamically parse the Caddy version and Docker Proxy version during build, generating informative tags (e.g., `caddy-v2.11.2-cdp-v2.12.0`).

## Configuration Data

The image is configured to store configuration and data in predictable locations:
- **`XDG_CONFIG_HOME`**: `/config`
- **`XDG_DATA_HOME`**: `/data`

When running the container, you should mount volumes to `/config` and `/data` to persist your configuration and Let's Encrypt certificates.

## Automated Dependency Updates

This repository is configured to keep itself up to date via **Dependabot**.

When a new version of Caddy, one of its plugins, or the base build image is released:
1. Dependabot parses `go.mod` or the `Dockerfile` and creates a Pull Request updating the versions.
2. The `.github/workflows/build.yml` Action runs to dry-compile the new image, confirming it is not fundamentally broken.
3. If the build passes—and the repository correctly requires branch protection status checks—the `.github/workflows/dependabot-auto-merge.yml` Action automatically merges the PR!
4. The `build.yml` action then detects a push to `master` and securely builds and publishes the new image directly to GHCR!

## Required Configuration

For automatic PR merging to function correctly, please ensure the repository is configured securely:
1. Go to **Settings** -> **Branches**.
2. Add a protection rule for your default branch (`master` or `main`).
3. Enable **Require status checks to pass before merging**.
4. Check `Build Docker Image` in the list of required checks.
