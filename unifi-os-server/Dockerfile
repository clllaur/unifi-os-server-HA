# Wrap the pre-built UniFi OS Server image with a Home Assistant persistence
# shim. BUILD_FROM is supplied by the Home Assistant builder from build.yaml.
ARG BUILD_FROM
FROM ${BUILD_FROM}

# STOPSIGNAL (SIGRTMIN+3) and the UniFi entrypoint are inherited from the base
# image. We only prepend a shim that maps add-on options to environment
# variables and relocates persistent state onto the /data volume before
# handing off to the original UniFi entrypoint.
COPY ha-entrypoint.sh /usr/local/bin/ha-entrypoint.sh
RUN chmod +x /usr/local/bin/ha-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/ha-entrypoint.sh"]
