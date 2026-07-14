# UniFi OS Server — Home Assistant Add-on Repository

A [Home Assistant](https://www.home-assistant.io) add-on repository for running
[UniFi OS Server](https://blog.ui.com/article/introducing-unifi-os-server)
self-hosted, using the image built by
[clllaur/unifi-os-server](https://github.com/clllaur/unifi-os-server).

## Add this repository

**Settings → Add-ons → Add-on Store → ⋮ → Repositories**, then add:

```
https://github.com/clllaur/unifi-os-server-HA
```

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fclllaur%2Funifi-os-server-HA)

## Add-ons

| Add-on | Description |
| --- | --- |
| [UniFi OS Server](./unifi-os-server) | Self-hosted UniFi OS Server running its native `systemd` stack. **Experimental / privileged.** |

## About

- The add-on wraps the pre-built, multi-arch image
  `ghcr.io/clllaur/unifi-os-server`, extracted from UniFi's official
  self-hosting installer by the upstream repository.
- Per-architecture add-on images are built by CI and published to
  `ghcr.io/clllaur/<arch>-addon-unifi-os-server`.
- Requires Home Assistant OS or Supervised (add-ons are not available on
  Home Assistant Container / Core).

See the [add-on documentation](./unifi-os-server/DOCS.md) for details.

## License

See [LICENSE](LICENSE). UniFi and UniFi OS Server are trademarks of Ubiquiti Inc.
