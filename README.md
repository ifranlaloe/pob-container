# PoB Container

A browser-accessible Linux desktop with the current official portable releases of Path of Building Community for Path of Exile 1 and Path of Exile 2.

The desktop is intentionally `linux/amd64`, which lets Wine run PoB's Windows executables on Apple Silicon through Docker's emulation support.

## Start

```sh
docker compose up --build -d
```

Open [http://localhost:6902/](http://localhost:6902/) and use either **Path of Building (PoE 1)** or **Path of Building (PoE 2)** from the desktop application menu.

The first start copies both applications to the `pob-applications` named Docker volume. This can take a moment.

## Persistent data

| Host path or volume | Contents |
| --- | --- |
| `./profiles/poe1` | PoE 1 builds and PoB settings |
| `./profiles/poe2` | PoE 2 builds and PoB settings |
| `./config` | Browser desktop state and Wine prefix |
| `pob-applications` named volume | PoB program files and in-app updates |

PoB's Windows AppData folders are linked to `./profiles`, so saving a build from either app writes to a normal host directory.

## Update PoB

Close the relevant PoB window, then run either command in a terminal inside the desktop:

```sh
pob-update poe1
pob-update poe2
```

Use `pob-update` with no argument to update both editions. The update is written to the persistent `pob-applications` volume and remains after the container is recreated.

You can also rebuild to fetch the latest official PoB releases for both editions:

```sh
docker compose build
docker compose up -d --force-recreate
```

`build.no_cache: true` ensures every normal Compose build downloads the latest releases. At startup, the container refreshes the application volume only when the newly built image contains a different PoB release. Existing `profiles`, `config`, and the named application volume are retained.

Do not use `docker compose down -v` unless you deliberately want to delete the persisted PoB installation. The bind-mounted profiles are never changed by a rebuild.

## Stop

```sh
docker compose down
```
