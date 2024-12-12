source /usr/local/bin/.app-deploy-sources/__constants.sh
source /usr/local/bin/.app-deploy-sources/__build_tagging_ios.sh
source /usr/local/bin/.app-deploy-sources/__build_tagging_android.sh

#################################
#        CREATE BUILD TAG       #
#################################

# Main logic

function __build_tagging {

    __validate_options "$@"

    APP_VERSION=""
    APP_PLATFORM=$(__check_platform)
    if [ "$APP_PLATFORM" == "$PLATFORM_ANDROID_APK" ]; then
        APP_VERSION=$(__generate_app_version_from_apk "$APP_PATH" "$BUILD_COUNT")
    elif [ "$APP_PLATFORM" == "$PLATFORM_ANDROID_AAB" ]; then
        APP_VERSION=$(__generate_app_version_from_aab "$APP_PATH" "$BUILD_COUNT")
    elif [ "$APP_PLATFORM" == "$PLATFORM_IOS" ]; then
        APP_VERSION=$(__generate_app_version_from_ipa "$APP_PATH" "$BUILD_COUNT")
    else
        echo
        echo "Unsupported file format: ${APP_PATH##*.}"
        echo "Please use only supported file formats: apk, aab, or ipa"
        echo
        exit 1
    fi

    __create_and_push_tag
}

# Tag creation & push

function __create_and_push_tag {

    # If there is a custom app version passed, append build number to it
    if [[ -n "$CUSTOM_APP_VERSION" ]]; then
        CUSTOM_APP_VERSION="${CUSTOM_APP_VERSION}b${BUILD_COUNT}"
    fi

    CHANGELOG=${CHANGELOG:-""} # Set empty string if changelog is not available
    TAG="${ENVIRONMENT}/v${CUSTOM_APP_VERSION:-$APP_VERSION}"
    git tag -a "$TAG" -m "${CHANGELOG}"
    git push origin "$TAG"
}

# Validation and checks

function __validate_options {
    shift

    while getopts "e:p:b:v:c:" opt; do
        case "$opt" in
            e) ENVIRONMENT="$OPTARG" ;;
            p) APP_PATH="$OPTARG" ;;
            b) BUILD_COUNT="$OPTARG" ;;
            v) CUSTOM_APP_VERSION="$OPTARG" ;;
            c) CHANGELOG="$OPTARG" ;;
            *) echo "Error: Invalid option"; exit 1 ;;
        esac
    done

    # Check if all mandatory options are provided
    if [[ -z "$ENVIRONMENT" || -z "$APP_PATH" || -z "$BUILD_COUNT" ]]; then
        echo "Error: Missing mandatory options."
        echo "Usage: app-deploy tagging -e \"environment_name\" -p \"path/to/app.{ipa/apk}\" -b \"{build count}\""
        echo "Example: app-deploy tagging -e \"internal-staging\" -p \"path/to/app.ipa\" -b \"42\""
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