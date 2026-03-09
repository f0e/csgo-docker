#!/bin/bash

mkdir -p "${STEAMAPPDIR}" || true

# update
bash "${STEAMCMDDIR}/steamcmd.sh" +force_install_dir "${STEAMAPPDIR}" \
    +login anonymous \
    +app_update "${STEAMAPPID}" \
    +quit

# patch steam.inf to use the new csgo legacy app id
sed -i 's/^appID=.*/appID=4465480/' "${STEAMAPPDIR}/${STEAMAPP}/steam.inf"

# remove bundled libgcc_s.so.1 - https://forums.alliedmods.net/showthread.php?t=336183
rm -f "${STEAMAPPDIR}/bin/libgcc_s.so.1"

# install metamod
if [ ! -z "$METAMOD_VERSION" ] && [ ! -d "${STEAMAPPDIR}/${STEAMAPP}/addons/metamod" ]; then
    LATESTMM=$(wget -qO- https://mms.alliedmods.net/mmsdrop/"${METAMOD_VERSION}"/mmsource-latest-linux)
    wget -qO- https://mms.alliedmods.net/mmsdrop/"${METAMOD_VERSION}"/"${LATESTMM}" | tar xvzf - -C "${STEAMAPPDIR}/${STEAMAPP}"
fi

# install sourcemod
if [ ! -z "$SOURCEMOD_VERSION" ] && [ ! -d "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod" ]; then
    LATESTSM=$(wget -qO- https://sm.alliedmods.net/smdrop/"${SOURCEMOD_VERSION}"/sourcemod-latest-linux)
    wget -qO- https://sm.alliedmods.net/smdrop/"${SOURCEMOD_VERSION}"/"${LATESTSM}" | tar xvzf - -C "${STEAMAPPDIR}/${STEAMAPP}"
fi

cd "${STEAMAPPDIR}"

# run server
bash "${STEAMAPPDIR}/srcds_run" \
    -game "${STEAMAPP}" \
    -console \
    -autoupdate \
    -steam_dir "${STEAMCMDDIR}" \
    -steamcmd_script "${HOMEDIR}/${STEAMAPP}_update.txt" \
    -usercon \
    ${SRCDS_ARGS}