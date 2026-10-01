#!/usr/bin/env bash
# Disables every workflow except this fork's own, i.e. those named espresso-*.
#
# Workflow enabled/disabled state lives in GitHub, not in git, so this leaves upstream's
# files untouched and never conflicts with an upstream merge. Re-run after a merge that
# brings in new upstream workflows.
#
# Workflows only register after Actions is enabled on the fork (Actions tab -> "I
# understand my workflows, go ahead and enable them"); until then this lists nothing.
set -euo pipefail

REPO="${1:-EspressoSystems/besu}"

gh api "repos/$REPO/actions/workflows?per_page=100" \
  --jq '.workflows[] | select(.state == "active") | .path | select(startswith(".github/workflows/")) | select(ltrimstr(".github/workflows/") | startswith("espresso-") | not)' |
  while read -r path; do
    echo "disabling $path"
    gh workflow disable "${path##*/}" --repo "$REPO"
  done
