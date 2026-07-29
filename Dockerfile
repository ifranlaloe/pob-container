# syntax=docker/dockerfile:1.7
FROM --platform=linux/amd64 lscr.io/linuxserver/webtop:latest

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV POB_SEED_ROOT=/opt/pob-seed \
    POB_ROOT=/opt/pob \
    WINE_MONO_VERSION=11.0.0 \
    WINE_MONO_MSI=/opt/wine-mono/wine-mono-11.0.0-x86.msi

# PoB is a 64-bit Windows application. Wine runs it inside the browser-accessible
# Linux desktop supplied by webtop.
RUN apk add --no-cache \
        bash \
        ca-certificates \
        curl \
        jq \
        rsync \
        unzip \
        wine \
        xfce4-whiskermenu-plugin

# Alpine does not package Wine Mono. Keep the official WineHQ MSI in the image
# so each persistent Wine prefix can install it silently on first PoB launch.
RUN set -eu; \
    mkdir -p "$(dirname "${WINE_MONO_MSI}")"; \
    curl --fail --location --silent --show-error \
        "https://dl.winehq.org/wine/wine-mono/${WINE_MONO_VERSION}/wine-mono-${WINE_MONO_VERSION}-x86.msi" \
        --output "${WINE_MONO_MSI}"; \
    test -s "${WINE_MONO_MSI}"

# Download the current portable releases. docker-compose.yml sets build.no_cache
# so this layer is deliberately re-run on every normal Compose build.
RUN set -eu; \
    fetch_release() { \
        local repository="$1"; \
        local asset_name="$2"; \
        local destination="$3"; \
        local release_json download_url version; \
        release_json="$(curl --fail --location --silent --show-error "https://api.github.com/repos/${repository}/releases/latest")"; \
        version="$(jq --raw-output '.tag_name' <<<"${release_json}")"; \
        download_url="$(jq --raw-output --arg asset "${asset_name}" '.assets[] | select(.name == $asset) | .browser_download_url' <<<"${release_json}")"; \
        test -n "${version}" && test "${version}" != "null"; \
        test -n "${download_url}" && test "${download_url}" != "null"; \
        mkdir -p "${destination}"; \
        curl --fail --location --silent --show-error "${download_url}" --output /tmp/pob-release.zip; \
        unzip -q /tmp/pob-release.zip -d "${destination}"; \
        printf '%s\n' "${version}" > "${destination}/.pob-image-version"; \
        rm -f /tmp/pob-release.zip; \
    }; \
    fetch_release "PathOfBuildingCommunity/PathOfBuilding" "PathOfBuildingCommunity-Portable.zip" "${POB_SEED_ROOT}/poe1"; \
    fetch_release "PathOfBuildingCommunity/PathOfBuilding-PoE2" "PathOfBuildingCommunity-PoE2-Portable.zip" "${POB_SEED_ROOT}/poe2"; \
    test -f "${POB_SEED_ROOT}/poe1/Path of Building.exe"; \
    test -f "${POB_SEED_ROOT}/poe2/Path of Building-PoE2.exe"; \
    mkdir -p "${POB_ROOT}"

COPY --chmod=755 custom-cont-init.d/10-reset-xfce-state /custom-cont-init.d/10-reset-xfce-state
COPY --chmod=755 custom-cont-init.d/15-add-pob-panel-launchers /custom-cont-init.d/15-add-pob-panel-launchers
COPY --chmod=755 custom-cont-init.d/20-remove-unavailable-xfce-panel-plugins /custom-cont-init.d/20-remove-unavailable-xfce-panel-plugins
COPY --chmod=755 custom-cont-init.d/30-install-or-refresh-pob /custom-cont-init.d/30-install-or-refresh-pob
COPY --chmod=755 bin/pob-launch bin/pob-update /usr/local/bin/
COPY applications/path-of-building-poe1.desktop applications/path-of-building-poe2.desktop /usr/share/applications/
COPY xfce/xfce4-panel.xml /opt/pob-xfce/xfce4-panel.xml
