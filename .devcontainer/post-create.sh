#!/usr/bin/env bash
# Installs the latest pkl and ajv-cli into the devcontainer
set -euo pipefail

case "$(uname -m)" in
  x86_64) arch=amd64 ;;
  aarch64|arm64) arch=aarch64 ;;
  *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

sudo curl -fsSL -o /usr/local/bin/pkl \
  "https://github.com/apple/pkl/releases/latest/download/pkl-linux-${arch}"
sudo chmod +x /usr/local/bin/pkl

# ajv-cli with draft 2020-12 support (needed for the Arazzo schemas)
npm install -g ajv-cli@5 ajv-formats@3

pkl --version
ajv help >/dev/null && echo "ajv-cli installed"
