source /usr/local/bin/.app-deploy-sources/__constants.sh
source /usr/local/bin/.app-deploy-sources/__build_tagging_ios.sh
source /usr/local/bin/.app-deploy-sources/__build_tagging_android.sh

#################################
#        CREATE BUILD TAG       #
#################################

# Main logic

function __build_tagging {

    __validate_options "$@"


    echo "Env -> $ENVIRONMENT"
    echo "Path -> $APP_PATH"
    echo "Build version -> $BUILD_VERSION"

    APP_VERSION=""

    APP_PLATFORM=$(__check_platform)
    if [ "$APP_PLATFORM" == "$PLATFORM_ANDROID_APK" ]; then
        __generate_app_version_from_apk "$APP_PATH"
    elif [ "$APP_PLATFORM" == "$PLATFORM_ANDROID_AAB" ]; then
        __generate_app_version_from_aab "$APP_PATH"
    elif [ "$APP_PLATFORM" == "$PLATFORM_IOS" ]; then
        APP_VERSION=$(__generate_app_version_from_ipa "$APP_PATH")
    else
        echo
        echo "Unsupported file format: ${APP_PATH##*.}"
        echo "Please use only supported file formats: apk, aab, or ipa"
        echo
        exit 1
    fi

    echo "Tag:"
    echo "${ENVIRONMENT}/${APP_VERSION}b${BUILD_VERSION}"
}

# Validation and checks

function __validate_options {
    shift

    while getopts "e:p:v:" opt; do
        case "$opt" in
            e) ENVIRONMENT="$OPTARG" ;;
            p) APP_PATH="$OPTARG" ;;
            v) BUILD_VERSION="$OPTARG" ;;
            *) echo "Error: Invalid option"; exit 1 ;;
        esac
    done

    # Check if all mandatory options are provided
    if [[ -z "$ENVIRONMENT" || -z "$APP_PATH" || -z "$BUILD_VERSION" ]]; then
        echo "Error: Missing mandatory options."
        echo "Usage: app-deploy tagging -e \"environment_name\" -p \"path/to/app.{ipa/apk}\" -v \"{build number}\""
        echo "Example: app-deploy tagging -e \"internal-staging\" -p \"path/to/app.ipa\" -v \"42\""
        exit 1
    fi
}

function __check_platform {
    if [ ${APP_PATH##*.} == "ipa" ]; then
        echo $PLATFORM_IOS
    elif [ ${APP_PATH##*.} == "apk" ]; then
        echo $PLATFORM_ANDROID_APK
    elif [ ${APP_PATH##*.} == "aab" ]; then
        echo $PLATFORM_ANDROID_AAB
    fi
}