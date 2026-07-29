# PoB Container

A browser-accessible Linux desktop with the current official portable releases of Path of Building Community for Path of Exile 1 and Path of Exile 2.

The desktop is intentionally `linux/amd64`, which lets Wine run PoB's Windows executables on Apple Silicon through Docker's emulation support.

## Start

```sh
docker compose up --build -d
```

Open [http://localhost:6902/](http://localhost:6902/) and use either **Path of Building (PoE 1)** or **Path of Building (PoE 2)** from the desktop application menu.

The first start copies both applications to `./.pob-container/applications`. This can take a moment.

## Persistent data

| Host path | Contents |
| --- | --- |
| `./.pob-container/profiles/poe1` | PoE 1 builds and PoB settings |
| `./.pob-container/profiles/poe2` | PoE 2 builds and PoB settings |
| `./.pob-container/config` | Browser desktop state and Wine prefix |
| `./.pob-container/applications` | PoB program files and in-app updates |

PoB's Windows AppData folders are linked to `./.pob-container/profiles`, so saving a build from either app writes to a normal host directory. The container follows the Docker host's local timezone.

## Update PoB

Close the relevant PoB window, then run either command in a terminal inside the desktop:

```sh
pob-update poe1
pob-update poe2
```

Use `pob-update` with no argument to update both editions. The update is written to `./.pob-container/applications` and remains after the container is recreated.

You can also rebuild to fetch the latest official PoB releases for both editions:

```sh
docker compose build
docker compose up -d --force-recreate
```

`build.no_cache: true` ensures every normal Compose build downloads the latest releases. At startup, the container refreshes the application folder only when the newly built image contains a different PoB release. Existing `./.pob-container` data is retained.

All persistent state is contained in `./.pob-container`, making cleanup straightforward. The bind-mounted profiles are never changed by a rebuild.

## Stop

```sh
docker compose down
```
