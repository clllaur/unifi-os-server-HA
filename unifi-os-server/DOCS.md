# UniFi OS Server

Self-hosted [UniFi OS Server](https://blog.ui.com/article/introducing-unifi-os-server)
running as a Home Assistant add-on. It packages the image built by
[clllaur/unifi-os-server](https://github.com/clllaur/unifi-os-server), which is
extracted from UniFi's official self-hosting installer.

> **Experimental.** UniFi OS Server runs a full `systemd` service stack
> (MongoDB, RabbitMQ, PostgreSQL, nginx, …) inside the container. That requires
> a **privileged** container with **AppArmor disabled** and **host networking**.
> Only install this on a machine you control and understand the security
> implications of running a privileged add-on.

## Requirements

- A Home Assistant installation that supports add-ons (Home Assistant OS or
  Supervised). Home Assistant Container / Core cannot run add-ons.
- `amd64` or `aarch64` architecture.
- Enough resources for a full UniFi controller: **2 GB+ RAM** recommended.
- Ports used by UniFi (443, 8080, 3478/udp, 10001/udp, 10003/udp, …) must be
  free on the host — see [Networking](#networking).

## Installation

1. In Home Assistant, go to **Settings → Add-ons → Add-on Store**.
2. Open the **⋮** menu (top right) → **Repositories** and add:

   ```
   https://github.com/clllaur/unifi-os-server-HA
   ```

3. Find **UniFi OS Server** in the store and click **Install**.
4. On the **Configuration** tab, set the options below.
5. Start the add-on, then open the Web UI (`https://<home-assistant-host>:443`).

## Configuration

| Option | Required | Description |
| --- | --- | --- |
| `UOS_SYSTEM_IP` | Recommended | Hostname or IP that devices use to reach UniFi OS Server (written to UniFi's `system.properties` as `system_ip`). Use the Home Assistant host's LAN IP or a DNS name. |
| `HARDWARE_PLATFORM` | No | Force a hardware platform. Only accepted value is `synology`. Leave empty for auto-detection. |

Example:

```yaml
UOS_SYSTEM_IP: unifi.example.com
HARDWARE_PLATFORM: ""
```

## Networking

This add-on uses **host networking** (`host_network: true`), which is required
for UniFi's Layer-2 device discovery and adoption to work. As a result UniFi
binds its ports **directly on the Home Assistant host** — they are **not**
remapped the way the upstream `docker-compose.yaml` remaps `443 → 11443`.

Make sure these host ports are free (nothing else, including Home Assistant's
own reverse proxy, is bound to them):

| Protocol | Port | Usage |
| --- | --- | --- |
| TCP | 443 | UniFi OS Server GUI / API |
| TCP | 8080 | Device and application communication (inform) |
| UDP | 3478 | STUN (adoption + remote management) |
| UDP | 10001 | Device discovery (broadcast) |
| UDP | 10003 | Device discovery during adoption |
| TCP | 5005, 6789, 8444, 8880-8882, 9543, 5671 | Optional features (RTP, speed test, hotspot, identity hub, AMQPS) |
| UDP | 5514 | Optional remote syslog |

If port `443` conflicts with another service on the host, this add-on is not a
good fit in host-network mode — UniFi does not support remapping its GUI port.

## Adopting devices

- **Same L2 network:** devices should be discovered automatically thanks to host
  networking.
- **Different subnet / manual:** SSH into the device (`ubnt` / `ubnt`) and set
  the inform URL:

  ```bash
  set-inform http://<UOS_SYSTEM_IP>:8080/inform
  ```

## Data & backups

All UniFi state (MongoDB, `/var/lib/unifi`, `/persistent`, `/srv`,
`/etc/rabbitmq/ssl`, logs) is relocated onto the add-on's `/data` volume by the
entrypoint shim, so it persists across add-on restarts, updates and rebuilds and
is included in Home Assistant backups.

> Because the full UniFi stack can be large, the backup can be sizeable. You can
> exclude it per-add-on in Home Assistant backup settings if desired.

## Updating

The add-on version tracks the upstream image version. When a new UniFi OS Server
image is published in `clllaur/unifi-os-server`, bump:

- `unifi-os-server/config.yaml` → `version`
- `unifi-os-server/build.yaml` → `build_from` tags
- `unifi-os-server/CHANGELOG.md`

Pushing to `main` triggers the CI workflow that rebuilds and publishes the
per-architecture images to `ghcr.io/clllaur/<arch>-addon-unifi-os-server`.

## Troubleshooting

- **Add-on won't start / systemd errors:** confirm you are on Home Assistant OS
  or Supervised (not Container/Core) and that AppArmor is disabled for the
  add-on (it is by default in this config).
- **Devices won't adopt:** verify `UOS_SYSTEM_IP` is reachable from the device
  and that UDP 3478/10001/10003 are not blocked.
- **Port already in use:** something else on the host is bound to 443/8080 —
  free it or stop the conflicting service.

## Credits

- UniFi OS Server is a product of Ubiquiti Inc.
- Upstream Docker/Kubernetes packaging:
  [clllaur/unifi-os-server](https://github.com/clllaur/unifi-os-server)
  (fork of [lemker/unifi-os-server](https://github.com/lemker/unifi-os-server)).
