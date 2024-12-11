#################################
#   EXTRACT DATA FROM APK/AAB   #
#################################

function __generate_app_version_from_apk {
    CI_BUILD_NUMBER=$2
    APK_MANIFEST=$(aapt dump badging $1)
    VERSION_NAME=$(echo "$APK_MANIFEST" | sed -n "s/.*versionName='\([^']*\).*/\1/p")
    VERSION_CODE=$(echo "$APK_MANIFEST" | sed -n "s/.*versionCode='\([^']*\).*/\1/p")
    echo "${VERSION_NAME}b${CI_BUILD_NUMBER}c${VERSION_CODE}"
}

function __generate_app_version_from_aab {
    temp_path=$PWD
    bundletool="${temp_path}/bundletool.jar"
    source="https://github.com/google/bundletool/releases/download/1.17.2/bundletool-all-1.17.2.jar"

    wget -q -nv "${source}" --output-document="${bundletool}" &
    wait
    APK_MANIFEST=$(exec java -jar "${bundletool}" dump manifest --bundle $APP_PATH &
    wait)

    CI_BUILD_NUMBER=$2
    VERSION_CODE=$(echo "$APK_MANIFEST" | sed -n "s/.*versionCode=\"\([^\"]*\).*/\1/p")
    VERSION_NAME=$(echo "$APK_MANIFEST" | sed -n "s/.*versionName=\"\([^\"]*\).*/\1/p")
    echo "${VERSION_NAME}b${CI_BUILD_NUMBER}c${VERSION_CODE}"
}