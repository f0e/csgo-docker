FROM cm2network/steamcmd:root AS build_stage

ENV STEAMAPPID=740
ENV STEAMAPP=csgo
ENV STEAMAPPDIR="${HOMEDIR}/${STEAMAPP}-dedicated"

COPY entry.sh "${HOMEDIR}/entry.sh"

RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        wget \
        ca-certificates \
        lib32z1 \
    && mkdir -p "${STEAMAPPDIR}" \
    && { \
        echo '@ShutdownOnFailedCommand 1'; \
        echo '@NoPromptForPassword 1'; \
        echo 'force_install_dir '"${STEAMAPPDIR}"''; \
        echo 'login anonymous'; \
        echo 'app_update '"${STEAMAPPID}"''; \
        echo 'quit'; \
       } > "${HOMEDIR}/${STEAMAPP}_update.txt" \
    && chmod +x "${HOMEDIR}/entry.sh" \
    && chown -R "${USER}:${USER}" "${HOMEDIR}/entry.sh" "${STEAMAPPDIR}" "${HOMEDIR}/${STEAMAPP}_update.txt" \
    && rm -rf /var/lib/apt/lists/*

FROM build_stage AS csgo-base

# Pass any srcds launch args here, e.g. "+game_type 0 +game_mode 1 +map de_dust2"
ENV SRCDS_ARGS=""

USER ${USER}
WORKDIR ${HOMEDIR}

CMD ["bash", "entry.sh"]

EXPOSE 27015/tcp \
    27015/udp \
    27020/udp

FROM csgo-base AS csgo-metamod
ENV METAMOD_VERSION=1.12

FROM csgo-metamod AS csgo-sourcemod
ENV SOURCEMOD_VERSION=1.12