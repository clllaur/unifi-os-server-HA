#!/bin/bash
# Home Assistant add-on shim for UniFi OS Server.
#
# Home Assistant Supervisor gives every add-on a single persistent volume
# mounted at /data (also where it writes options.json). UniFi OS Server, on the
# other hand, spreads its state across several directories. This shim:
#   1. Translates the add-on options into the environment variables that the
#      upstream UniFi entrypoint expects.
#   2. Relocates UniFi's stateful directories onto the /data volume via symlinks
#      so they survive add-on updates and rebuilds.
# It then execs the original UniFi entrypoint (which boots systemd).
set -e

DATA=/data
OPTS="$DATA/options.json"

# --- 1. Options -> environment ------------------------------------------------
# Parse the two string options without depending on jq being present in the
# UniFi base image. Only export when non-empty so we don't clobber UniFi's own
# "is this set?" checks with empty values.
if [ -f "$OPTS" ]; then
    _read_opt() {
        sed -n 's/.*"'"$1"'"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$OPTS"
    }
    _uos_ip="$(_read_opt UOS_SYSTEM_IP)"
    _hw_platform="$(_read_opt HARDWARE_PLATFORM)"
    [ -n "$_uos_ip" ] && export UOS_SYSTEM_IP="$_uos_ip" && echo "[ha-shim] UOS_SYSTEM_IP=$_uos_ip"
    [ -n "$_hw_platform" ] && export HARDWARE_PLATFORM="$_hw_platform" && echo "[ha-shim] HARDWARE_PLATFORM=$_hw_platform"
fi

# --- 2. Persist UniFi state on the /data volume -------------------------------
# For each UniFi directory, move any image-seeded contents into a namespaced
# subdirectory under /data on first boot, then replace the original path with a
# symlink. UniFi's own /data usage (e.g. /data/uos_uuid) persists natively since
# /data *is* the add-on volume.
persist() {
    local src="$1" dst="$DATA/$2"

    # Already relocated on a previous boot.
    [ -L "$src" ] && return 0

    mkdir -p "$dst"
    if [ -e "$src" ]; then
        # Seed persistent copy with image-provided content, once.
        cp -a "$src/." "$dst/" 2>/dev/null || true
        rm -rf "$src"
    fi
    mkdir -p "$(dirname "$src")"
    ln -s "$dst" "$src"
    echo "[ha-shim] persist $src -> $dst"
}

persist /persistent        persistent
persist /srv               srv
persist /var/lib/unifi      var-lib-unifi
persist /var/lib/mongodb    var-lib-mongodb
persist /var/log            var-log
persist /etc/rabbitmq/ssl   etc-rabbitmq-ssl

# --- 3. Hand off to UniFi's original entrypoint (boots systemd) ---------------
exec /root/uos-entrypoint.sh "$@"
