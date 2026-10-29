#!/usr/bin/env bash
# Renders Pkl examples and validates each against the Arazzo JSON Schema matching its `arazzo` version.
#
# Schemas are published per minor release, so 1.0.0 and 1.0.1 share the 1.0 schema and 1.1.0 uses the 1.1 schema.
#
# Usage: scripts/validate.sh [example.pkl ...]   (defaults to examples/*.pkl)
set -euo pipefail
cd "$(dirname "$0")/.."

if [ "$#" -gt 0 ]; then examples=("$@"); else examples=(examples/*.pkl); fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

for example in "${examples[@]}"; do
  version="$(pkl eval -x arazzo "$example")"
  case "$version" in
    1.0.0|1.0.1) schema=schemas/arazzo-1.0.schema.json ;;
    1.1.0) schema=schemas/arazzo-1.1.schema.json ;;
    *) echo "$example: unsupported arazzo version '$version' (supported: 1.0.0, 1.0.1, 1.1.0)" >&2; exit 1 ;;
  esac

  out="$tmp/$(basename "$example" .pkl).json"
  pkl eval "$example" -o "$out"
  echo -n "$example (arazzo $version): "
  ajv validate --spec=draft2020 --strict=false -c ajv-formats -s "$schema" -d "$out"
done
