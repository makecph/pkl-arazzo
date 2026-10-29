#!/usr/bin/env bash
# Publishes the package metadata file of a built package to the root of the gh-pages branch. Pkl fetches the metadata
# for package://raw.githubusercontent.com/makecph/pkl-arazzo/gh-pages/arazzo@<version> from there, through
# https://raw.githubusercontent.com/makecph/pkl-arazzo/gh-pages/arazzo@<version>.
#
# Usage: scripts/publish-metadata.sh <version> <package output dir>
set -euo pipefail

version="${1:?usage: publish-metadata.sh <version> <package output dir>}"
out="$(cd "${2:?usage: publish-metadata.sh <version> <package output dir>}" && pwd)"
metadata="$out/arazzo@$version"
[ -f "$metadata" ] || { echo "$metadata does not exist" >&2; exit 1; }

cd "$(dirname "$0")/.."
pages="$(mktemp -d)/pages"
trap 'git worktree remove --force "$pages" 2>/dev/null || true' EXIT

if git ls-remote --exit-code --heads origin gh-pages >/dev/null 2>&1; then
  git fetch --quiet origin gh-pages
  git worktree add --quiet -B gh-pages "$pages" origin/gh-pages
else
  git worktree add --quiet --orphan -b gh-pages "$pages"
fi

cp "$metadata" "$pages/"

cd "$pages"
git add -A
if git diff --cached --quiet; then
  echo "arazzo@$version is already published"
  exit 0
fi
git commit --quiet -m "Publish arazzo $version metadata"
git push --quiet origin gh-pages
echo "Published arazzo@$version"
