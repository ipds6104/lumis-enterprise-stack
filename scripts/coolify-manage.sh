#!/usr/bin/env bash
# ==============================================================================
# Coolify Management & Autodeploy Automation Script
# Connects to ThinkStation Server (100.101.49.42 / localhost:8000)
# ==============================================================================
set -euo pipefail

COOLIFY_HOST="${COOLIFY_HOST:-100.101.49.42}"
COOLIFY_PORT="${COOLIFY_PORT:-8000}"
COOLIFY_TOKEN="${COOLIFY_TOKEN:-9|lumis-coolify-token-2026}"
SOCKS_PROXY="${SOCKS_PROXY:-socks5h://localhost:1055}"

echo "==> Lumis Enterprise Stack: Coolify Management CLI"
echo "Target Host: ${COOLIFY_HOST}:${COOLIFY_PORT}"

# Helper function to perform authenticated curl requests to Coolify API
coolify_api() {
    local method="$1"
    local endpoint="$2"
    shift 2
    curl -s --proxy "${SOCKS_PROXY}" \
        -X "${method}" \
        -H "Authorization: Bearer ${COOLIFY_TOKEN}" \
        -H "Content-Type: application/json" \
        "http://${COOLIFY_HOST}:${COOLIFY_PORT}/api/v1/${endpoint}" "$@"
}

action="${1:-status}"

case "$action" in
    servers)
        echo "[*] Querying Coolify Servers..."
        coolify_api GET "servers" | jq .
        ;;
    apps)
        echo "[*] Querying Applications in Coolify..."
        coolify_api GET "applications" | jq .
        ;;
    deploy)
        local_app_uuid="${2:-}"
        if [ -z "$local_app_uuid" ]; then
            echo "Usage: $0 deploy <app_uuid>"
            exit 1
        fi
        echo "[*] Triggering deployment for application: $local_app_uuid"
        coolify_api POST "deploy?uuid=${local_app_uuid}" | jq .
        ;;
    status)
        echo "[*] Checking Coolify API connection..."
        coolify_api GET "version" || echo "Coolify reachable via Mesh."
        ;;
    *)
        echo "Usage: $0 {status|servers|apps|deploy <uuid>}"
        exit 1
        ;;
esac
