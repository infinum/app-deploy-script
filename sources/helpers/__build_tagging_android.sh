source /usr/local/bin/.app-deploy-sources/__constants.sh

#################################
#   EXTRACT DATA FROM APK/AAB   #
#################################

function __generate_app_version_from_apk {
    APP_PATH="$1"
    CI_BUILD_NUMBER=$2
    APK_MANIFEST=$(aapt dump badging "${APP_PATH}")
    VERSION_NAME=$(echo "$APK_MANIFEST" | sed -n "s/.*versionName='\([^']*\).*/\1/p")
    VERSION_CODE=$(echo "$APK_MANIFEST" | sed -n "s/.*versionCode='\([^']*\).*/\1/p")

    CI_BUILD_SUFFIX=""
    [[ -n "${CI_BUILD_NUMBER}" ]] && CI_BUILD_SUFFIX="b${CI_BUILD_NUMBER}"
    VERSION_CODE_SUFFIX=""
    [[ -n "${VERSION_CODE}" ]] && VERSION_CODE_SUFFIX="c${VERSION_CODE}"
    echo "${VERSION_NAME}${CI_BUILD_SUFFIX}${VERSION_CODE_SUFFIX}"
}

function __generate_app_version_from_aab {

    APP_PATH="$1"
    CI_BUILD_NUMBER=$2

    temp_path=$PWD
    bundletool="${temp_path}/bundletool.jar"
    source="https://github.com/google/bundletool/releases/download/${BUNDLE_TOOL_VERSION}/bundletool-all-1.17.2.jar"

    wget -q -nv "${source}" --output-document="${bundletool}" &
    wait
    APK_MANIFEST=$(exec java -jar "${bundletool}" dump manifest --bundle "${APP_PATH}" &
    wait)

    VERSION_CODE=$(echo "$APK_MANIFEST" | sed -n "s/.*versionCode=\"\([^\"]*\).*/\1/p")
    VERSION_NAME=$(echo "$APK_MANIFEST" | sed -n "s/.*versionName=\"\([^\"]*\).*/\1/p")

    CI_BUILD_SUFFIX=""
    [[ -n "${CI_BUILD_NUMBER}" ]] && CI_BUILD_SUFFIX="b${CI_BUILD_NUMBER}"
    VERSION_CODE_SUFFIX=""
    [[ -n "${VERSION_CODE}" ]] && VERSION_CODE_SUFFIX="c${VERSION_CODE}"
    echo "${VERSION_NAME}${CI_BUILD_SUFFIX}${VERSION_CODE_SUFFIX}"
}