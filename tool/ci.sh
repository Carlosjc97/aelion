#!/usr/bin/env bash
set -euo pipefail

flutter analyze
flutter test
npm --prefix functions run build
