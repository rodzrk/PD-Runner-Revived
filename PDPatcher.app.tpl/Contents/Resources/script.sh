#!/bin/bash
export PATH="/bin:/sbin:/usr/bin:/usr/sbin"
export LANG=C
export LC_CTYPE=C
export LC_ALL=C

PD_VER="{{version}}-{{build}}"
PD_BEF="{{hash_before}}"
PD_AFT="{{hash_after}}"
PD_I01={{i_01}}
PD_I02={{i_02}}
PD_A01={{a_01}}
PD_A02={{a_02}}
PD_IIN="\x6a\x01\x58\xc3"
PD_AIN="\x20\x00\x80\xd2\xc0\x03\x5f\xd6"

PD_LOC="/Library/Preferences/Parallels/parallels-desktop.loc"
PD_DIR="/Applications/Parallels Desktop.app"; [ -f "${PD_LOC}" ] && PD_DIR=$(cat "${PD_LOC}")
PD_MAC="${PD_DIR}/Contents/MacOS"
PD_SRV="${PD_MAC}/Parallels Service.app/Contents/MacOS/prl_disp_service"
PD_LIC="/Library/Preferences/Parallels/licenses.json"
PD_URL="https://download.parallels.com/desktop/v${PD_VER%%.*}/${PD_VER}/ParallelsDesktop-${PD_VER}.dmg"

MY_VST=$(defaults read "${PD_DIR}/Contents/Info.plist" CFBundleShortVersionString)
MY_VID=$(defaults read "${PD_DIR}/Contents/Info.plist" CFBundleVersion)
MY_VER="${MY_VST}-${MY_VID}"

function throw() {
    echo "$1"; echo "$1" > /tmp/pdp_err.txt
    exit 1
}

[ "$EUID" -ne 0 ] && throw "Permission Error"

[ -d "${PD_DIR}" ] || {
    open -u "${PD_URL}"
    throw "PD Not Found
Please download and install PD ${PD_VER}"
}

[ "${PD_VER}" = "${MY_VER}" ] || {
    open -u "${PD_URL}"
    throw "This patch only applies to PD ${PD_VER}
Current version: ${MY_VER}"
}

[ `md5 -q "${PD_SRV}"` = "${PD_BEF}" ] || {
    [ -f "${PD_SRV}.bak" ] && {
        throw "Already patched!"
    }
    open -u "${PD_URL}"
    throw "PD Service is corrupted, please re-install."
}

pgrep -x "prl_disp_service" || "${PD_MAC}/Parallels Service" service_start
"${PD_MAC}/prlsrvctl" web-portal signout
killall -9 prl_client_app prl_disp_service

cp "${PD_SRV}" "${PD_SRV}.bak"
chmod a-x "${PD_SRV}.bak"

[ "${PD_I01}" -ne -1 ] && { printf "${PD_IIN}" | dd of="${PD_SRV}" obs=1 seek="${PD_I01}" conv=notrunc; }
[ "${PD_I02}" -ne -1 ] && { printf "${PD_IIN}" | dd of="${PD_SRV}" obs=1 seek="${PD_I02}" conv=notrunc; }
[ "${PD_A01}" -ne -1 ] && { printf "${PD_AIN}" | dd of="${PD_SRV}" obs=1 seek="${PD_A01}" conv=notrunc; }
[ "${PD_A02}" -ne -1 ] && { printf "${PD_AIN}" | dd of="${PD_SRV}" obs=1 seek="${PD_A02}" conv=notrunc; }

[ `md5 -q "${PD_SRV}"` = "${PD_AFT}" ] || {
    throw "Error: Content mismatch"
}

chflags noschg "${PD_LIC}"
chflags nouchg "${PD_LIC}"
rm -f "${PD_LIC}" && echo '{"license":"{\"product_version\":\"'"${PD_VER%%.*}"'.*\",\"edition\":2,\"platform\":3,\"product\":7,\"offline\":true,\"cpu_limit\":32,\"ram_limit\":131072}"}' > "${PD_LIC}" || {
    throw "Error: Cannot write license file"
}
chflags schg "${PD_LIC}"

codesign -f -s - --timestamp=none --all-architectures "${PD_SRV}" || {
    throw "Error: Cannot sign app"
}

open -j -a "${PD_DIR}"
sleep 1 && killall -9 prl_client_app
open -a "${PD_DIR}"

exit 0
