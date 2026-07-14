# Changelog

## 1.4.0

- Initial Home Assistant add-on release.
- Wraps `ghcr.io/clllaur/unifi-os-server:v1.4.0` (UniFi OS Server 5.1.21).
- Host networking for device discovery and adoption.
- Persistent state relocated onto the add-on `/data` volume so it survives
  add-on updates and rebuilds.
- Configurable `UOS_SYSTEM_IP` and `HARDWARE_PLATFORM` options.
