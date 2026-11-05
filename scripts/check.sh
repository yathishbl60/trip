#!/usr/bin/env bash
# Source-only validation; never builds the app or runs benchmarks.
set -euo pipefail
repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
python3 "$repo_root/scripts/check_architecture.py"
python3 "$repo_root/scripts/workspace.py" check
python3 "$repo_root/scripts/check_project_skills.py"
python3 "$repo_root/scripts/check_localization.py"
python3 "$repo_root/scripts/check_design_system.py"
bash "$repo_root/scripts/audit_sources.sh"
git -C "$repo_root" diff --check
