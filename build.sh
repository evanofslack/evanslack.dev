#!/usr/bin/env bash
# Cloudflare Pages build script.
# Build command in the Pages dashboard: bash build.sh
#
# Production builds use baseURL from config.yml (https://evanslack.dev/).
# Preview builds override baseURL with the deployment's own URL so links
# stay on the preview host.
set -euo pipefail

if [ "${CF_PAGES_BRANCH:-}" = "main" ] || [ -z "${CF_PAGES_URL:-}" ]; then
  hugo --minify
else
  hugo --minify --baseURL "$CF_PAGES_URL"
fi
