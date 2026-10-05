#!/usr/bin/env bash
# Cloud Agent install: wire redBus analytics Cursor skills into ~/.cursor/skills
set -euo pipefail

ROOT="${WORKSPACE_ROOT:-}"
if [[ -z "$ROOT" ]]; then
  if [[ -d /workspace/repos ]]; then
    ROOT=/workspace/repos
  elif [[ -d /workspace/bus-product-analysis ]]; then
    ROOT=/workspace
  elif [[ -d /agent/repos/bus-product-analysis ]]; then
    ROOT=/agent/repos
  else
    ROOT="$(pwd)"
  fi
fi

SKILLS_DIR="${HOME}/.cursor/skills"
mkdir -p "$SKILLS_DIR"

link_skill() {
  local src="$1"
  local name="$2"
  if [[ -f "$src/SKILL.md" ]]; then
    rm -rf "$SKILLS_DIR/$name"
    ln -sfn "$src" "$SKILLS_DIR/$name"
    echo "linked $name -> $src"
  else
    echo "skip missing $src" >&2
  fi
}

# Prefer dedicated CR Analytics package, then query-repo skills/, then bus-product-analysis
CR_LOCAL=/home/ubuntu/cr-analytics/skills
QR="$ROOT/cursor-skills-query-repository/skills"
BPA_SKILLS="$ROOT/bus-product-analysis/skills"
BPA="$ROOT/bus-product-analysis"

resolve_skill() {
  local name="$1"
  if [[ -f "$CR_LOCAL/$name/SKILL.md" ]]; then
    echo "$CR_LOCAL/$name"
  elif [[ -f "$QR/$name/SKILL.md" ]]; then
    echo "$QR/$name"
  elif [[ -f "$BPA_SKILLS/$name/SKILL.md" ]]; then
    echo "$BPA_SKILLS/$name"
  elif [[ -f "$BPA/$name/SKILL.md" ]]; then
    echo "$BPA/$name"
  elif [[ -f "$ROOT/$name/SKILL.md" ]]; then
    echo "$ROOT/$name"
  else
    echo ""
  fi
}

SKILLS=(
  cr-analyser
  cr-analytics-assistant
  cr-dim-usertype cr-dim-dbd cr-dim-lmb cr-dim-channel
  cr-dim-region-tier cr-dim-sd-type cr-dim-custom-sd cr-dim-ga-plugin
  cr-dim-operator cr-dim-bo-type cr-dim-age-gender cr-dim-bus-type
  women-funnel-analytics return-tier-pilgrim lmb-newbus-analytics
  experiment-coverage-analytics toilet-cohort-analytics seat-bus-images
  metro-surface-analytics filter-usage-analytics syed-athena-queries
  query-repository
)

for name in "${SKILLS[@]}"; do
  src="$(resolve_skill "$name")"
  if [[ -n "$src" ]]; then
    link_skill "$src" "$name"
  else
    echo "skip missing $name" >&2
  fi
done

echo "Installed skills:"
ls -la "$SKILLS_DIR" | sed -n '1,80p'
