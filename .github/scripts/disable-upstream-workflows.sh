#!/usr/bin/env bash
##
## Copyright contributors to Besu.
##
## Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
## the License. You may obtain a copy of the License at
##
## http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
## an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
## specific language governing permissions and limitations under the License.
##
## SPDX-License-Identifier: Apache-2.0
##

# Disables every workflow except this fork's own, i.e. those named espresso-*.
#
# Workflow enabled/disabled state lives in GitHub, not in git, so this leaves upstream's
# files untouched and never conflicts with an upstream merge. Re-run after a merge that
# brings in new upstream workflows.
#
# GitHub registers a workflow only once something triggers it, even if the file is on the
# default branch, and an unregistered one cannot be disabled (the API 404s). So upstream's
# workflows each run once before this can turn them off. In practice nothing of theirs
# triggers on a branch push -- ci.yml wants main or a PR, dco.yml a PR, the rest cron.
set -euo pipefail

REPO="${1:-EspressoSystems/besu}"

gh api "repos/$REPO/actions/workflows?per_page=100" \
  --jq '.workflows[] | select(.state == "active") | .path | select(startswith(".github/workflows/")) | select(ltrimstr(".github/workflows/") | startswith("espresso-") | not)' |
  while read -r path; do
    echo "disabling $path"
    gh workflow disable "${path##*/}" --repo "$REPO"
  done
