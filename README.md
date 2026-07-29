# PoB Container

A browser-accessible Alpine Linux desktop with the current official portable releases of Path of Building Community for Path of Exile 1 and Path of Exile 2.

The desktop is intentionally `linux/amd64`, which lets Wine run PoB's Windows executables on Apple Silicon through Docker's emulation support.

## Start

```sh
docker compose up --build -d
```

Open [http://localhost:7633/](http://localhost:7633/) and use either **Path of Building (PoE 1)** or **Path of Building (PoE 2)** from the desktop application menu.

The first start copies both applications to `~/.pob-container/applications`. This can take a moment.

## Persistent data

| Host path | Contents |
| --- | --- |
| `~/.pob-container/profiles/poe1` | PoE 1 builds and PoB settings |
| `~/.pob-container/profiles/poe2` | PoE 2 builds and PoB settings |
| `~/.pob-container/config` | Browser desktop state and Wine prefix |
| `~/.pob-container/applications` | PoB program files and in-app updates |

PoB's Windows AppData folders are linked to `~/.pob-container/profiles`, so saving a build from either app writes to a normal host directory. Docker Compose creates the folder automatically on first start. The container follows the Docker host's local timezone.

## Alpine compatibility

Wine Mono is bundled in the image and installed silently into the persistent Wine prefix on the first PoB launch, so Wine does not show its Mono installer prompt. On the first Alpine start, the container resets only an inherited XFCE configuration and uses Webtop's standard Alpine panel and dock. Wine, PoB, and saved profiles are not reset.

PoE 1 and PoE 2 are regular desktop applications. They appear under **Games** in the Whisker menu, can be found by typing `Path of Building`, and are the first two shortcuts in the standard bottom dock. Their launcher icons are extracted from each official portable release during the image build.

On Apple Silicon, Docker Desktop runs this amd64 Wine image through Rosetta. The image includes a tiny Alpine compatibility library so XFCE's application scanner works normally there; the Whisker menu and stock dock are not limited to placeholder shortcuts.

## Customize the desktop

The desktop is intentionally yours to customize. Right-click an empty area of the XFCE panel to open **Panel Preferences** or **Add New Items**. The Whisker menu can be configured from its own right-click menu.

All of these changes are saved in `~/.pob-container/config` and survive restarts, rebuilds, and image upgrades. The container configures the standard Alpine panel only once, then leaves your panel and menu layout untouched.

## Update PoB

Close the relevant PoB window, then run either command in a terminal inside the desktop:

```sh
pob-update poe1
pob-update poe2
```

Use `pob-update` with no argument to update both editions. The update is written to `~/.pob-container/applications` and remains after the container is recreated.

You can also rebuild to fetch the latest official PoB releases for both editions:

```sh
docker compose build
docker compose up -d --force-recreate
```

`build.no_cache: true` ensures every normal Compose build downloads the latest releases. At startup, the container refreshes the application folder only when the newly built image contains a different PoB release. Existing `~/.pob-container` data is retained.

All persistent state is contained in `~/.pob-container`, making cleanup straightforward. The bind-mounted profiles are never changed by a rebuild.

## Stop

```sh
docker compose down
```
