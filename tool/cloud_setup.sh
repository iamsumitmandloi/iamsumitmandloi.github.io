#!/usr/bin/env bash
# Installs Flutter and fetches this project's dependencies on a fresh Linux
# machine, e.g. a Claude Code cloud session. Safe to run more than once.
#
#   bash tool/cloud_setup.sh
#
# Override FLUTTER_VERSION or FLUTTER_HOME in the environment if needed.
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.47.9}"
FLUTTER_HOME="${FLUTTER_HOME:-/opt/flutter}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ ! -x "$FLUTTER_HOME/bin/flutter" ]; then
  echo "Installing Flutter $FLUTTER_VERSION into $FLUTTER_HOME"
  git clone --quiet --depth 1 --branch "$FLUTTER_VERSION" \
    https://github.com/flutter/flutter.git "$FLUTTER_HOME"
fi
git config --global --add safe.directory "$FLUTTER_HOME"

export PATH="$FLUTTER_HOME/bin:$PATH"
if ! grep -qs "$FLUTTER_HOME/bin" "$HOME/.bashrc"; then
  echo "export PATH=\"$FLUTTER_HOME/bin:\$PATH\"" >> "$HOME/.bashrc"
fi

flutter --disable-analytics > /dev/null
flutter config --no-cli-animations > /dev/null
flutter precache --web

cd "$REPO_DIR"
flutter pub get
flutter --version
