#!/usr/bin/env bash
# Regenerate data/vault.ttl from the sample vault.
# Whole-vault raw Turtle uses CONSTRUCT (wiki export -f turtle omits FILE only
# serializes one document at a time).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="${ROOT}/sample/wiki.yaml"
OUT="${ROOT}/data/vault.ttl"

mkdir -p "$(dirname "${OUT}")"

wiki -c "${CONFIG}" query \
  "CONSTRUCT { ?s ?p ?o } WHERE { ?s ?p ?o }" \
  -f turtle > "${OUT}"

echo "Wrote ${OUT}"
