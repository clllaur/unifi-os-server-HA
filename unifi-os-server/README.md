# UniFi OS Server — Home Assistant add-on

Run [UniFi OS Server](https://blog.ui.com/article/introducing-unifi-os-server)
as a Home Assistant add-on.

This is an **experimental**, privileged add-on that runs UniFi's full
`systemd` service stack. See [DOCS.md](DOCS.md) for full installation,
configuration, networking and troubleshooting details.

## Quick start

1. Add the repository to Home Assistant:
   `https://github.com/clllaur/unifi-os-server-HA`
2. Install **UniFi OS Server** from the Add-on Store.
3. Set `UOS_SYSTEM_IP` to your host's LAN IP or hostname.
4. Start the add-on and open `https://<home-assistant-host>:443`.

> Uses **host networking** — UniFi binds its ports (443, 8080, 3478/udp, …)
> directly on the Home Assistant host. Make sure those ports are free.
