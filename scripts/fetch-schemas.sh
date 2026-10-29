#!/usr/bin/env bash
# Re-downloads the published Arazzo JSON Schemas and the spec texts into ./schemas
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p schemas
curl -fsSL https://spec.openapis.org/arazzo/1.0/schema/2025-10-15 -o schemas/arazzo-1.0.schema.json
curl -fsSL https://spec.openapis.org/arazzo/1.1/schema/2026-04-15 -o schemas/arazzo-1.1.schema.json
for version in 1.0.0 1.0.1 1.1.0; do
  curl -fsSL "https://raw.githubusercontent.com/OAI/Arazzo-Specification/main/versions/$version.md" -o "schemas/arazzo-$version.md"
done
