source "$APP_DEPLOY_SOURCES/__constants.sh"

#################################
#   EXTRACT DATA FROM APK/AAB   #
#################################

# These functions run inside $(...), where `set -e` doesn't apply, so every failure returns explicitly.
# Errors go to stderr, as stdout is the extracted version.

function __generate_app_version_from_apk {
    APP_PATH="$1"
    CI_BUILD_NUMBER=$2

    __require_tools aapt || return 1
    APK_MANIFEST=$(aapt dump badging "${APP_PATH}") || {
        echo "Error: aapt couldn't read ${APP_PATH}." >&2
        return 1
    }
    VERSION_NAME=$(echo "$APK_MANIFEST" | sed -n "s/.*versionName='\([^']*\).*/\1/p")
    VERSION_CODE=$(echo "$APK_MANIFEST" | sed -n "s/.*versionCode='\([^']*\).*/\1/p")

    __android_app_version
}

function __generate_app_version_from_aab {
    APP_PATH="$1"
    CI_BUILD_NUMBER=$2

    __require_tools java wget || return 1
    bundletool="$(mktemp)"
    source="https://github.com/google/bundletool/releases/download/${BUNDLE_TOOL_VERSION}/bundletool-all-${BUNDLE_TOOL_VERSION}.jar"

    if ! wget -q -nv "${source}" --output-document="${bundletool}"; then
        echo "Error: couldn't download bundletool from ${source}." >&2
        rm -f "${bundletool}"
        return 1
    fi
    APK_MANIFEST=$(java -jar "${bundletool}" dump manifest --bundle "${APP_PATH}")
    BUNDLETOOL_STATUS=$?
    rm -f "${bundletool}"
    if [[ $BUNDLETOOL_STATUS -ne 0 ]]; then
        echo "Error: bundletool couldn't read ${APP_PATH}." >&2
        return 1
    fi

    VERSION_CODE=$(echo "$APK_MANIFEST" | sed -n "s/.*versionCode=\"\([^\"]*\).*/\1/p")
    VERSION_NAME=$(echo "$APK_MANIFEST" | sed -n "s/.*versionName=\"\([^\"]*\).*/\1/p")

    __android_app_version
}

# Builds the version from VERSION_NAME, VERSION_CODE and CI_BUILD_NUMBER
function __android_app_version {
    if [[ -z "${VERSION_NAME}" ]]; then
        echo "Error: no versionName found in ${APP_PATH}." >&2
        return 1
    fi

    CI_BUILD_SUFFIX=""
    [[ -n "${CI_BUILD_NUMBER}" ]] && CI_BUILD_SUFFIX="b${CI_BUILD_NUMBER}"
    VERSION_CODE_SUFFIX=""
    [[ -n "${VERSION_CODE}" ]] && VERSION_CODE_SUFFIX="c${VERSION_CODE}"
    echo "${VERSION_NAME}${CI_BUILD_SUFFIX}${VERSION_CODE_SUFFIX}"
}

function __require_tools {
    for tool in "$@"; do
        if ! command -v "$tool" > /dev/null; then
            echo "Error: $tool is required to read the app version, but it isn't on PATH." >&2
            return 1
        fi
    done
}
