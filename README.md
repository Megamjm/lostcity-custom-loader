# lostcity-custom-loader

Custom content loader for **Lost City RS 274** on Unraid + Docker Compose
(`ghcr.io/mserajnik/lost-city-rs:274`, Node/tsx image).

On every container start the loader:

1. Copies every folder under `/custom` (except `_loader`) into Content
2. Registers missing `loc.pack` / `npc.pack` / `obj.pack` / `varp.pack` / `inv.pack` / `map.pack` IDs
3. Writes `engine/.env` including `BUILD_VERIFY=false` (required for custom locs)
4. Starts the world with `tsx` — **does not** call the image `start` script, which overwrites `.env` and drops `BUILD_VERIFY`

## Provided package: homesteads

`packages/homesteads` is the land-deed / island / house-stamp content pack.

Drop more packs later as:

```
packages/<name>/content/scripts/<folder>/
packages/<name>/content/maps/*.jm2
```

`install.sh` copies every `packages/*` directory into `/custom/<name>` on the array.

## Unraid install

```bash
mkdir -p /mnt/user/Data/runescape_custom
cd /mnt/user/Data/runescape_custom
git clone https://github.com/Megamjm/lostcity-custom-loader.git
cd lostcity-custom-loader
bash install.sh
docker restart lostcity
docker logs -f --tail 80 lostcity
```

Expect:

```
[custom-loader] wrote engine .env with BUILD_VERIFY=false
[custom-loader] migrate + start (tsx)
INFO  World is ready
```

### Update later

```bash
cd /mnt/user/Data/runescape_custom/lostcity-custom-loader
git pull
bash install.sh
docker restart lostcity
```

## Compose (required)

The stack must mount the custom tree and run the loader instead of image `start`:

```yaml
services:
  app:
    image: ghcr.io/mserajnik/lost-city-rs:274
    container_name: lostcity
    user: "1000:1000"
    command: ["bash", "/custom/_loader/boot.sh"]
    volumes:
      - /mnt/user/appdata/lostcity/database:/opt/lost-city-rs/database
      - /mnt/user/appdata/lostcity/players:/opt/lost-city-rs/engine/data/players
      - /mnt/user/Data/runescape_custom/custom:/custom:ro
```

Full example: `compose/docker-compose.example.yml`.

After editing compose in the Unraid GUI, use **Apply** / `up -d --force-recreate` so `command` and env take effect.

## Environment variables

The image `start` script only copies a **fixed** list into `engine/.env`. This loader writes `.env` itself so custom flags survive.

| Variable | Default | Purpose |
| --- | --- | --- |
| `TZ` | `America/New_York` | Container timezone (Compose only) |
| `WEB_PORT` | `8888` | Web client |
| `WEB_MANAGEMENT_PORT` | `8898` | Management UI |
| `NODE_MEMBERS` | `true` | Members world |
| `NODE_XPRATE` | `1` | XP rate |
| `NODE_PRODUCTION` | `false` | Production mode |
| `NODE_DEBUG` | `true` | Debug logging |
| `NODE_STAFF` | `caelum` | Comma-separated staff accounts |
| `NODE_DEBUGPROC_CHAR` | `~` | Prefix for debugprocs (`::~home_help`) |
| `LOGIN_SERVER` | `true` | Embedded login |
| `LOGIN_HOST` | `localhost` | Login host |
| `LOGIN_PORT` | `43500` | Login port |
| `FRIEND_SERVER` | `true` | Friends |
| `FRIEND_HOST` | `localhost` | |
| `FRIEND_PORT` | `45099` | |
| `LOGGER_SERVER` | `true` | Logger |
| `LOGGER_HOST` | `localhost` | |
| `LOGGER_PORT` | `43501` | |
| `DB_BACKEND` | `sqlite` | Database |
| `EASY_STARTUP` | `true` | Image helper |
| `WEBSITE_REGISTRATION` | `false` | Web registration |
| `BUILD_VERIFY` | **always `false`** | Must be false or custom locs fail CRC |

`BUILD_VERIFY` is forced to `false` in `loader/boot.sh`. Putting it only in Compose is not enough — the stock `start` script will wipe it.

## In-game (staff)

With `NODE_DEBUGPROC_CHAR=~`:

```
::~home_help
::~home_setup
::~home_village
```

## Layout

```
loader/boot.sh                 # container entry
loader/register-pack-ids.sh    # pack ID self-heal
packages/homesteads/           # provided content pack
compose/docker-compose.example.yml
install.sh                     # copies loader + packages onto the array
```

## Notes

- Image paths: Content `/opt/lost-city-rs/content`, engine `/opt/lost-city-rs/engine`.
- `/custom` is mounted read-only. The loader copies into the container writable layer.
- Rebuilds wipe that layer. `git pull && bash install.sh && docker restart lostcity` puts files back; boot re-registers pack IDs.
- 274 NPC combat uses `hitpoints=` / `attack=` / `strength=` / `defence=`, not `stats=`.
